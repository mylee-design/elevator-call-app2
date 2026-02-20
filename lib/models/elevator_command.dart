import 'dart:convert';
import 'dart:typed_data';

/// 엘리베이터 명령 모델
///
/// BLE를 통해 엘리베이터로 전송되는 명령을 정의합니다.

abstract class ElevatorCommand {
  /// 명령 타입
  String get type;

  /// 명령을 JSON 문자열로 변환
  String toJson();

  /// 명령을 UTF-8 바이트 배열로 변환 (BLE 전송용)
  Uint8List toBytes() {
    return Uint8List.fromList(utf8.encode(toJson()));
  }

  /// 명령을 BSON 스타일 바이너리로 변환 (효율적 전송용)
  Uint8List toBinary();
}

/// 층 호출 명령
class FloorCallCommand extends ElevatorCommand {
  /// 목표 층
  final int targetFloor;

  /// 현재 층 (선택사항)
  final int? currentFloor;

  /// 우선 순위 (1-10, 높을수록 우선)
  final int priority;

  /// 타임스탬프
  final int timestamp;

  /// 요청 ID
  final String requestId;

  FloorCallCommand({
    required this.targetFloor,
    this.currentFloor,
    this.priority = 5,
    String? requestId,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch,
       requestId = requestId ?? _generateRequestId();

  static String _generateRequestId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${targetFloor.hashCode}';
  }

  @override
  String get type => 'floor_call';

  @override
  String toJson() {
    return jsonEncode({
      'type': type,
      'target_floor': targetFloor,
      'current_floor': currentFloor,
      'priority': priority,
      'timestamp': timestamp,
      'request_id': requestId,
    });
  }

  @override
  Uint8List toBinary() {
    // 간소화된 바이너리 포맷
    // [0] = 명령 타입 (0x01 = floor call)
    // [1-2] = 타겟 층 (16-bit signed)
    // [3-4] = 현재 층 (16-bit signed, -1 if null)
    // [5] = 우선순위
    // [6-13] = 타임스탬프 (64-bit)
    final bytes = BytesBuilder();
    bytes.addByte(0x01); // 명령 타입
    bytes.add(_int16ToBytes(targetFloor));
    bytes.add(_int16ToBytes(currentFloor ?? -1));
    bytes.addByte(priority);
    bytes.add(_int64ToBytes(timestamp));
    return bytes.toBytes();
  }

  static Uint8List _int16ToBytes(int value) {
    final byteData = ByteData(2);
    byteData.setInt16(0, value, Endian.little);
    return Uint8List.view(byteData.buffer);
  }

  static Uint8List _int64ToBytes(int value) {
    final byteData = ByteData(8);
    byteData.setInt64(0, value, Endian.little);
    return Uint8List.view(byteData.buffer);
  }

  factory FloorCallCommand.fromJson(String json) {
    final data = jsonDecode(json);
    return FloorCallCommand(
      targetFloor: data['target_floor'],
      currentFloor: data['current_floor'],
      priority: data['priority'] ?? 5,
      requestId: data['request_id'],
    );
  }
}

/// 문 제어 명령
class DoorControlCommand extends ElevatorCommand {
  /// 문 동작 타입
  final DoorAction action;

  DoorControlCommand({required this.action});

  @override
  String get type => 'door_control';

  @override
  String toJson() {
    return jsonEncode({
      'type': type,
      'action': action.value,
    });
  }

  @override
  Uint8List toBinary() {
    // [0] = 명령 타입 (0x02 = door control)
    // [1] = 동작 (0x01=open, 0x02=close, 0x03=hold)
    return Uint8List.fromList([0x02, action.binaryValue]);
  }

  factory DoorControlCommand.fromJson(String json) {
    final data = jsonDecode(json);
    return DoorControlCommand(
      action: DoorAction.fromString(data['action']),
    );
  }
}

/// 비상 정지 명령
class EmergencyStopCommand extends ElevatorCommand {
  /// 정지 이유
  final String? reason;

  /// 사용자 ID
  final String? userId;

  EmergencyStopCommand({this.reason, this.userId});

  @override
  String get type => 'emergency_stop';

  @override
  String toJson() {
    return jsonEncode({
      'type': type,
      'reason': reason,
      'user_id': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Uint8List toBinary() {
    // [0] = 명령 타입 (0xFF = emergency stop)
    return Uint8List.fromList([0xFF]);
  }

  factory EmergencyStopCommand.fromJson(String json) {
    final data = jsonDecode(json);
    return EmergencyStopCommand(
      reason: data['reason'],
      userId: data['user_id'],
    );
  }
}

/// 인증 요청 명령
class AuthRequestCommand extends ElevatorCommand {
  /// QR 코드 토큰
  final String qrToken;

  /// 기기 ID
  final String deviceId;

  /// 사용자 ID
  final String? userId;

  AuthRequestCommand({
    required this.qrToken,
    required this.deviceId,
    this.userId,
  });

  @override
  String get type => 'auth_request';

  @override
  String toJson() {
    return jsonEncode({
      'type': type,
      'qr_token': qrToken,
      'device_id': deviceId,
      'user_id': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Uint8List toBinary() {
    // 인증은 보안상 JSON 사용 권장
    return toBytes();
  }

  factory AuthRequestCommand.fromJson(String json) {
    final data = jsonDecode(json);
    return AuthRequestCommand(
      qrToken: data['qr_token'],
      deviceId: data['device_id'],
      userId: data['user_id'],
    );
  }
}

/// 문 동작 타입
enum DoorAction {
  open('open', 0x01),
  close('close', 0x02),
  hold('hold', 0x03);

  final String value;
  final int binaryValue;

  const DoorAction(this.value, this.binaryValue);

  factory DoorAction.fromString(String value) {
    return DoorAction.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DoorAction.hold,
    );
  }
}

/// 명령 팩토리
class ElevatorCommandFactory {
  ElevatorCommandFactory._();

  static ElevatorCommand? fromJson(String json) {
    try {
      final data = jsonDecode(json);
      final type = data['type'] as String;

      switch (type) {
        case 'floor_call':
          return FloorCallCommand.fromJson(json);
        case 'door_control':
          return DoorControlCommand.fromJson(json);
        case 'emergency_stop':
          return EmergencyStopCommand.fromJson(json);
        case 'auth_request':
          return AuthRequestCommand.fromJson(json);
        default:
          return null;
      }
    } catch (e) {
      return null;
    }
  }

  static ElevatorCommand? fromBinary(Uint8List bytes) {
    if (bytes.isEmpty) return null;

    final commandType = bytes[0];

    switch (commandType) {
      case 0x01: // Floor Call
        if (bytes.length < 14) return null;
        final byteData = ByteData.sublistView(bytes);
        return FloorCallCommand(
          targetFloor: byteData.getInt16(1, Endian.little),
          currentFloor: byteData.getInt16(3, Endian.little) == -1
              ? null
              : byteData.getInt16(3, Endian.little),
          priority: bytes[5],
        );
      case 0x02: // Door Control
        if (bytes.length < 2) return null;
        final action = DoorAction.values.firstWhere(
          (e) => e.binaryValue == bytes[1],
          orElse: () => DoorAction.hold,
        );
        return DoorControlCommand(action: action);
      case 0xFF: // Emergency Stop
        return EmergencyStopCommand();
      default:
        return null;
    }
  }
}
