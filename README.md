## 🐶 펫데이즈 😺
<img alt="petdays" width="1024" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/petdays.png?raw=true">
<div align="center">
    <a target="_blank" href="https://apps.apple.com/kr/app/%ED%8E%AB%EB%8D%B0%EC%9D%B4%EC%A6%88/id6738037038">
        <img width="180" src="https://raw.githubusercontent.com/zzikbu/PetDays/main/readme_assets/appstore.png?raw=true" alt="App Store Link">
    </a>
</div>
<br/>

## 목차
- [프로젝트 소개](#프로젝트-소개)
- [주요 기능](#주요-기능)
- [팀 구성 및 역할](#팀-구성-및-역할)
- [기획 및 디자인](#기획-및-디자인)
- [기능 실행 화면](#기능-실행-화면)
- [주요 기술](#주요-기술)
<br/><br/>

## 프로젝트 소개
1500만 반려인 시대에 맞춰, 반려동물과의 소중한 일상을 디지털로 기록하고 추억할 수 있는 모바일 애플리케이션입니다.
<br/>

### 개발 기간
- 2024.07.29 ~ 2024.08.28 ( 약 1개월 / FlowChart, IA, 디자인 구현 )
- 2024.08.21 ~ 2024.11.12 (약 3개월 / 기능 개발 후 iOS 배포)
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
| <img alt="깃허브 프로필 이미지" width="170" src="https://avatars.githubusercontent.com/zzikbu"> |
| [이승민](https://github.com/zzikbu)                             |
<br/>

## 기획 및 디자인
- [기획 \(IA & FlowChart\) 피그마](https://www.figma.com/board/bRJPGCggzClx0mkBAM67HK/%ED%8E%AB%EB%8D%B0%EC%9D%B4%EC%A6%88_IA-%26-FlowChart?node-id=0-1&t=zGr2xHekPnblou5w-1)
- [디자인 피그마](https://www.figma.com/design/LbVM8DvEcGfaR47cfpLk0c/%ED%8E%AB%EB%8D%B0%EC%9D%B4%EC%A6%88_%EB%94%94%EC%9E%90%EC%9D%B8?node-id=3-219&t=x3TuifRTAZvSPb8Z-1)

| IA                                                           |
|:------------------------------------------------------------:|
| <img alt="ia" width="350" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/1/ia.png?raw=true"> |

| FlowChart                                                    |
|:------------------------------------------------------------:|
| <img alt="flowchart" width="660" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/1/flowchart.png?raw=true"> |

| 홈                                                            | 반려동물 상세보기                                                    | 피드 홈                                                         | 성장일기 상세보기                                                    |
|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|
| <img alt="home" width="144" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/1/home.png?raw=true"> | <img alt="pet_detail" width="190" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/1/pet_detail.png?raw=true"> | <img alt="feed_home" width="178" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/1/feed_home.png?raw=true"> | <img alt="diary_detail" width="172" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/1/diary_detail.png?raw=true"> |
| 산책 홈                                                         | 산책 상세보기                                                      | 산책 지도 트래킹                                                    |                                                              |
| <img alt="walk_home" width="174" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/1/walk_home.png?raw=true"> | <img alt="walk_detail" width="174" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/1/walk_detail.png?raw=true"> | <img alt="walk_map" width="174" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/1/walk_map.png?raw=true"> |                                                              |

<br/>

## 기능 실행 화면

| 로그인                                                          | 회원가입                                                         | 홈                                                            | 반려동물 추가                                                      |
|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|
| <img alt="signin" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/signin.gif?raw=true"> | <img alt="signup" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/signup.gif?raw=true"> | <img alt="home" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/home.gif?raw=true"> | <img alt="pet" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/pet.gif?raw=true"> |
| 성장일기                                                         | 진료기록                                                         | 산책                                                           | 피드 / 좋아요                                                     |
| <img alt="diary" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/diary.gif?raw=true"> | <img alt="medical" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/medical.gif?raw=true"> | <img alt="walk" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/walk.gif?raw=true"> | <img alt="feed" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/feed.gif?raw=true"> |
| 신고 / 차단                                                      | 닉네임 변경                                                       | 프로필 이미지 변경 / 삭제                                              | 공개한 성장일기                                                     |
| <img alt="report_block" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/report_block.gif?raw=true"> | <img alt="nickname" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/nickname.gif?raw=true"> | <img alt="profile_image" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/profile_image.gif?raw=true"> | <img alt="open" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/open.PNG?raw=true"> |
| 좋아요한 성장일기                                                    |                                                              |                                                              |                                                              |
| <img alt="like" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/2/like.PNG?raw=true"> |                                                              |                                                              |                                                              |
<br/>

## 주요 기술
### **Provider와 StateNotifier를 활용한 효율적인 상태 관리**
* 기존 `ChangeNotifier`의 한계를 보완하고, 더 효율적인 상태 관리를 위해 `StateNotifier`를 도입했습니다.
* `StateNotifier` 사용한 주요 개선점
  - **불변성 기반의 상태 관리**: 상태 변경 시 새로운 상태 객체를 생성하여 변경 과정을 명확히 추적
  - **타입 안전성 강화**: 엄격한 상태 타입 정의를 통한 런타임 에러 방지
  - **상태의 Status 구분**: 각 상태의 Status를 직관적으로 알 수 있도록 init, submitting, fetching 등으로 구체적으로 정의
<img alt="statenotifier" width="400" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/3/statenotifier_1.png?raw=true">
<img alt="statenotifier" width="480" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/3/statenotifier_2.png?raw=true">

---
### **Batch**
- 성장일기 삭제 기능에서 아래 작업을 `Batch`를 활용해 구현했습니다.
  1. 해당 문서에 좋아요를 누른 사용자들의 likes 필드에서 성장일기 ID 제거
  2. 해당 성장일기 문서 삭제
  3. 작성자의 diaryCount 감소

- `Batch`는 위 작업들을 하나로 묶어 실행하며, **모든 작업이 성공적으로 완료되지 않으면 롤백**되도록 설계했습니다.

- 이를 통해 데이터베이스 작업 간 불일치 상태를 방지하며, 데이터의 일관성을 유지했습니다.
<img alt="batch" width="400" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/3/batch.png?raw=true">

---
### **Transaction**
- 성장일기 좋아요 기능에서 아래 작업을 `Transaction`을 활용해 구현했습니다.
  1. 해당 성장일기의 likes 필드에서 유저 ID 추가 또는 제거
  2. 해당 성장일기의 likeCount 증가 또는 감소
  3. 좋아요를 누른 유저 문서의 likes 필드에 성장일기 ID 추가 또는 제거

- `Transaction`을 사용하여 **모든 작업이 성공적으로 처리되거나 실패 시 모두 취소**되도록 하고, 트랜잭션 중 데이터 변경(좋아요 수)이 감지되면 작업이 **자동 재시도** 되도록 설계했습니다.

- 이를 통해 여러 사용자가 동시에 좋아요 작업을 수행하더라도 데이터의 불일치 문제를 방지하며, 데이터의 일관성을 유지했습니다.
<img alt="transaction" width="400" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/3/transaction.png?raw=true">
