# 엘리베이터 BLE 프로토콜 문서

## 개요

이 문서는 엘리베이터 호출 앱과 엘리베이터 제어 시스템 간의 BLE 통신 프로토콜을 정의합니다.

## 아키텍처

```
┌──────────────┐      BLE       ┌──────────────┐      CAN/Ethernet    ┌──────────────┐
│   모바일 앱   │  ═══════════▶  │  BLE 게이트웨이 │  ═══════════════▶  │  엘리베이터   │
│  (Flutter)   │  ═══════════◀  │  (라즈베리파이)  │  ═══════════════◀  │  컨트롤러    │
└──────────────┘                └──────────────┘                     └──────────────┘
```

## BLE 서비스 구조

### 1. 메인 엘리베이터 서비스 (UUID: 0000ELEV-...)

| Characteristic | UUID | 속성 | 설명 |
|---------------|------|------|------|
| Floor Call | 0000FCAL-... | Write | 층 호출 명령 |
| Door Control | 0000DOOR-... | Write | 문 제어 명령 |
| Emergency Stop | 0000EMST-... | Write | 비상 정지 |
| Current Floor | 0000FSTA-... | Read/Notify | 현재 층 |
| Direction | 0000DIRC-... | Read/Notify | 운행 방향 |
| Door Status | 0000DSTT-... | Read/Notify | 문 상태 |
| Operation Status | 0000OPST-... | Read/Notify | 운행 상태 |
| Elevator Info | 0000EINF-... | Read | 엘리베이터 정보 |

### 2. 인증 서비스 (UUID: 0000AUTH-...)

| Characteristic | UUID | 속성 | 설명 |
|---------------|------|------|------|
| Auth Request | 0000AREQ-... | Write | 인증 요청 |
| Auth Response | 0000ARES-... | Read/Notify | 인증 응답 |
| Session Token | 0000SESS-... | Read/Write | 세션 토큰 |

## 데이터 포맷

### 명령 포맷 (JSON)

```json
{
  "type": "floor_call",
  "target_floor": 5,
  "current_floor": 1,
  "priority": 5,
  "timestamp": 1708326400000,
  "request_id": "req_12345"
}
```

### 명령 포맷 (Binary)

```
[0]    = 명령 타입 (0x01=Floor Call, 0x02=Door Control, 0xFF=Emergency)
[1-2]  = 타겟 층 (int16, little-endian)
[3-4]  = 현재 층 (int16, little-endian, -1 if null)
[5]    = 우선순위 (uint8)
[6-13] = 타임스탬프 (int64, little-endian)
```

### 상태 포맷 (Binary)

```
[0] = 현재 층 (int8)
[1] = 목표 층 (int8, -127 if null)
[2] = 방향 (0=정지, 1=상승, 2=하강)
[3] = 문 상태 (0=닫힘, 1=열림중, 2=열림, 3=닫힘중)
[4] = 운행 상태 (0=대기, 1=운행, 2=정지, 3=정비, 4=비상, 5=오류)
[5] = 하중 (%, 255 if null)
[6-7] = 예약
```

## 인증 흐름

```
앱                                    엘리베이터
│                                         │
│  1. QR Token + Device ID 전송            │
│ ───────────────────────────────────────▶│
│                                         │
│  2. Challenge 수신                       │
│ ◀───────────────────────────────────────│
│                                         │
│  3. Challenge Response 생성 (QR 기반)    │
│                                         │
│  4. Challenge Response 전송              │
│ ───────────────────────────────────────▶│
│                                         │
│  5. Session Token + 권한 수신            │
│ ◀───────────────────────────────────────│
│                                         │
```

## 제조사별 광고 데이터

### Otis (Manufacturer ID: 0x0001)
```
[0-1] = 제조사 ID (0x0001)
[2]   = 프로토콜 버전
[3-6] = 엘리베이터 ID
[7]   = 현재 층
[8]   = 상태 플래그
```

### Schindler (Manufacturer ID: 0x0002)
```
[0-1] = 제조사 ID (0x0002)
[2-5] = 엘리베이터 ID
[6]   = 현재 층
[7]   = 상태
```

### KONE (Manufacturer ID: 0x0003)
```
[0-1] = 제조사 ID (0x0003)
[2-5] = 엘리베이터 ID
[6]   = 현재 층
[7]   = 상태
```

### Thyssenkrupp (Manufacturer ID: 0x0004)
```
[0-1] = 제조사 ID (0x0004)
[2-7] = 엘리베이터 ID (ASCII)
[8]   = 현재 층
```

## 보안

1. **LE Secure Connections**: BLE 4.2+에서 지원되는 보안 연결
2. **Challenge-Response**: QR 코드 기반 인증
3. **Session Token**: 인증 후 발급되는 임시 토큰
4. **MTU Encryption**: 517 bytes MTU에 암호화 적용

## 에러 코드

| 코드 | 설명 | 처리 방법 |
|------|------|----------|
| E001 | 연결 실패 | 재연결 시도 |
| E002 | 인증 실패 | QR 재스캔 |
| E003 | 명령 거부 | 권한 확인 |
| E004 | 타임아웃 | 재시도 |
| E005 | 비상 정지 | 현장 확인 |
| E006 | 정비 중 | 다른 엘리베이터 사용 |

## 구현 참고사항

1. **Android**: BLUETOOTH_SCAN, BLUETOOTH_CONNECT 권한 필요 (Android 12+)
2. **iOS**: NSCameraUsageDescription, NSBluetoothAlwaysUsageDescription 필요
3. **백그라운드**: iOS는 백그라운드 스캔 제한, Android는 foreground_service 권장
4. **MTU**: 가능한 한 큰 MTU(517) 사용 권장
