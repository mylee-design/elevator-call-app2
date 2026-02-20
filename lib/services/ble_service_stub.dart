// Stub implementation for web platform
// BLE is not supported on web

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/ble_device.dart';
import '../models/elevator_command.dart';
import '../models/elevator_status.dart';

class BleService extends ChangeNotifier {
  bool get isScanning => false;
  bool get isConnected => false;
  bool get isAuthenticated => false;
  List<BleDevice> get devices => [];
  BleDevice? get connectedDevice => null;
  ElevatorStatus? get currentStatus => null;
  String? get errorMessage => 'BLE is not supported on web platform';

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    throw UnsupportedError('BLE scanning is not supported on web');
  }

  Future<void> stopScan() async {}

  Future<bool> connect(BleDevice device) async {
    return false;
  }

  Future<void> disconnect() async {}

  Future<bool> callFloor(int floor) async {
    return false;
  }

  Future<bool> openDoor() async => false;
  Future<bool> closeDoor() async => false;
  Future<bool> holdDoor() async => false;
}
