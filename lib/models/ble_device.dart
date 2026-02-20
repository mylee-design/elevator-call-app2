import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleDevice {
  final String id;
  final String? name;
  final int rssi;
  final List<String> serviceUuids;
  final BluetoothDevice? device;
  final DateTime discoveredAt;

  BleDevice({
    required this.id,
    this.name,
    required this.rssi,
    this.serviceUuids = const [],
    this.device,
    DateTime? discoveredAt,
  }) : discoveredAt = discoveredAt ?? DateTime.now();

  factory BleDevice.fromScanResult(ScanResult result) {
    return BleDevice(
      id: result.device.remoteId.toString(),
      name: result.device.platformName.isNotEmpty
          ? result.device.platformName
          : result.advertisementData.localName,
      rssi: result.rssi,
      serviceUuids: result.advertisementData.serviceUuids
          .map((uuid) => uuid.toString())
          .toList(),
      device: result.device,
    );
  }

  String get displayName => name ?? 'Unknown Device';

  String get signalStrength {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Good';
    if (rssi >= -70) return 'Fair';
    if (rssi >= -80) return 'Weak';
    return 'Poor';
  }

  int get signalBars {
    if (rssi >= -50) return 4;
    if (rssi >= -60) return 3;
    if (rssi >= -70) return 2;
    if (rssi >= -80) return 1;
    return 0;
  }

  @override
  String toString() {
    return 'BleDevice(id: $id, name: $name, rssi: $rssi)';
  }
}
