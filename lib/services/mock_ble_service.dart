import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/ble_device.dart';

class MockBleService extends ChangeNotifier {
  final List<BleDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  BleDevice? _connectedDevice;
  Timer? _scanTimer;
  Timer? _statusTimer;
  String _elevatorStatus = 'idle';
  int _currentFloor = 1;

  List<BleDevice> get devices => List.unmodifiable(_devices);
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  BleDevice? get connectedDevice => _connectedDevice;
  String get elevatorStatus => _elevatorStatus;
  int get currentFloor => _currentFloor;

  Future<bool> requestPermissions() async {
    // Mock permissions always granted
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isScanning) return;

    _devices.clear();
    _isScanning = true;
    notifyListeners();

    // Simulate discovering mock devices
    final mockDevices = [
      _createMockDevice('ELV-001', 'Elevator A', -45),
      _createMockDevice('ELV-002', 'Elevator B', -62),
      _createMockDevice('ELV-003', 'Elevator C', -78),
    ];

    int index = 0;
    _scanTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (index < mockDevices.length) {
        _devices.add(mockDevices[index]);
        index++;
        notifyListeners();
      }
    });

    await Future.delayed(timeout);
    await stopScan();
  }

  Future<void> stopScan() async {
    _scanTimer?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connect(BleDevice bleDevice) async {
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));

    _isConnected = true;
    _connectedDevice = bleDevice;
    _elevatorStatus = 'idle';

    // Simulate status updates
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _simulateStatusChanges();
    });

    notifyListeners();
  }

  Future<void> disconnect() async {
    _statusTimer?.cancel();
    _isConnected = false;
    _connectedDevice = null;
    _elevatorStatus = 'idle';
    notifyListeners();
  }

  Future<void> sendCommand(String command) async {
    if (!_isConnected) {
      throw Exception('Not connected to any device');
    }

    // Simulate command processing
    await Future.delayed(const Duration(milliseconds: 500));

    if (command.startsWith('CALL:')) {
      _elevatorStatus = 'moving';
      notifyListeners();

      // Simulate elevator movement
      await Future.delayed(const Duration(seconds: 3));
      _elevatorStatus = 'arrived';
      notifyListeners();

      await Future.delayed(const Duration(seconds: 2));
      _elevatorStatus = 'idle';
      notifyListeners();
    }
  }

  Future<String?> readStatus() async {
    if (!_isConnected) return null;

    return jsonEncode({
      'status': _elevatorStatus,
      'current_floor': _currentFloor,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  BleDevice _createMockDevice(String id, String name, int rssi) {
    return BleDevice(
      id: id,
      name: name,
      rssi: rssi,
      serviceUuids: ['00001800-0000-1000-8000-00805f9b34fb'],
    );
  }

  void _simulateStatusChanges() {
    final random = Random();
    if (random.nextDouble() < 0.3) {
      _currentFloor = random.nextInt(10) + 1;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopScan();
    disconnect();
    super.dispose();
  }
}

String jsonEncode(Map<String, dynamic> data) {
  return '{${data.entries.map((e) => '"${e.key}":"${e.value}"').join(',')}}';
}
