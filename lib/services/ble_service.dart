import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/ble_device.dart';

class BleService extends ChangeNotifier {
  final List<BleDevice> _devices = [];
  bool _isScanning = false;
  bool _isConnected = false;
  BleDevice? _connectedDevice;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;

  // UUIDs for elevator service (example)
  static final Guid elevatorServiceUuid = Guid("00001800-0000-1000-8000-00805f9b34fb");
  static final Guid commandCharacteristicUuid = Guid("00002a00-0000-1000-8000-00805f9b34fb");
  static final Guid statusCharacteristicUuid = Guid("00002a01-0000-1000-8000-00805f9b34fb");

  List<BleDevice> get devices => List.unmodifiable(_devices);
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  BleDevice? get connectedDevice => _connectedDevice;

  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isScanning) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Bluetooth permissions not granted');
    }

    _devices.clear();
    _isScanning = true;
    notifyListeners();

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        final device = BleDevice.fromScanResult(result);
        if (!_devices.any((d) => d.id == device.id)) {
          _devices.add(device);
          notifyListeners();
        }
      }
    });

    await FlutterBluePlus.startScan(
      timeout: timeout,
      androidUsesFineLocation: true,
    );

    await Future.delayed(timeout);
    await stopScan();
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  Future<void> connect(BleDevice bleDevice) async {
    if (bleDevice.device == null) return;

    try {
      _connectionSubscription = bleDevice.device!.connectionState.listen((state) {
        _isConnected = state == BluetoothConnectionState.connected;
        if (_isConnected) {
          _connectedDevice = bleDevice;
        } else {
          _connectedDevice = null;
        }
        notifyListeners();
      });

      await bleDevice.device!.connect(
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      _isConnected = false;
      _connectedDevice = null;
      notifyListeners();
      throw Exception('Failed to connect: $e');
    }
  }

  Future<void> disconnect() async {
    if (_connectedDevice?.device != null) {
      await _connectedDevice!.device!.disconnect();
    }
    await _connectionSubscription?.cancel();
    _isConnected = false;
    _connectedDevice = null;
    notifyListeners();
  }

  Future<void> sendCommand(String command) async {
    if (!_isConnected || _connectedDevice?.device == null) {
      throw Exception('Not connected to any device');
    }

    try {
      List<BluetoothService> services = await _connectedDevice!.device!.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid == elevatorServiceUuid) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid == commandCharacteristicUuid) {
              final data = utf8.encode(command);
              await characteristic.write(data);
              return;
            }
          }
        }
      }
      throw Exception('Elevator service or characteristic not found');
    } catch (e) {
      throw Exception('Failed to send command: $e');
    }
  }

  Future<String?> readStatus() async {
    if (!_isConnected || _connectedDevice?.device == null) {
      return null;
    }

    try {
      List<BluetoothService> services = await _connectedDevice!.device!.discoverServices();

      for (BluetoothService service in services) {
        if (service.uuid == elevatorServiceUuid) {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            if (characteristic.uuid == statusCharacteristicUuid) {
              final data = await characteristic.read();
              return utf8.decode(data);
            }
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    stopScan();
    disconnect();
    super.dispose();
  }
}
