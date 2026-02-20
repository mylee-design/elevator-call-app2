# 웹 배포 가이드

## 개요

Flutter 웹을 사용하여 브라우저에서 엘리베이터 호출 앱을 실행할 수 있습니다.

## ⚠️ 웹 버전 제약사항

### 지원 브라우저
- **Chrome** 89+ (권장)
- **Edge** 89+
- **Opera** 75+

### 지원하지 않는 브라우저
- Safari (Web Bluetooth 미지원)
- Firefox (Web Bluetooth 미지원)
- iOS Chrome (WebKit 제한)

### 기능 제한
| 기능 | 웹 지원 | 비고 |
|------|---------|------|
| QR 스캔 | ✅ | 칩라 권한 필요 |
| BLE 스캔 | ✅ | Chrome/Edge 전용 |
| BLE 연결 | ✅ | 보안 컨텍스트(HTTPS) 필요 |
| 백그라운드 | ❌ | 브라우저 제한 |
| 푸시 알림 | ⚠️ | 서비스 워커 필요 |

---

## 빌드 방법

### 1. Flutter 설치

```bash
# Flutter 설치 확인
flutter doctor

# Flutter 버전 3.24+ 권장
flutter --version
```

### 2. 웹 빌드

```bash
cd elevator_call_app

# 의존성 설치
flutter pub get

# 웹 개발 서버 실행 (로컬 테스트)
flutter run -d chrome

# 프로덕션 빌드
flutter build web --release
```

빌드된 파일 위치: `build/web/`

---

## 로컬 테스트

### 개발 서버 실행
```bash
flutter run -d chrome
```

### 다른 브라우저 테스트
```bash
# Edge
flutter run -d edge

# 특정 브라우저
flutter run -d web-server --web-port=8080
```

---

## 배포 방법

### 방법 1: Firebase Hosting (권장)

```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 로그인
firebase login

# Firebase 초기화
firebase init hosting
# - build/web 선택
# - SPA: Yes
# - 자동 배포: 선택사항

# 배포
firebase deploy
```

### 방법 2: Netlify

```bash
# Netlify CLI 설치
npm install -g netlify-cli

# 배포
netlify deploy --dir=build/web --prod
```

### 방법 3: GitHub Pages

```bash
# gh-pages 패키지 설치
npm install -g gh-pages

# 배포
flutter build web --release --base-href "/elevator_call_app/"
gh-pages -d build/web
```

### 방법 4: 정적 파일 서빙

```bash
cd build/web

# Python
python -m http.server 8080

# Node.js
npx serve .

# PHP
php -S localhost:8080
```

---

## HTTPS 설정 (필수)

Web Bluetooth API는 **보안 컨텍스트(HTTPS 또는 localhost)**에서만 작동합니다.

### 로컬 HTTPS 테스트

```bash
# mkcert 설치
npm install -g mkcert

# 인증서 생성
mkcert -install
mkcert localhost

# HTTPS 서버 실행
cd build/web
npx http-server -S -C localhost.pem -K localhost-key.pem
```

---

## 브라우저 권한 설정

### 칩라 권한
- 브라우저에서 칩라 접근 허용 필요
- 설정 → 개인정보 및 보안 → 칩라

### Bluetooth 권한
- 첫 실행시 Bluetooth 권한 요청
- 설정 → 개인정보 및 보안 → Bluetooth

---

## 디버깅

### Chrome DevTools
```
F12 → Console → Bluetooth 관련 로그 확인
```

### Web Bluetooth 디버깅
```javascript
// Chrome DevTools Console에서
navigator.bluetooth.requestDevice({ acceptAllDevices: true })
  .then(device => console.log(device))
  .catch(error => console.error(error));
```

---

## 문제 해결

### "Bluetooth is not supported" 오류
- Chrome/Edge 브라우저 사용 확인
- HTTPS 또는 localhost 접속 확인

### "Permission denied" 오류
- 브라우저 권한 설정 확인
- 사이트 설정 → 권한 → Bluetooth 허용

### QR 스캔이 안될 때
- 칩라 권한 확인
- 다른 브라우저 시도
- 수동 입력 기능 사용

---

## 데모 URL

배포 후 접속 URL:
```
https://your-project.firebaseapp.com
https://your-project.netlify.app
https://your-username.github.io/elevator_call_app
```
