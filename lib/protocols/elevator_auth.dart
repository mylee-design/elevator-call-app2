import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../constants/ble_uuids.dart';

/// 엘리베이터 인증 프로토콜
///
/// BLE 연결 후 Challenge-Response 인증을 수행합니다.

class ElevatorAuth {
  final BluetoothDevice device;
  BluetoothCharacteristic? _authRequestChar;
  BluetoothCharacteristic? _authResponseChar;
  BluetoothCharacteristic? _sessionTokenChar;

  StreamSubscription<List<int>>? _responseSubscription;
  final _responseController = StreamController<AuthResponse>.broadcast();

  ElevatorAuth({required this.device});

  /// 인증 서비스 초기화
  Future<bool> initialize() async {
    try {
      List<BluetoothService> services = await device.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid == BleUuids.authServiceUuid) {
          for (BluetoothCharacteristic char in service.characteristics) {
            if (char.uuid == BleUuids.authRequestCharacteristic) {
              _authRequestChar = char;
            } else if (char.uuid == BleUuids.authResponseCharacteristic) {
              _authResponseChar = char;
              // 응답 알림 구독 설정
              await _setupResponseListener();
            } else if (char.uuid == BleUuids.sessionTokenCharacteristic) {
              _sessionTokenChar = char;
            }
          }
        }
      }

      return _authRequestChar != null && _authResponseChar != null;
    } catch (e) {
      print('Auth initialization error: $e');
      return false;
    }
  }

  /// 응답 리스너 설정
  Future<void> _setupResponseListener() async {
    if (_authResponseChar == null) return;

    // Notify 활성화
    await _authResponseChar!.setNotifyValue(true);

    // 응답 스트림 구독
    _responseSubscription = _authResponseChar!.lastValueStream.listen((value) {
      if (value.isNotEmpty) {
        try {
          final response = AuthResponse.fromBytes(Uint8List.fromList(value));
          _responseController.add(response);
        } catch (e) {
          print('Auth response parsing error: $e');
        }
      }
    });
  }

  /// Challenge-Response 인증 수행
  Future<AuthResult> authenticate({
    required String qrToken,
    required String deviceId,
    String? userId,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      if (_authRequestChar == null) {
        return AuthResult.failure('Auth service not initialized');
      }

      // 1. Challenge 요청
      final challengeRequest = ChallengeRequest(
        qrToken: qrToken,
        deviceId: deviceId,
        userId: userId,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await _authRequestChar!.write(challengeRequest.toBytes());

      // 2. Challenge 응답 대기
      final response = await _responseController.stream
          .where((r) => r.type == AuthResponseType.challenge)
          .timeout(timeout)
          .first;

      if (!response.success) {
        return AuthResult.failure(response.message ?? 'Challenge failed');
      }

      // 3. Challenge 검증 및 Response 생성
      final challengeData = response.challengeData;
      if (challengeData == null) {
        return AuthResult.failure('No challenge data received');
      }

      final challengeResponse = _generateChallengeResponse(
        challengeData: challengeData,
        qrToken: qrToken,
      );

      // 4. Response 전송
      await _authRequestChar!.write(challengeResponse.toBytes());

      // 5. 인증 결과 대기
      final authResponse = await _responseController.stream
          .where((r) => r.type == AuthResponseType.authResult)
          .timeout(timeout)
          .first;

      if (authResponse.success && authResponse.sessionToken != null) {
        // 세션 토큰 저장
        await _saveSessionToken(authResponse.sessionToken!);
        return AuthResult.success(
          sessionToken: authResponse.sessionToken!,
          expiresAt: authResponse.expiresAt,
          permissions: authResponse.permissions,
        );
      } else {
        return AuthResult.failure(authResponse.message ?? 'Authentication failed');
      }
    } on TimeoutException {
      return AuthResult.failure('Authentication timeout');
    } catch (e) {
      return AuthResult.failure('Authentication error: $e');
    }
  }

  /// Challenge Response 생성
  ChallengeResponseData _generateChallengeResponse({
    required Uint8List challengeData,
    required String qrToken,
  }) {
    // 간단한 Challenge-Response 구현
    // 실제 구현에서는 HMAC-SHA256 등의 암호화 사용 권장

    final qrHash = _simpleHash(qrToken);
    final response = Uint8List(challengeData.length);

    for (int i = 0; i < challengeData.length; i++) {
      response[i] = challengeData[i] ^ qrHash[i % qrHash.length];
    }

    return ChallengeResponseData(response: response);
  }

  /// 간단한 해시 함수 (실제 구현에서는 crypto 라이브러리 사용)
  Uint8List _simpleHash(String input) {
    final bytes = utf8.encode(input);
    final hash = Uint8List(32);

    for (int i = 0; i < hash.length; i++) {
      hash[i] = bytes[i % bytes.length] ^ (i * 7);
    }

    return hash;
  }

  /// 세션 토큰 저장
  Future<void> _saveSessionToken(String token) async {
    if (_sessionTokenChar != null) {
      await _sessionTokenChar!.write(utf8.encode(token));
    }
  }

  /// 세션 토큰 읽기
  Future<String?> readSessionToken() async {
    if (_sessionTokenChar == null) return null;

    final value = await _sessionTokenChar!.read();
    if (value.isNotEmpty) {
      return utf8.decode(value);
    }
    return null;
  }

  /// 리소스 정리
  void dispose() {
    _responseSubscription?.cancel();
    _responseController.close();
  }
}

/// Challenge 요청
class ChallengeRequest {
  final String qrToken;
  final String deviceId;
  final String? userId;
  final int timestamp;

  ChallengeRequest({
    required this.qrToken,
    required this.deviceId,
    this.userId,
    required this.timestamp,
  });

  Uint8List toBytes() {
    final json = jsonEncode({
      'qr_token': qrToken,
      'device_id': deviceId,
      'user_id': userId,
      'timestamp': timestamp,
    });
    return Uint8List.fromList(utf8.encode(json));
  }
}

/// Challenge 응답 데이터
class ChallengeResponseData {
  final Uint8List response;

  ChallengeResponseData({required this.response});

  Uint8List toBytes() {
    final header = Uint8List.fromList([0x01]); // Response type
    return Uint8List.fromList([...header, ...response]);
  }
}

/// 인증 응답
class AuthResponse {
  final AuthResponseType type;
  final bool success;
  final String? message;
  final Uint8List? challengeData;
  final String? sessionToken;
  final DateTime? expiresAt;
  final List<String>? permissions;

  AuthResponse({
    required this.type,
    required this.success,
    this.message,
    this.challengeData,
    this.sessionToken,
    this.expiresAt,
    this.permissions,
  });

  factory AuthResponse.fromBytes(Uint8List bytes) {
    try {
      final json = utf8.decode(bytes);
      final data = jsonDecode(json);

      return AuthResponse(
        type: AuthResponseType.fromString(data['type']),
        success: data['success'] ?? false,
        message: data['message'],
        challengeData: data['challenge_data'] != null
            ? base64Decode(data['challenge_data'])
            : null,
        sessionToken: data['session_token'],
        expiresAt: data['expires_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(data['expires_at'])
            : null,
        permissions: data['permissions']?.cast<String>(),
      );
    } catch (e) {
      return AuthResponse(
        type: AuthResponseType.error,
        success: false,
        message: 'Invalid response format',
      );
    }
  }
}

/// 인증 응답 타입
enum AuthResponseType {
  challenge('challenge'),
  authResult('auth_result'),
  error('error');

  final String value;

  const AuthResponseType(this.value);

  factory AuthResponseType.fromString(String? value) {
    return AuthResponseType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AuthResponseType.error,
    );
  }
}

/// 인증 결과
class AuthResult {
  final bool success;
  final String? errorMessage;
  final String? sessionToken;
  final DateTime? expiresAt;
  final List<String>? permissions;

  AuthResult._({
    required this.success,
    this.errorMessage,
    this.sessionToken,
    this.expiresAt,
    this.permissions,
  });

  factory AuthResult.success({
    required String sessionToken,
    DateTime? expiresAt,
    List<String>? permissions,
  }) {
    return AuthResult._(
      success: true,
      sessionToken: sessionToken,
      expiresAt: expiresAt,
      permissions: permissions,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      success: false,
      errorMessage: errorMessage,
    );
  }

  bool get isAuthenticated => success && sessionToken != null;
}
