# 엘리베이터 호출 앱 (Elevator Call App)

Flutter 기반 엘리베이터 호출 앱 POC (Proof of Concept)

## 기능

- **QR 코드 스캔**: 엘리베이터 식별용 QR 코드 스캔
- **BLE 통신**: 블루투스로 엘리베이터와 통신
- **층 선택**: -3층 ~ 30층 층 선택 지원
- **Mock 모드**: 실제 기기 없이 테스트 가능

## 화면 흐름

```
HomeScreen → QRScanScreen → BleDevicesScreen → FloorSelectionScreen → CallScreen
```

## 기술 스택

- **Framework**: Flutter 3.24+
- **QR Scanning**: mobile_scanner
- **BLE Communication**: flutter_blue_plus
- **State Management**: Provider
- **Permissions**: permission_handler

## 프로젝트 구조

```
lib/
├── main.dart                      # 앱 진입점
├── theme.dart                     # 앱 테마 설정
├── models/
│   ├── elevator_info.dart         # 엘리베이터 정보 모델
│   └── ble_device.dart            # BLE 기기 모델
├── screens/
│   ├── home_screen.dart           # 홈 화면
│   ├── qr_scan_screen.dart        # QR 스캔 화면
│   ├── ble_devices_screen.dart    # BLE 기기 목록 화면
│   ├── floor_selection_screen.dart # 층 선택 화면
│   └── call_screen.dart           # 호출 화면
└── services/
    ├── ble_service.dart           # BLE 서비스
    └── mock_ble_service.dart      # Mock BLE 서비스 (테스트용)
```

## 설치 및 실행

### 1. Flutter 설치

```bash
# Flutter SDK 설치 (https://docs.flutter.dev/get-started/install)
flutter doctor
```

### 2. 프로젝트 클론 및 의존성 설치

```bash
cd elevator_call_app
flutter pub get
```

### 3. Android 설정

`android/app/src/main/AndroidManifest.xml`에 다음 권한이 포함되어 있는지 확인:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Android 12+ (API 31+)에서는 런타임 권한 요청이 필요합니다.

### 4. iOS 설정

`ios/Runner/Info.plist`에 다음 권한 설명이 포함되어 있는지 확인:

```xml
<key>NSCameraUsageDescription</key>
<string>QR 코드를 스캔하여 엘리베이터를 식별하기 위해 칩라 접근이 필요합니다.</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>엘리베이터와 BLE 통신을 위해 블루투스 접근이 필요합니다.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>주변 BLE 기기를 검색하기 위해 위치 접근이 필요합니다.</string>
```

### 5. 앱 실행

```bash
# Android
flutter run

# iOS (Mac 필요)
flutter run -d ios

# 특정 기기
flutter run -d <device_id>
```

## 테스트

### Mock 모드 사용

홈 화면의 "Mock 모드로 테스트" 버튼을 클릭하여 실제 BLE 기기 없이 테스트할 수 있습니다.

### QR 코드 테스트

다음 형식의 QR 코드를 생성하여 테스트:

```json
{"elevator_id": "ELV001", "floor": "1"}
```

또는 단순 문자열:
```
ELV001:1
```

## 빌드

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 알려진 이슈

1. **iOS 백그라운드 BLE 스캔**: iOS는 백그라운드에서 BLE 스캔에 제한이 있습니다.
2. **Android 12+ 권한**: BLUETOOTH_SCAN, BLUETOOTH_CONNECT 권한이 별도로 필요합니다.
3. **위치 권한**: Android 11 이하에서는 BLE 스캔을 위해 위치 권한이 필요합니다.

## 라이선스

MIT License
