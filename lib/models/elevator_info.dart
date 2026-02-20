class ElevatorInfo {
  final String elevatorId;
  final String floor;
  final String? buildingName;
  final DateTime scannedAt;

  ElevatorInfo({
    required this.elevatorId,
    required this.floor,
    this.buildingName,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now();

  factory ElevatorInfo.fromQRData(String qrData) {
    try {
      // QR 데이터가 JSON 형식인 경우 파싱
      if (qrData.startsWith('{') && qrData.endsWith('}')) {
        final Map<String, dynamic> data = _parseJson(qrData);
        return ElevatorInfo(
          elevatorId: data['elevator_id']?.toString() ?? data['id']?.toString() ?? 'UNKNOWN',
          floor: data['floor']?.toString() ?? '1',
          buildingName: data['building_name']?.toString(),
        );
      }
      // 단순 문자열 형식 (예: "ELV001:1")
      else if (qrData.contains(':')) {
        final parts = qrData.split(':');
        return ElevatorInfo(
          elevatorId: parts[0],
          floor: parts.length > 1 ? parts[1] : '1',
        );
      }
      // 기본값
      else {
        return ElevatorInfo(
          elevatorId: qrData,
          floor: '1',
        );
      }
    } catch (e) {
      return ElevatorInfo(
        elevatorId: 'ERROR',
        floor: '1',
      );
    }
  }

  static Map<String, dynamic> _parseJson(String jsonStr) {
    // 간단한 JSON 파싱 (실제 구현에서는 dart:convert 사용)
    final Map<String, dynamic> result = {};
    final cleanStr = jsonStr.substring(1, jsonStr.length - 1);
    final pairs = cleanStr.split(',');
    for (var pair in pairs) {
      final keyValue = pair.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim().replaceAll('"', '').replaceAll("'", '');
        final value = keyValue[1].trim().replaceAll('"', '').replaceAll("'", '');
        result[key] = value;
      }
    }
    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'elevator_id': elevatorId,
      'floor': floor,
      'building_name': buildingName,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ElevatorInfo(elevatorId: $elevatorId, floor: $floor, buildingName: $buildingName)';
  }
}
