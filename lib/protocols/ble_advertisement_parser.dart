import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../constants/ble_uuids.dart';
import '../models/ble_device.dart';

/// BLE 광고 데이터 파서
///
/// 엘리베이터 BLE 기기의 광고 데이터를 파싱하여 정보를 추출합니다.

class BleAdvertisementParser {
  BleAdvertisementParser._();

  /// 광고 데이터에서 제조사 ID 추출
  static int? extractManufacturerId(AdvertisementData advertisementData) {
    try {
      final manufacturerData = advertisementData.manufacturerData;
      if (manufacturerData.isEmpty) return null;

      // 첫 번째 제조사 ID 반환
      return manufacturerData.keys.first;
    } catch (e) {
      return null;
    }
  }

  /// 광고 데이터에서 엘리베이터 정보 추출
  static ElevatorAdvertisement? parseElevatorAdvertisement(
    BluetoothDevice device,
    AdvertisementData advertisementData,
  ) {
    try {
      final manufacturerId = extractManufacturerId(advertisementData);
      if (manufacturerId == null) return null;

      // 제조사 ID가 알려진 엘리베이터 제조사인지 확인
      final isKnownManufacturer = _isElevatorManufacturer(manufacturerId);

      // 서비스 UUID 확인
      final serviceUuids = advertisementData.serviceUuids;
      final hasElevatorService = serviceUuids.any(
        (uuid) => BleUuids.isElevatorService(Guid(uuid)),
      );

      // 알려진 제조사이거나 엘리베이터 서비스 UUID가 있으면 처리
      if (!isKnownManufacturer && !hasElevatorService) return null;

      // 제조사 데이터 파싱
      final manufacturerData = advertisementData.manufacturerData[manufacturerId];
      if (manufacturerData == null || manufacturerData.isEmpty) {
        // 기본 정보만 반환
        return ElevatorAdvertisement(
          deviceId: device.remoteId.str,
          deviceName: advertisementData.advName.isNotEmpty
              ? advertisementData.advName
              : device.platformName,
          manufacturerId: manufacturerId,
          rssi: advertisementData.rssi,
          isConnectable: advertisementData.connectable,
          txPowerLevel: advertisementData.txPowerLevel,
        );
      }

      // 제조사별 파서 선택
      return _parseManufacturerSpecificData(
        device: device,
        advertisementData: advertisementData,
        manufacturerId: manufacturerId,
        data: manufacturerData,
      );
    } catch (e) {
      print('Error parsing advertisement: $e');
      return null;
    }
  }

  /// 제조사별 데이터 파싱
  static ElevatorAdvertisement? _parseManufacturerSpecificData({
    required BluetoothDevice device,
    required AdvertisementData advertisementData,
    required int manufacturerId,
    required List<int> data,
  }) {
    switch (manufacturerId) {
      case BleUuids.manufacturerIdOtis:
        return _parseOtisData(device, advertisementData, manufacturerId, data);
      case BleUuids.manufacturerIdSchindler:
        return _parseSchindlerData(device, advertisementData, manufacturerId, data);
      case BleUuids.manufacturerIdKone:
        return _parseKoneData(device, advertisementData, manufacturerId, data);
      case BleUuids.manufacturerIdThyssenkrupp:
        return _parseThyssenkruppData(device, advertisementData, manufacturerId, data);
      default:
        return _parseGenericData(device, advertisementData, manufacturerId, data);
    }
  }

  /// Otis 엘리베이터 데이터 파싱
  static ElevatorAdvertisement _parseOtisData(
    BluetoothDevice device,
    AdvertisementData advertisementData,
    int manufacturerId,
    List<int> data,
  ) {
    // Otis 광고 데이터 포맷 (예시)
    // [0-1] = 제조사 ID (0x0001)
    // [2] = 프로토콜 버전
    // [3-6] = 엘리베이터 ID (4바이트)
    // [7] = 현재 층
    // [8] = 상태 플래그

    String? elevatorId;
    int? currentFloor;
    ElevatorAdvertisementStatus? status;

    if (data.length >= 9) {
      elevatorId = 'OTIS_${data[3].toRadixString(16).padLeft(2, '0')}'
          '${data[4].toRadixString(16).padLeft(2, '0')}'
          '${data[5].toRadixString(16).padLeft(2, '0')}'
          '${data[6].toRadixString(16).padLeft(2, '0')}';
      currentFloor = data[7] > 127 ? data[7] - 256 : data[7]; // 부호 있는 8비트
      status = _parseStatusFlags(data[8]);
    }

    return ElevatorAdvertisement(
      deviceId: device.remoteId.str,
      deviceName: advertisementData.advName.isNotEmpty
          ? advertisementData.advName
          : device.platformName,
      manufacturerId: manufacturerId,
      manufacturerName: 'Otis',
      elevatorId: elevatorId,
      currentFloor: currentFloor,
      status: status,
      rssi: advertisementData.rssi,
      isConnectable: advertisementData.connectable,
      txPowerLevel: advertisementData.txPowerLevel,
    );
  }

  /// Schindler 엘리베이터 데이터 파싱
  static ElevatorAdvertisement _parseSchindlerData(
    BluetoothDevice device,
    AdvertisementData advertisementData,
    int manufacturerId,
    List<int> data,
  ) {
    // Schindler 광고 데이터 포맷 (예시)
    String? elevatorId;
    int? currentFloor;

    if (data.length >= 8) {
      elevatorId = 'SCHINDLER_${data.sublist(2, 6).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
      currentFloor = data[6] > 127 ? data[6] - 256 : data[6];
    }

    return ElevatorAdvertisement(
      deviceId: device.remoteId.str,
      deviceName: advertisementData.advName.isNotEmpty
          ? advertisementData.advName
          : device.platformName,
      manufacturerId: manufacturerId,
      manufacturerName: 'Schindler',
      elevatorId: elevatorId,
      currentFloor: currentFloor,
      rssi: advertisementData.rssi,
      isConnectable: advertisementData.connectable,
      txPowerLevel: advertisementData.txPowerLevel,
    );
  }

  /// KONE 엘리베이터 데이터 파싱
  static ElevatorAdvertisement _parseKoneData(
    BluetoothDevice device,
    AdvertisementData advertisementData,
    int manufacturerId,
    List<int> data,
  ) {
    String? elevatorId;
    int? currentFloor;

    if (data.length >= 8) {
      elevatorId = 'KONE_${data.sublist(2, 6).map((b) => b.toString().padLeft(3, '0')).join()}';
      currentFloor = data[6] > 127 ? data[6] - 256 : data[6];
    }

    return ElevatorAdvertisement(
      deviceId: device.remoteId.str,
      deviceName: advertisementData.advName.isNotEmpty
          ? advertisementData.advName
          : device.platformName,
      manufacturerId: manufacturerId,
      manufacturerName: 'KONE',
      elevatorId: elevatorId,
      currentFloor: currentFloor,
      rssi: advertisementData.rssi,
      isConnectable: advertisementData.connectable,
      txPowerLevel: advertisementData.txPowerLevel,
    );
  }

  /// Thyssenkrupp 엘리베이터 데이터 파싱
  static ElevatorAdvertisement _parseThyssenkruppData(
    BluetoothDevice device,
    AdvertisementData advertisementData,
    int manufacturerId,
    List<int> data,
  ) {
    String? elevatorId;
    int? currentFloor;

    if (data.length >= 8) {
      elevatorId = 'TK_${String.fromCharCodes(data.sublist(2, 8)).trim()}';
      currentFloor = data.length > 8 ? (data[8] > 127 ? data[8] - 256 : data[8]) : null;
    }

    return ElevatorAdvertisement(
      deviceId: device.remoteId.str,
      deviceName: advertisementData.advName.isNotEmpty
          ? advertisementData.advName
          : device.platformName,
      manufacturerId: manufacturerId,
      manufacturerName: 'Thyssenkrupp',
      elevatorId: elevatorId,
      currentFloor: currentFloor,
      rssi: advertisementData.rssi,
      isConnectable: advertisementData.connectable,
      txPowerLevel: advertisementData.txPowerLevel,
    );
  }

  /// Generic 엘리베이터 데이터 파싱
  static ElevatorAdvertisement _parseGenericData(
    BluetoothDevice device,
    AdvertisementData advertisementData,
    int manufacturerId,
    List<int> data,
  ) {
    // 기본 파싱 - 데이터에서 가능한 정보 추출
    String? elevatorId;

    if (data.length >= 6) {
      elevatorId = 'ELV_${data.sublist(0, 6).map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
    }

    return ElevatorAdvertisement(
      deviceId: device.remoteId.str,
      deviceName: advertisementData.advName.isNotEmpty
          ? advertisementData.advName
          : device.platformName,
      manufacturerId: manufacturerId,
      manufacturerName: 'Generic',
      elevatorId: elevatorId,
      rssi: advertisementData.rssi,
      isConnectable: advertisementData.connectable,
      txPowerLevel: advertisementData.txPowerLevel,
    );
  }

  /// 상태 플래그 파싱
  static ElevatorAdvertisementStatus _parseStatusFlags(int flags) {
    return ElevatorAdvertisementStatus(
      isMoving: (flags & 0x01) != 0,
      isDoorOpen: (flags & 0x02) != 0,
      isAvailable: (flags & 0x04) != 0,
      hasError: (flags & 0x08) != 0,
    );
  }

  /// 알려진 엘리베이터 제조사인지 확인
  static bool _isElevatorManufacturer(int manufacturerId) {
    return manufacturerId == BleUuids.manufacturerIdOtis ||
           manufacturerId == BleUuids.manufacturerIdSchindler ||
           manufacturerId == BleUuids.manufacturerIdKone ||
           manufacturerId == BleUuids.manufacturerIdThyssenkrupp ||
           manufacturerId == BleUuids.manufacturerIdGeneric;
  }

  /// 신호 강도를 품질 레벨로 변환
  static SignalQuality rssiToQuality(int? rssi) {
    if (rssi == null) return SignalQuality.unknown;
    if (rssi >= -50) return SignalQuality.excellent;
    if (rssi >= -60) return SignalQuality.good;
    if (rssi >= -70) return SignalQuality.fair;
    if (rssi >= -80) return SignalQuality.poor;
    return SignalQuality.weak;
  }
}

/// 엘리베이터 광고 데이터
class ElevatorAdvertisement {
  /// 기기 ID (MAC 주소)
  final String deviceId;

  /// 기기 이름
  final String deviceName;

  /// 제조사 ID
  final int manufacturerId;

  /// 제조사 이름
  final String? manufacturerName;

  /// 엘리베이터 ID
  final String? elevatorId;

  /// 현재 층 (광고 데이터에 포함된 경우)
  final int? currentFloor;

  /// 상태 플래그
  final ElevatorAdvertisementStatus? status;

  /// RSSI (신호 강도)
  final int? rssi;

  /// 연결 가능 여부
  final bool isConnectable;

  /// TX Power Level
  final int? txPowerLevel;

  const ElevatorAdvertisement({
    required this.deviceId,
    required this.deviceName,
    required this.manufacturerId,
    this.manufacturerName,
    this.elevatorId,
    this.currentFloor,
    this.status,
    this.rssi,
    this.isConnectable = true,
    this.txPowerLevel,
  });

  /// 신호 품질
  SignalQuality get signalQuality => BleAdvertisementParser.rssiToQuality(rssi);

  /// 사용자에게 표시할 이름
  String get displayName {
    if (deviceName.isNotEmpty && deviceName != 'Unknown') {
      return deviceName;
    }
    if (elevatorId != null) {
      return 'Elevator $elevatorId';
    }
    return 'Elevator ${deviceId.substring(deviceId.length - 4)}';
  }

  @override
  String toString() {
    return 'ElevatorAdvertisement(id: $deviceId, name: $deviceName, rssi: $rssi)';
  }
}

/// 엘리베이터 광고 상태
class ElevatorAdvertisementStatus {
  /// 이동 중인지
  final bool isMoving;

  /// 문이 열려있는지
  final bool isDoorOpen;

  /// 사용 가능한지
  final bool isAvailable;

  /// 에러 상태인지
  final bool hasError;

  const ElevatorAdvertisementStatus({
    this.isMoving = false,
    this.isDoorOpen = false,
    this.isAvailable = true,
    this.hasError = false,
  });
}

/// 신호 품질 레벨
enum SignalQuality {
  unknown('알 수 없음', Icons.signal_wifi_statusbar_null),
  excellent('매우 좋음', Icons.signal_wifi_4_bar),
  good('좋음', Icons.signal_wifi_3_bar),
  fair('보통', Icons.signal_wifi_2_bar),
  poor('약함', Icons.signal_wifi_1_bar),
  weak('매우 약함', Icons.signal_wifi_0_bar);

  final String label;
  final IconData icon;

  const SignalQuality(this.label, this.icon);
}

// IconData import 필요 - 실제 구현시 추가
class Icons {
  static const signal_wifi_statusbar_null = null;
  static const signal_wifi_4_bar = null;
  static const signal_wifi_3_bar = null;
  static const signal_wifi_2_bar = null;
  static const signal_wifi_1_bar = null;
  static const signal_wifi_0_bar = null;
}
