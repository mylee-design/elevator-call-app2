import 'package:flutter/material.dart';

/// 접근성 라벨 상수
/// Screen reader 지원을 위한 시맨틱 라벨
class SemanticLabels {
  SemanticLabels._();

  // ====================
  // Home Screen
  // ====================
  static const String homeScreen = '홈 화면';
  static const String appLogo = '엘리베이터 호출 앱 로고';
  static const String scanQrButton = 'QR 코드 스캔 버튼, 엘리베이터를 스캔하여 호출합니다';
  static const String mockModeButton = 'Mock 모드로 테스트 버튼, 테스트용 모드로 전환합니다';
  static const String permissionInfo = '블루투스와 칩라 권한이 필요합니다';

  // ====================
  // QR Scan Screen
  // ====================
  static const String qrScanScreen = 'QR 코드 스캔 화면';
  static const String qrScanner = 'QR 코드 스캔 영역, 엘리베이터 QR 코드를 프레임 안에 맞춰주세요';
  static const String flashToggle = '플래시 토글 버튼';
  static const String zoomControl = '줌 컨트롤';
  static const String scanGuide = '엘리베이터 QR 코드를 스캔하세요';
  static const String scanResultDialog = 'QR 코드 인식 결과';
  static const String rescanButton = '다시 스캔 버튼';
  static const String continueButton = '계속 버튼';

  // ====================
  // BLE Devices Screen
  // ====================
  static const String bleDevicesScreen = 'BLE 기기 선택 화면';
  static const String deviceList = 'BLE 기기 목록';
  static const String scanButton = '기기 검색 버튼';
  static const String connectButton = '연결 버튼';
  static const String disconnectButton = '연결 해제 버튼';
  static const String deviceSignalStrength = '기기 신호 강도';
  static const String scannedElevatorInfo = '스캔된 엘리베이터 정보';
  static const String noDevicesFound = '기기를 찾을 수 없습니다';
  static const String scanningInProgress = 'BLE 기기 검색 중';

  // ====================
  // Floor Selection Screen
  // ====================
  static const String floorSelectionScreen = '층 선택 화면';
  static const String floorGrid = '층 선택 그리드';
  static const String floorButton = '층 버튼';
  static const String currentFloor = '현재 위치 층';
  static const String selectedFloor = '선택된 층';
  static const String confirmButton = '엘리베이터 호출 확인 버튼';
  static const String connectedDevice = '연결된 기기';

  // ====================
  // Call Screen
  // ====================
  static const String callScreen = '엘리베이터 호출 화면';
  static const String callStatus = '호출 상태';
  static const String callInProgress = '엘리베이터 호출 중';
  static const String elevatorMoving = '엘리베이터가 이동 중입니다';
  static const String elevatorArrived = '엘리베이터가 도착했습니다';
  static const String callFailed = '호출에 실패했습니다';
  static const String estimatedTime = '예상 도착 시간';
  static const String completeButton = '완료 버튼';
  static const String retryButton = '다시 시도 버튼';
  static const String elevatorInfo = '엘리베이터 정보';
  static const String targetFloor = '목적지 층';

  // ====================
  // General
  // ====================
  static const String loading = '로딩 중';
  static const String error = '오류 발생';
  static const String success = '성공';
  static const String cancel = '취소';
  static const String close = '닫기';
  static const String back = '뒤로 가기';
  static const String settings = '설정으로 이동';
  static const String permissionRequired = '권한 필요';
}

/// 접근성 헬퍼 위젯
class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget child;
  final bool excludeSemantics;

  const AccessibleButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.child,
    this.excludeSemantics = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: excludeSemantics,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// 접근성 카드 위젯
class AccessibleCard extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Widget child;
  final bool selected;

  const AccessibleCard({
    super.key,
    required this.label,
    this.onTap,
    required this.child,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: label,
      selected: selected,
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: child,
      ),
    );
  }
}

/// 접근성 입력 필드 위젯
class AccessibleTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? error;
  final Widget child;

  const AccessibleTextField({
    super.key,
    required this.label,
    this.hint,
    this.error,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: label,
      hint: hint,
      value: error,
      child: child,
    );
  }
}

/// 접근성 로딩 인디케이터
class AccessibleLoading extends StatelessWidget {
  final String label;
  final Widget child;

  const AccessibleLoading({
    super.key,
    this.label = SemanticLabels.loading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: child,
      ),
    );
  }
}

/// 접근성 에러 메시지
class AccessibleError extends StatelessWidget {
  final String message;
  final Widget child;

  const AccessibleError({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${SemanticLabels.error}: $message',
      liveRegion: true,
      child: child,
    );
  }
}

/// 접근성 성공 메시지
class AccessibleSuccess extends StatelessWidget {
  final String message;
  final Widget child;

  const AccessibleSuccess({
    super.key,
    required this.message,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${SemanticLabels.success}: $message',
      liveRegion: true,
      child: child,
    );
  }
}

/// 접근성 리스트 위젯
class AccessibleList extends StatelessWidget {
  final String label;
  final int itemCount;
  final Widget child;

  const AccessibleList({
    super.key,
    required this.label,
    required this.itemCount,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$label, $itemCount개 항목',
      child: child,
    );
  }
}

/// 접근성 상태 표시 위젯
class AccessibleStatus extends StatelessWidget {
  final String status;
  final Widget child;
  final bool liveRegion;

  const AccessibleStatus({
    super.key,
    required this.status,
    required this.child,
    this.liveRegion = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${SemanticLabels.callStatus}: $status',
      liveRegion: liveRegion,
      child: child,
    );
  }
}

/// 접근성 확장
extension SemanticsExtension on Widget {
  /// 버튼 시맨틱 추가
  Widget asButton(String label, {VoidCallback? onTap}) {
    return Semantics(
      button: true,
      label: label,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              child: this,
            )
          : this,
    );
  }

  /// 헤더 시맨틱 추가
  Widget asHeader(String label) {
    return Semantics(
      header: true,
      label: label,
      child: this,
    );
  }

  /// 이미지 시맨틱 추가
  Widget asImage(String label) {
    return Semantics(
      image: true,
      label: label,
      child: this,
    );
  }

  /// 라이브 리전 설정
  Widget asLiveRegion({bool assertive = false}) {
    return Semantics(
      liveRegion: true,
      child: this,
    );
  }

  /// 선택 상태 시맨틱
  Widget asSelected(bool selected, String label) {
    return Semantics(
      selected: selected,
      label: label,
      child: this,
    );
  }
}
