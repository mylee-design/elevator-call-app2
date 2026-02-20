import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../constants/ble_uuids.dart';
import '../models/ble_device.dart';
import '../models/elevator_command.dart';
import '../models/elevator_status.dart';
import '../protocols/ble_advertisement_parser.dart';
import '../protocols/elevator_auth.dart';

/// 통합 엘리베이터 서비스
///
/// BLE 스캔, 연결, 인증, 명령 전송, 상태 수신을 통합 관리합니다.

class ElevatorService extends ChangeNotifier {
  // ========== State ==========
  final List<ElevatorAdvertisement> _discoveredElevators = [];
  ElevatorAdvertisement? _selectedElevator;
  BluetoothDevice? _connectedDevice;
  ElevatorStatus? _currentStatus;
  ElevatorInfo? _elevatorInfo;

  bool _isScanning = false;
  bool _isConnecting = false;
  bool _isAuthenticated = false;
  String? _sessionToken;
  String? _errorMessage;

  // ========== Subscriptions ==========
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription<List<int>>? _statusSubscription;

  // ========== Getters ==========
  List<ElevatorAdvertisement> get discoveredElevators => List.unmodifiable(_discoveredElevators);
  ElevatorAdvertisement? get selectedElevator => _selectedElevator;
  BluetoothDevice? get connectedDevice => _connectedDevice;
  ElevatorStatus? get currentStatus => _currentStatus;
  ElevatorInfo? get elevatorInfo => _elevatorInfo;

  bool get isScanning => _isScanning;
  bool get isConnecting => _isConnecting;
  bool get isConnected => _connectedDevice != null;
  bool get isAuthenticated => _isAuthenticated;
  String? get sessionToken => _sessionToken;
  String? get errorMessage => _errorMessage;

  /// 현재 층
  int? get currentFloor => _currentStatus?.currentFloor;

  /// 목표 층
  int? get targetFloor => _currentStatus?.targetFloor;

  /// 이동 중인지
  bool get isMoving => _currentStatus?.isMoving ?? false;

  /// 도착했는지
  bool get isArrived => _currentStatus?.isArrived ?? false;

  // ========== BLE Scanning ==========

  /// 엘리베이터 BLE 기기 스캔 시작
  Future<void> startScan({Duration timeout = BleConfig.scanTimeout}) async {
    if (_isScanning) return;

    _discoveredElevators.clear();
    _isScanning = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          _processScanResult(result);
        }
      });

      await FlutterBluePlus.startScan(
        timeout: timeout,
        androidUsesFineLocation: true,
      );

      // 타임아웃 후 자동 종료
      Future.delayed(timeout, () => stopScan());
    } catch (e) {
      _errorMessage = 'Scan error: $e';
      _isScanning = false;
      notifyListeners();
    }
  }

  /// 스캔 결과 처리
  void _processScanResult(ScanResult result) {
    final advertisement = BleAdvertisementParser.parseElevatorAdvertisement(
      result.device,
      result.advertisementData,
    );

    if (advertisement != null) {
      // 중복 체크
      final existingIndex = _discoveredElevators.indexWhere(
        (e) => e.deviceId == advertisement.deviceId,
      );

      if (existingIndex >= 0) {
        // RSSI 업데이트
        _discoveredElevators[existingIndex] = advertisement;
      } else {
        _discoveredElevators.add(advertisement);
      }

      notifyListeners();
    }
  }

  /// 스캔 중지
  Future<void> stopScan() async {
    if (!_isScanning) return;

    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    _isScanning = false;
    notifyListeners();
  }

  // ========== Connection ==========

  /// 엘리베이터 선택
  void selectElevator(ElevatorAdvertisement elevator) {
    _selectedElevator = elevator;
    notifyListeners();
  }

  /// 엘리베이터에 연결
  Future<bool> connect({
    required ElevatorAdvertisement elevator,
    Duration timeout = BleConfig.connectionTimeout,
  }) async {
    if (_isConnecting) return false;

    _isConnecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 기기 검색
      final device = BluetoothDevice.fromId(elevator.deviceId);
      _connectedDevice = device;

      // 연결 상태 모니터링
      _connectionSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      // 연결 시도
      await device.connect(timeout: timeout);

      // MTU 협상
      try {
        await device.requestMtu(BleConfig.mtuSize);
      } catch (e) {
        print('MTU negotiation failed: $e');
      }

      _isConnecting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Connection failed: $e';
      _isConnecting = false;
      _connectedDevice = null;
      notifyListeners();
      return false;
    }
  }

  /// 연결 해제
  Future<void> disconnect() async {
    if (_connectedDevice == null) return;

    await _statusSubscription?.cancel();
    await _connectionSubscription?.cancel();
    await _connectedDevice?.disconnect();

    _handleDisconnection();
  }

  /// 연결 해제 처리
  void _handleDisconnection() {
    _connectedDevice = null;
    _isAuthenticated = false;
    _sessionToken = null;
    _currentStatus = null;
    _statusSubscription = null;
    notifyListeners();
  }

  // ========== Authentication ==========

  /// 인증 수행
  Future<AuthResult> authenticate({
    required String qrToken,
    required String deviceId,
    String? userId,
  }) async {
    if (_connectedDevice == null) {
      return AuthResult.failure('Not connected');
    }

    try {
      final auth = ElevatorAuth(device: _connectedDevice!);
      final initialized = await auth.initialize();

      if (!initialized) {
        // 인증 서비스가 없으면 기본 인증으로 간주
        _isAuthenticated = true;
        notifyListeners();
        return AuthResult.success(sessionToken: 'default');
      }

      final result = await auth.authenticate(
        qrToken: qrToken,
        deviceId: deviceId,
        userId: userId,
      );

      if (result.isAuthenticated) {
        _isAuthenticated = true;
        _sessionToken = result.sessionToken;
        notifyListeners();
      }

      auth.dispose();
      return result;
    } catch (e) {
      return AuthResult.failure('Authentication error: $e');
    }
  }

  // ========== Commands ==========

  /// 층 호출 명령 전송
  Future<bool> callFloor(int targetFloor) async {
    if (!_isReadyForCommand) return false;

    try {
      final command = FloorCallCommand(
        targetFloor: targetFloor,
        currentFloor: _currentStatus?.currentFloor,
      );

      return await _sendCommand(command);
    } catch (e) {
      _errorMessage = 'Call floor error: $e';
      notifyListeners();
      return false;
    }
  }

  /// 문 열기 명령
  Future<bool> openDoor() async {
    return _sendDoorCommand(DoorAction.open);
  }

  /// 문 닫기 명령
  Future<bool> closeDoor() async {
    return _sendDoorCommand(DoorAction.close);
  }

  /// 문 유지 명령
  Future<bool> holdDoor() async {
    return _sendDoorCommand(DoorAction.hold);
  }

  /// 문 제어 명령 전송
  Future<bool> _sendDoorCommand(DoorAction action) async {
    if (!_isReadyForCommand) return false;

    try {
      final command = DoorControlCommand(action: action);
      return await _sendCommand(command);
    } catch (e) {
      _errorMessage = 'Door control error: $e';
      notifyListeners();
      return false;
    }
  }

  /// 비상 정지
  Future<bool> emergencyStop({String? reason}) async {
    if (_connectedDevice == null) return false;

    try {
      final command = EmergencyStopCommand(
        reason: reason,
        userId: _sessionToken,
      );
      return await _sendCommand(command);
    } catch (e) {
      _errorMessage = 'Emergency stop error: $e';
      notifyListeners();
      return false;
    }
  }

  /// 명령 전송 공통 메서드
  Future<bool> _sendCommand(ElevatorCommand command) async {
    final service = await _findService(BleUuids.elevatorServiceUuid);
    if (service == null) return false;

    final characteristic = await _findCharacteristic(
      service,
      BleUuids.floorCallCharacteristic,
    );
    if (characteristic == null) return false;

    await characteristic.write(command.toBytes());
    return true;
  }

  /// 명령 전송 가능 여부
  bool get _isReadyForCommand {
    if (_connectedDevice == null) {
      _errorMessage = 'Not connected';
      return false;
    }
    // 인증이 필요한 경우 체크
    // if (!_isAuthenticated) {
    //   _errorMessage = 'Not authenticated';
    //   return false;
    // }
    return true;
  }

  // ========== Status Monitoring ==========

  /// 상태 모니터링 시작
  Future<bool> startStatusMonitoring() async {
    if (_connectedDevice == null) return false;

    try {
      final service = await _findService(BleUuids.elevatorStatusServiceUuid) ??
                       await _findService(BleUuids.elevatorServiceUuid);
      if (service == null) return false;

      // 현재 층 특성
      final floorChar = await _findCharacteristic(
        service,
        BleUuids.currentFloorCharacteristic,
      );

      if (floorChar != null) {
        await floorChar.setNotifyValue(true);
        _statusSubscription?.cancel();
        _statusSubscription = floorChar.lastValueStream.listen(_handleStatusUpdate);
      }

      // 초기 상태 읽기
      await _readInitialStatus(service);

      return true;
    } catch (e) {
      print('Status monitoring error: $e');
      return false;
    }
  }

  /// 상태 업데이트 처리
  void _handleStatusUpdate(List<int> value) {
    try {
      if (value.isEmpty) return;

      final status = ElevatorStatus.fromBinary(Uint8List.fromList(value));
      _currentStatus = status;
      notifyListeners();
    } catch (e) {
      print('Status parsing error: $e');
    }
  }

  /// 초기 상태 읽기
  Future<void> _readInitialStatus(BluetoothService service) async {
    try {
      final floorChar = await _findCharacteristic(
        service,
        BleUuids.currentFloorCharacteristic,
      );

      if (floorChar != null) {
        final value = await floorChar.read();
        _handleStatusUpdate(value);
      }
    } catch (e) {
      print('Initial status read error: $e');
    }
  }

  // ========== Helper Methods ==========

  /// 서비스 찾기
  Future<BluetoothService?> _findService(Guid uuid) async {
    if (_connectedDevice == null) return null;

    try {
      final services = await _connectedDevice!.discoverServices();
      return services.firstWhere(
        (s) => s.uuid == uuid,
        orElse: () => services.firstWhere(
          (s) => BleUuids.isElevatorService(s.uuid),
          orElse: () => throw Exception('Service not found'),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// 특성 찾기
  Future<BluetoothCharacteristic?> _findCharacteristic(
    BluetoothService service,
    Guid uuid,
  ) async {
    try {
      return service.characteristics.firstWhere((c) => c.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// 엘리베이터 정보 읽기
  Future<ElevatorInfo?> readElevatorInfo() async {
    if (_connectedDevice == null) return null;

    try {
      final service = await _findService(BleUuids.elevatorServiceUuid);
      if (service == null) return null;

      final infoChar = await _findCharacteristic(
        service,
        BleUuids.elevatorInfoCharacteristic,
      );

      if (infoChar != null) {
        final value = await infoChar.read();
        final json = String.fromCharCodes(value);
        _elevatorInfo = ElevatorInfo.fromJson(json);
        notifyListeners();
        return _elevatorInfo;
      }
    } catch (e) {
      print('Read elevator info error: $e');
    }
    return null;
  }

  /// 에러 클리어
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ========== Cleanup ==========

  @override
  void dispose() {
    stopScan();
    disconnect();
    super.dispose();
  }
}
