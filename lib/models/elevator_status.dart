import 'dart:convert';
import 'dart:typed_data';

/// 엘리베이터 상태 모델
///
/// BLE를 통해 수신된 엘리베이터 상태를 정의합니다.

class ElevatorStatus {
  /// 현재 층
  final int currentFloor;

  /// 목표 층
  final int? targetFloor;

  /// 운행 방향
  final ElevatorDirection direction;

  /// 문 상태
  final DoorStatus doorStatus;

  /// 운행 상태
  final OperationStatus operationStatus;

  /// 현재 속도 (m/s)
  final double? speed;

  /// 하중 (%)
  final int? loadPercentage;

  /// 타임스탬프
  final DateTime timestamp;

  /// 상태 메시지
  final String? message;

  /// 에러 코드
  final String? errorCode;

  const ElevatorStatus({
    required this.currentFloor,
    this.targetFloor,
    this.direction = ElevatorDirection.stopped,
    this.doorStatus = DoorStatus.closed,
    this.operationStatus = OperationStatus.idle,
    this.speed,
    this.loadPercentage,
    this.message,
    this.errorCode,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// JSON에서 상태 객체 생성
  factory ElevatorStatus.fromJson(String json) {
    final data = jsonDecode(json);
    return ElevatorStatus(
      currentFloor: data['current_floor'],
      targetFloor: data['target_floor'],
      direction: ElevatorDirection.fromString(data['direction']),
      doorStatus: DoorStatus.fromString(data['door_status']),
      operationStatus: OperationStatus.fromString(data['operation_status']),
      speed: data['speed']?.toDouble(),
      loadPercentage: data['load_percentage'],
      message: data['message'],
      errorCode: data['error_code'],
      timestamp: data['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'])
          : DateTime.now(),
    );
  }

  /// 바이너리 데이터에서 상태 객체 생성
  factory ElevatorStatus.fromBinary(Uint8List bytes) {
    if (bytes.length < 6) {
      throw FormatException('Invalid binary data length');
    }

    final byteData = ByteData.sublistView(bytes);

    return ElevatorStatus(
      currentFloor: byteData.getInt8(0),
      targetFloor: byteData.getInt8(1) == -127 ? null : byteData.getInt8(1),
      direction: ElevatorDirection.fromValue(bytes[2]),
      doorStatus: DoorStatus.fromValue(bytes[3]),
      operationStatus: OperationStatus.fromValue(bytes[4]),
      loadPercentage: bytes[5] <= 100 ? bytes[5] : null,
      timestamp: DateTime.now(),
    );
  }

  /// JSON 문자열로 변환
  String toJson() {
    return jsonEncode({
      'current_floor': currentFloor,
      'target_floor': targetFloor,
      'direction': direction.value,
      'door_status': doorStatus.value,
      'operation_status': operationStatus.value,
      'speed': speed,
      'load_percentage': loadPercentage,
      'message': message,
      'error_code': errorCode,
      'timestamp': timestamp.millisecondsSinceEpoch,
    });
  }

  /// 바이너리 데이터로 변환
  Uint8List toBinary() {
    final byteData = ByteData(8);
    byteData.setInt8(0, currentFloor);
    byteData.setInt8(1, targetFloor ?? -127);
    byteData.setUint8(2, direction.value);
    byteData.setUint8(3, doorStatus.value);
    byteData.setUint8(4, operationStatus.value);
    byteData.setUint8(5, loadPercentage ?? 255);
    byteData.setUint16(6, 0); // reserved
    return Uint8List.view(byteData.buffer);
  }

  /// 상태 복사 (불변성 유지)
  ElevatorStatus copyWith({
    int? currentFloor,
    int? targetFloor,
    ElevatorDirection? direction,
    DoorStatus? doorStatus,
    OperationStatus? operationStatus,
    double? speed,
    int? loadPercentage,
    String? message,
    String? errorCode,
    DateTime? timestamp,
  }) {
    return ElevatorStatus(
      currentFloor: currentFloor ?? this.currentFloor,
      targetFloor: targetFloor ?? this.targetFloor,
      direction: direction ?? this.direction,
      doorStatus: doorStatus ?? this.doorStatus,
      operationStatus: operationStatus ?? this.operationStatus,
      speed: speed ?? this.speed,
      loadPercentage: loadPercentage ?? this.loadPercentage,
      message: message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 상태가 호출 중인지 확인
  bool get isMoving => direction != ElevatorDirection.stopped;

  /// 상태가 도착했는지 확인
  bool get isArrived => direction == ElevatorDirection.stopped && doorStatus == DoorStatus.open;

  /// 에러 상태인지 확인
  bool get hasError => errorCode != null || operationStatus == OperationStatus.error;

  /// 사용자에게 표시할 상태 텍스트
  String get statusText {
    if (hasError) return '오류 발생';
    if (isArrived) return '도착';
    if (isMoving) {
      final dirText = direction == ElevatorDirection.up ? '상승' : '하강';
      return '$dirText 중 (${targetFloor}층 향해)';
    }
    return '대기 중';
  }

  @override
  String toString() {
    return 'ElevatorStatus(floor: $currentFloor, direction: ${direction.name}, door: ${doorStatus.name})';
  }
}

/// 엘리베이터 운행 방향
enum ElevatorDirection {
  stopped('stopped', 0),
  up('up', 1),
  down('down', 2);

  final String value;
  final int binaryValue;

  const ElevatorDirection(this.value, this.binaryValue);

  factory ElevatorDirection.fromString(String? value) {
    return ElevatorDirection.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ElevatorDirection.stopped,
    );
  }

  factory ElevatorDirection.fromValue(int value) {
    return ElevatorDirection.values.firstWhere(
      (e) => e.binaryValue == value,
      orElse: () => ElevatorDirection.stopped,
    );
  }
}

/// 문 상태
enum DoorStatus {
  closed('closed', 0),
  opening('opening', 1),
  open('open', 2),
  closing('closing', 3);

  final String value;
  final int binaryValue;

  const DoorStatus(this.value, this.binaryValue);

  factory DoorStatus.fromString(String? value) {
    return DoorStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DoorStatus.closed,
    );
  }

  factory DoorStatus.fromValue(int value) {
    return DoorStatus.values.firstWhere(
      (e) => e.binaryValue == value,
      orElse: () => DoorStatus.closed,
    );
  }

  /// 문이 열림/닫힘 중인지 확인
  bool get isTransitioning => this == DoorStatus.opening || this == DoorStatus.closing;
}

/// 운행 상태
enum OperationStatus {
  idle('idle', 0),
  running('running', 1),
  stopped('stopped', 2),
  maintenance('maintenance', 3),
  emergency('emergency', 4),
  error('error', 5);

  final String value;
  final int binaryValue;

  const OperationStatus(this.value, this.binaryValue);

  factory OperationStatus.fromString(String? value) {
    return OperationStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OperationStatus.idle,
    );
  }

  factory OperationStatus.fromValue(int value) {
    return OperationStatus.values.firstWhere(
      (e) => e.binaryValue == value,
      orElse: () => OperationStatus.idle,
    );
  }

  /// 정상 운행 가능한 상태인지 확인
  bool get isOperational => this == OperationStatus.idle || this == OperationStatus.running;
}

/// 엘리베이터 정보
class ElevatorInfo {
  /// 엘리베이터 ID
  final String elevatorId;

  /// 엘리베이터 이름
  final String? name;

  /// 건물 이름
  final String? buildingName;

  /// 최소 층
  final int minFloor;

  /// 최대 층
  final int maxFloor;

  /// 지상 층 수
  final int aboveGroundFloors;

  /// 지하 층 수
  final int belowGroundFloors;

  /// 제조사
  final String? manufacturer;

  /// 모델
  final String? model;

  /// 설치 일자
  final DateTime? installationDate;

  /// 최대 수용 인원
  final int? maxCapacity;

  /// 최대 하중 (kg)
  final int? maxLoadKg;

  const ElevatorInfo({
    required this.elevatorId,
    this.name,
    this.buildingName,
    this.minFloor = -3,
    this.maxFloor = 30,
    this.aboveGroundFloors = 30,
    this.belowGroundFloors = 3,
    this.manufacturer,
    this.model,
    this.installationDate,
    this.maxCapacity,
    this.maxLoadKg,
  });

  factory ElevatorInfo.fromJson(String json) {
    final data = jsonDecode(json);
    return ElevatorInfo(
      elevatorId: data['elevator_id'],
      name: data['name'],
      buildingName: data['building_name'],
      minFloor: data['min_floor'] ?? -3,
      maxFloor: data['max_floor'] ?? 30,
      aboveGroundFloors: data['above_ground_floors'] ?? 30,
      belowGroundFloors: data['below_ground_floors'] ?? 3,
      manufacturer: data['manufacturer'],
      model: data['model'],
      installationDate: data['installation_date'] != null
          ? DateTime.parse(data['installation_date'])
          : null,
      maxCapacity: data['max_capacity'],
      maxLoadKg: data['max_load_kg'],
    );
  }

  String toJson() {
    return jsonEncode({
      'elevator_id': elevatorId,
      'name': name,
      'building_name': buildingName,
      'min_floor': minFloor,
      'max_floor': maxFloor,
      'above_ground_floors': aboveGroundFloors,
      'below_ground_floors': belowGroundFloors,
      'manufacturer': manufacturer,
      'model': model,
      'installation_date': installationDate?.toIso8601String(),
      'max_capacity': maxCapacity,
      'max_load_kg': maxLoadKg,
    });
  }

  /// 유효한 층 범위 내인지 확인
  bool isValidFloor(int floor) => floor >= minFloor && floor <= maxFloor;

  /// 모든 유효한 층 목록
  List<int> get allFloors => List.generate(
    maxFloor - minFloor + 1,
    (index) => minFloor + index,
  );

  @override
  String toString() {
    return 'ElevatorInfo(id: $elevatorId, name: $name, floors: $minFloor~$maxFloor)';
  }
}
