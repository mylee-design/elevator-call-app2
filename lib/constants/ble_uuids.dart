import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE UUID Constants for Elevator Communication
///
/// 이 파일은 엘리베이터 BLE 통신에 사용되는 서비스 및 특성 UUID를 정의합니다.
/// 제조사별로 다른 UUID를 사용할 수 있으므로, Generic UUID와 제조사별 UUID를 모두 정의합니다.

class BleUuids {
  BleUuids._();

  // ====================
  // Generic Elevator Service (표준 엘리베이터 서비스)
  // ====================

  /// 메인 엘리베이터 제어 서비스 UUID
  static final Guid elevatorServiceUuid = Guid("0000ELEV-0000-1000-8000-00805F9B34FB");

  /// 엘리베이터 상태 서비스 UUID
  static final Guid elevatorStatusServiceUuid = Guid("0000ESTS-0000-1000-8000-00805F9B34FB");

  /// 인증 서비스 UUID
  static final Guid authServiceUuid = Guid("0000AUTH-0000-1000-8000-00805F9B34FB");

  // ====================
  // Characteristics - Command (명령)
  // ====================

  /// 층 호출 명령 특성 (Write)
  static final Guid floorCallCharacteristic = Guid("0000FCAL-0000-1000-8000-00805F9B34FB");

  /// 문 제어 명령 특성 (Write)
  static final Guid doorControlCharacteristic = Guid("0000DOOR-0000-1000-8000-00805F9B34FB");

  /// 비상 정지 명령 특성 (Write)
  static final Guid emergencyStopCharacteristic = Guid("0000EMST-0000-1000-8000-00805F9B34FB");

  // ====================
  // Characteristics - Status (상태)
  // ====================

  /// 현재 층 상태 특성 (Read/Notify)
  static final Guid currentFloorCharacteristic = Guid("0000FSTA-0000-1000-8000-00805F9B34FB");

  /// 엘리베이터 방향 특성 (Read/Notify)
  static final Guid directionCharacteristic = Guid("0000DIRC-0000-1000-8000-00805F9B34FB");

  /// 문 상태 특성 (Read/Notify)
  static final Guid doorStatusCharacteristic = Guid("0000DSTT-0000-1000-8000-00805F9B34FB");

  /// 운행 상태 특성 (Read/Notify)
  static final Guid operationStatusCharacteristic = Guid("0000OPST-0000-1000-8000-00805F9B34FB");

  // ====================
  // Characteristics - Authentication (인증)
  // ====================

  /// 인증 요청 특성 (Write)
  static final Guid authRequestCharacteristic = Guid("0000AREQ-0000-1000-8000-00805F9B34FB");

  /// 인증 응답 특성 (Read/Notify)
  static final Guid authResponseCharacteristic = Guid("0000ARES-0000-1000-8000-00805F9B34FB");

  /// 세션 토큰 특성 (Read/Write)
  static final Guid sessionTokenCharacteristic = Guid("0000SESS-0000-1000-8000-00805F9B34FB");

  // ====================
  // Characteristics - Configuration (설정)
  // ====================

  /// 엘리베이터 정보 특성 (Read)
  static final Guid elevatorInfoCharacteristic = Guid("0000EINF-0000-1000-8000-00805F9B34FB");

  /// 최대 층 정보 특성 (Read)
  static final Guid maxFloorCharacteristic = Guid("0000MXFL-0000-1000-8000-00805F9B34FB");

  /// 최소 층 정보 특성 (Read)
  static final Guid minFloorCharacteristic = Guid("0000MNFL-0000-1000-8000-00805F9B34FB");

  // ====================
  // Manufacturer Specific UUIDs (제조사별 UUID)
  // ====================

  /// Otis Elevator Service
  static final Guid otisServiceUuid = Guid("OTIS0001-0000-1000-8000-00805F9B34FB");

  /// Schindler Elevator Service
  static final Guid schindlerServiceUuid = Guid("SCHN0001-0000-1000-8000-00805F9B34FB");

  /// KONE Elevator Service
  static final Guid koneServiceUuid = Guid("KONE0001-0000-1000-8000-00805F9B34FB");

  /// Thyssenkrupp Elevator Service
  static final Guid tkElevatorServiceUuid = Guid("TKEL0001-0000-1000-8000-00805F9B34FB");

  // ====================
  // BLE Advertisement Data (광고 데이터)
  // ====================

  /// 제조사 ID - Generic Elevator
  static const int manufacturerIdGeneric = 0xFFFF;

  /// 제조사 ID - Otis
  static const int manufacturerIdOtis = 0x0001;

  /// 제조사 ID - Schindler
  static const int manufacturerIdSchindler = 0x0002;

  /// 제조사 ID - KONE
  static const int manufacturerIdKone = 0x0003;

  /// 제조사 ID - Thyssenkrupp
  static const int manufacturerIdThyssenkrupp = 0x0004;

  // ====================
  // Helper Methods
  // ====================

  /// 제조사 ID로부터 서비스 UUID 반환
  static Guid getServiceUuidByManufacturer(int manufacturerId) {
    switch (manufacturerId) {
      case manufacturerIdOtis:
        return otisServiceUuid;
      case manufacturerIdSchindler:
        return schindlerServiceUuid;
      case manufacturerIdKone:
        return koneServiceUuid;
      case manufacturerIdThyssenkrupp:
        return tkElevatorServiceUuid;
      default:
        return elevatorServiceUuid;
    }
  }

  /// UUID가 엘리베이터 서비스인지 확인
  static bool isElevatorService(Guid uuid) {
    return uuid == elevatorServiceUuid ||
           uuid == otisServiceUuid ||
           uuid == schindlerServiceUuid ||
           uuid == koneServiceUuid ||
           uuid == tkElevatorServiceUuid;
  }

  /// UUID가 명령 특성인지 확인
  static bool isCommandCharacteristic(Guid uuid) {
    return uuid == floorCallCharacteristic ||
           uuid == doorControlCharacteristic ||
           uuid == emergencyStopCharacteristic;
  }

  /// UUID가 상태 특성인지 확인
  static bool isStatusCharacteristic(Guid uuid) {
    return uuid == currentFloorCharacteristic ||
           uuid == directionCharacteristic ||
           uuid == doorStatusCharacteristic ||
           uuid == operationStatusCharacteristic;
  }
}

/// BLE 통신 설정
class BleConfig {
  BleConfig._();

  /// 스캔 타임아웃 (초)
  static const Duration scanTimeout = Duration(seconds: 10);

  /// 연결 타임아웃 (초)
  static const Duration connectionTimeout = Duration(seconds: 10);

  /// 명령 응답 타임아웃 (초)
  static const Duration commandTimeout = Duration(seconds: 5);

  /// 인증 타임아웃 (초)
  static const Duration authTimeout = Duration(seconds: 10);

  /// MTU 크기
  static const int mtuSize = 517;

  /// 재연결 시도 횟수
  static const int maxReconnectAttempts = 3;

  /// 재연결 지연 시간
  static const Duration reconnectDelay = Duration(seconds: 2);
}
