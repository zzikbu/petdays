## 🐶 펫데이즈 😺
![프로모션 이미지 합친거](https://github.com/user-attachments/assets/0fa1fbdb-2111-4679-a3d2-433506df8f98)
| <a href="https://apps.apple.com/kr/app/%ED%8E%AB%EB%8D%B0%EC%9D%B4%EC%A6%88/id6738037038" target="_blank"> <br>  <img src="https://github.com/user-attachments/assets/0fbf0214-d271-4722-abb7-ed853f242cd1" width="140px"> <br></a> |
|:------------------------------------------------------------:|
<br/>

## 목차
- [프로젝트 소개](#프로젝트-소개)
- [주요 기능](#주요-기능)
- [팀 구성 및 역할](#팀-구성-및-역할)
- [기획 및 디자인](#기획-및-디자인)
- [주요 기능 실행 화면](#주요-기능-실행-화면)
- [주요 기술](#%EC%A3%BC%EC%9A%94-%EA%B8%B0%EC%88%A0)
<br/><br/>

## 프로젝트 소개
1500만 반려인 시대에 맞춰, 반려동물과의 소중한 일상을 디지털로 기록하고 추억할 수 있는 모바일 애플리케이션입니다.
<br/><br/>
#### 개발 기간
- 2024.08.28 ~ 2024.11.12 (기능 개발 후 배포)
- 2024.11.13 ~ (리팩토링 및 버그 수정 진행 중)
<br/><br/>

## 주요 기능
1. 반려동물 등록 : 반려동물의 기본 정보를 등록하고, 함께한 소중한 시간을 확인할 수 있습니다.

2. 성장일기 : 반려동물과의 특별한 순간을 사진과 글로 기록하고, 다른 반려인들과 공유할 수 있습니다.

3. 진료기록 : 병원 방문 기록을 체계적으로 관리할 수 있습니다.

4. 산책 : 반려동물과의 산책 경로와 시간을 기록하고, 확인할 수 있습니다.
<br/><br/>

## 기술 스택

- **언어:** `Dart`
- **프레임워크:** `Flutter`
- **아키텍쳐**: `MVVM`
- **사용한 패키지:**
  - 파이어베이스: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `google_sign_in`
  - 상태관리: `provider`, `state_notifier`, `flutter_state_notifier`
  - 지도 & 위치: `geolocator`, `google_maps_flutter`
  - Carousel UI: `carousel_slider`, `smooth_page_indicator`
  - 유효성: `uuid`, `string_validator`
  - 이미지: `flutter_svg`, `image_picker`, `extended_image`
  - 웹뷰: `webview_flutter`
  - 앱 정보 & 권한: `package_info_plus`, `permission_handler`
  - 스플래시 화면: `flutter_native_splash` 
<br/><br/>

## 팀 구성 및 역할
| 1인 기획 / 디자인 / 개발                                             |
|:------------------------------------------------------------:|
| <img src="https://avatars.githubusercontent.com/zzikbu" width=160px alt="이승민"/> |
| [이승민](https://github.com/zzikbu)                             |
<br/>

## 기획 및 디자인
| <img src="https://github.com/user-attachments/assets/fdcc8ff3-89dd-4dab-9b1d-006685f790a3" width="90%" /> | <img src="https://github.com/user-attachments/assets/070b9c2d-b473-4c46-ad3f-ba33014d9913" width="100%" /> |
|:------------------------------------------------------------:|:------------------------------------------------------------:|
| <img src="https://github.com/user-attachments/assets/6ce8bd37-dd7f-4535-a839-c1cefb0cf8b1" width="90%" /> | <img src="https://github.com/user-attachments/assets/d574c7f8-133f-4bb9-ab85-5b75edc726de" width="100%" /> |
- [기획 \(IA & FlowChart\) 피그마](https://www.figma.com/board/bRJPGCggzClx0mkBAM67HK/%ED%8E%AB%EB%8D%B0%EC%9D%B4%EC%A6%88_IA-%26-FlowChart?node-id=0-1&t=zGr2xHekPnblou5w-1)
- [디자인 피그마](https://www.figma.com/design/LbVM8DvEcGfaR47cfpLk0c/%ED%8E%AB%EB%8D%B0%EC%9D%B4%EC%A6%88_%EB%94%94%EC%9E%90%EC%9D%B8?node-id=3-219&t=x3TuifRTAZvSPb8Z-1)
<br/><br/>

## 주요 기능 실행 화면
| 이메일 회원가입 | 이메일 로그인 |
|:--------:|:-------:|
|          |         |
<br/>

## 주요 기술

### **batch**
- 성장일기 삭제 작업에서 (1) 해당 문서에 좋아요를 눌렀던 사용자들의 likes 필드에서 해당 성장일기 ID를 제거하고, (2) diary 문서를 삭제하며,  (3) 작성자의 diaryCount를 감소시키는 작업을 동시에 처리하도록 구현했습니다. 이 모든 작업은 하나의 배치로 묶어서 처리되며, 어느 하나라도 실패하면 전체 작업이 롤백되도록 했습니다.
- 이를 통해 데이터베이스에서 불일치 상태가 발생하지 않고, 데이터의 일관성을 유지할 수 있었습니다.
<img src="https://github.com/user-attachments/assets/07f84056-f88f-4477-930b-46b246349862" width="45%" />
