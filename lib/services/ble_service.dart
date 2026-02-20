import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Conditional imports for web vs mobile
import '../models/ble_device.dart';
import '../models/elevator_command.dart';
import '../models/elevator_status.dart';

/// BLE Service - Web stub version
///
/// 웹에서는 BLE가 지원되지 않으므로 Mock 모드만 사용 가능

class BleService extends ChangeNotifier {
  final List<BleDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  bool _isAuthenticated = false;
  BleDevice? _connectedDevice;
  ElevatorStatus? _currentStatus;
  String? _errorMessage;

  // Mock device for web
  final List<BleDevice> _mockDevices = [
    BleDevice(
      id: 'mock-elevator-1',
      name: 'Mock Elevator 1',
      rssi: -50,
      isConnectable: true,
    ),
    BleDevice(
      id: 'mock-elevator-2',
      name: 'Mock Elevator 2',
      rssi: -65,
      isConnectable: true,
    ),
  ];

  List<BleDevice> get devices => List.unmodifiable(_devices);
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  bool get isAuthenticated => _isAuthenticated;
  BleDevice? get connectedDevice => _connectedDevice;
  ElevatorStatus? get currentStatus => _currentStatus;
  String? get errorMessage => _errorMessage;

  /// Start scanning for BLE devices
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    _isScanning = true;
    _devices.clear();
    _errorMessage = null;
    notifyListeners();

    // Simulate scan delay
    await Future.delayed(const Duration(seconds: 2));

    // Add mock devices for web demo
    _devices.addAll(_mockDevices);
    _isScanning = false;
    notifyListeners();
  }

  /// Stop scanning
  Future<void> stopScan() async {
    _isScanning = false;
    notifyListeners();
  }

  /// Connect to a BLE device
  Future<bool> connect(BleDevice device) async {
    _isConnected = true;
    _connectedDevice = device;
    notifyListeners();

    // Simulate initial status
    _currentStatus = ElevatorStatus(
      currentFloor: 1,
      targetFloor: null,
      direction: ElevatorDirection.stopped,
      doorStatus: DoorStatus.closed,
    );
    notifyListeners();

    return true;
  }

  /// Disconnect from the device
  Future<void> disconnect() async {
    _isConnected = false;
    _isAuthenticated = false;
    _connectedDevice = null;
    _currentStatus = null;
    notifyListeners();
  }

  /// Call elevator to a specific floor
  Future<bool> callFloor(int floor) async {
    if (!_isConnected) return false;

    // Simulate elevator movement
    _currentStatus = ElevatorStatus(
      currentFloor: _currentStatus?.currentFloor ?? 1,
      targetFloor: floor,
      direction: floor > (_currentStatus?.currentFloor ?? 1)
          ? ElevatorDirection.up
          : ElevatorDirection.down,
      doorStatus: DoorStatus.closed,
    );
    notifyListeners();

    // Simulate movement
    await Future.delayed(const Duration(seconds: 3));

    _currentStatus = ElevatorStatus(
      currentFloor: floor,
      targetFloor: null,
      direction: ElevatorDirection.stopped,
      doorStatus: DoorStatus.open,
    );
    notifyListeners();

    return true;
  }

  /// Open elevator door
  Future<bool> openDoor() async {
    if (!_isConnected) return false;

    _currentStatus = _currentStatus?.copyWith(
      doorStatus: DoorStatus.open,
    );
    notifyListeners();
    return true;
  }

  /// Close elevator door
  Future<bool> closeDoor() async {
    if (!_isConnected) return false;

    _currentStatus = _currentStatus?.copyWith(
      doorStatus: DoorStatus.closed,
    );
    notifyListeners();
    return true;
  }

  /// Hold elevator door
  Future<bool> holdDoor() async {
    if (!_isConnected) return false;
    return true;
  }

  /// Authenticate with the elevator
  Future<bool> authenticate(String qrToken) async {
    if (!_isConnected) return false;

    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    stopScan();
    disconnect();
    super.dispose();
  }
}
