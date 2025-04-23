## 펫데이즈
<img alt="header" width="1024" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/header.png?raw=true">

<p align="center">
  <a href="https://apps.apple.com/kr/app/%ED%8E%AB%EB%8D%B0%EC%9D%B4%EC%A6%88/id6738037038">
    <img alt="app_store" height="60" src="https://raw.githubusercontent.com/zzikbu/PetDays/main/readme_assets/app_store.png">
  </a>
  <a href="https://play.google.com/store/apps/details?id=com.devmoichi.petdays">
    <img alt="play_store" height="60" src="https://raw.githubusercontent.com/zzikbu/PetDays/main/readme_assets/play_store.png">
  </a>
</p>

## 목차
- [프로젝트 소개](#프로젝트-소개)
- [개발 기간](#개발-기간)
- [주요 기능](#주요-기능)
- [기술 스택](#기술-스택)
- [기획 및 디자인](#기획-및-디자인)
- [기능 실행 화면](#기능-실행-화면)
- [주요 기술](#주요-기술)
  <br/><br/>

## 프로젝트 소개
**1인 기획 / 디자인 / 개발**<br>

반려동물의 성장일기, 진료기록, 산책기록을 한곳에 담아 보관하고 공유할 수 있는 모바일 애플리케이션입니다.
<br/><br/>

## 개발 기간
- **기획 & 디자인:** 2024.07.29 ~ 2024.08.28 _(약 1개월)_
- **기능 개발 & 배포:** 2024.08.14 ~ 2024.12.01 _(약 5개월)_
- **리팩토링 & 유지보수:** 2024.12.01 ~ _(현재 진행 중)_  
  <br>

## 주요 기능
1. **반려동물:** 반려동물의 기본 정보를 등록하고, 함께한 소중한 시간을 확인할 수 있습니다.

2. **성장일기:** 반려동물과의 특별한 순간을 사진과 글로 기록해 추억할 수 있습니다.

3. **진료기록:** 병원 방문 기록을 관리할 수 있습니다.

4. **산책:** 산책 시간,거리와 경로를 기록해 관리할 수 있습니다.

5. **피드:** 공개된 성장일기를 통해 다른 반려인들과 경험을 공유하고 좋아요를 통해 공감할 수 있습니다.
   <br/><br/>

## 기술 스택
- **언어:** `Dart`
- **프레임워크:** `Flutter`
- **아키텍쳐**: `MVVM`<br>
  <img alt="architecture" height="280" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/architecture.png?raw=true">

- **사용한 패키지:**
  - Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `google_sign_in`
  - State Management: `provider`, `state_notifier`, `flutter_state_notifier`
  - Location: `geolocator`, `google_maps_flutter`
  - UI/UX: `carousel_slider`, `smooth_page_indicator`, `flutter_svg`, `extended_image`
  - Util:  `image_picker`, `permission_handler`, `flutter_native_splash`, `uuid`, `string_validator`, `package_info_plus`, `webview_flutter`
    <br/><br/>

## 기획 및 디자인
### [🔗 기획 및 디자인 Figma 🔗](https://www.figma.com/design/LbVM8DvEcGfaR47cfpLk0c/%ED%8E%AB%EB%8D%B0%EC%9D%B4%EC%A6%88_%EB%94%94%EC%9E%90%EC%9D%B8?node-id=3-219&t=x3TuifRTAZvSPb8Z-1)

| IA                                                           | FlowChart                                                    |
|:------------------------------------------------------------:|:------------------------------------------------------------:|
| <img alt="ia" height="309" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/plan_design/ia.png?raw=true"> | <img alt="flowchart" height="309" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/plan_design/flowchart.png?raw=true"> |

| 홈                                                            | 반려동물 상세보기                                                    | 피드 홈                                                         | 성장일기 상세보기                                                    |
|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|
| <img alt="home" width="144" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/plan_design/home.png?raw=true"> | <img alt="pet_detail" width="190" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/plan_design/pet_detail.png?raw=true"> | <img alt="feed_home" width="178" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/plan_design/feed_home.png?raw=true"> | <img alt="diary_detail" width="172" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/plan_design/diary_detail.png?raw=true"> |
| 산책 홈                                                         | 산책 상세보기                                                      | 산책 지도 트래킹                                                    |                                                              |
| <img alt="walk_home" width="174" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/plan_design/walk_home.png?raw=true"> | <img alt="walk_detail" width="174" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/plan_design/walk_detail.png?raw=true"> | <img alt="walk_map" width="174" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/plan_design/walk_map.png?raw=true"> |                                                              |
<br/>

## 기능 실행 화면

| 로그인                                                          | 회원가입                                                         | 홈                                                            | 반려동물 추가                                                      |
|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|:------------------------------------------------------------:|
| <img alt="signin" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/signin.gif?raw=true"> | <img alt="signup" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/signup.gif?raw=true"> | <img alt="home" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/home.gif?raw=true"> | <img alt="pet" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/pet.gif?raw=true"> |
| 성장일기                                                         | 진료기록                                                         | 산책                                                           | 피드 / 좋아요                                                     |
| <img alt="diary" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/diary.gif?raw=true"> | <img alt="medical" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/medical.gif?raw=true"> | <img alt="walk" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/walk.gif?raw=true"> | <img alt="feed" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/feed.gif?raw=true"> |
| 신고 / 차단                                                      | 닉네임 변경                                                       | 프로필 이미지 변경 / 삭제                                              | 공개한 성장일기                                                     |
| <img alt="report_block" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/report_block.gif?raw=true"> | <img alt="nickname" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/nickname.gif?raw=true"> | <img alt="profile_image" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/profile_image.gif?raw=true"> | <img alt="open" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/open.PNG?raw=true"> |
| 좋아요한 성장일기                                                    |                                                              |                                                              |                                                              |
| <img alt="like" width="180" src="https://github.com/zzikbu/PetDays/blob/main/readme_assets/gif/like.PNG?raw=true"> |                                                              |                                                              |                                                              |
<br/>

## 주요 기술
### ✅ Provider와 StateNotifier를 활용한 효율적인 상태 관리
* 기존 `ChangeNotifier`의 한계를 보완하고, 더 효율적인 상태 관리를 위해 `StateNotifier`를 도입했습니다.

* `StateNotifier` 사용한 주요 개선점
  - **Immutable 기반의 상태 관리**: 상태 변경 시 새로운 상태 객체를 생성하여 변경 과정을 명확히 추적
  - **타입 안전성 강화**: 엄격한 상태 타입 정의를 통한 런타임 에러 방지
  - **상태의 Status 구분**: 각 상태의 Status를 직관적으로 알 수 있도록 init, submitting, fetching 등으로 구체적으로 정의
```dart
// Status 정의
enum MedicalStatus { init, submitting, fetching, success, error }

// 불변 상태 클래스 정의
class MedicalState {
  final MedicalStatus medicalStatus;
  final List<MedicalModel> medicalList;

  const MedicalState({
    required this.medicalStatus, 
    required this.medicalList
  });
  
  MedicalState copyWith({
    MedicalStatus? medicalStatus, 
    List<MedicalModel>? medicalList
  }) {
    return MedicalState(
      medicalStatus: medicalStatus ?? this.medicalStatus,
      medicalList: medicalList ?? this.medicalList,
    );
  }
}

// Provider 구현
class MedicalProvider extends StateNotifier<MedicalState> with LocatorMixin {
  MedicalProvider() : super(MedicalState.init());

  Future<void> getMedicalList({required String uid}) async {
    try {
      // fetching 상태로 변경
      state = state.copyWith(medicalStatus: MedicalStatus.fetching);
      
      // 데이터 요청 로직
      final medicalList = await read<MedicalRepository>().getMedicalList(uid: uid);
      
      // success 상태로 변경 및 medicalList 업데이트
      state = state.copyWith(
        medicalList: medicalList,
        medicalStatus: MedicalStatus.success,
      );
    } on CustomException catch (_) {
      // error 상태로 변경
      state = state.copyWith(medicalStatus: MedicalStatus.error);
      rethrow;
    }
  }
}

// UI에서 상태 구독 후 활용
Widget build(BuildContext context) {
  final medicalState = context.watch<MedicalState>();
  final isLoading = medicalState.medicalStatus == MedicalStatus.fetching;
  
  return isLoading
    ? CircularProgressIndicator()
    : ListView.builder(
        itemCount: medicalState.medicalList.length,
        itemBuilder: (context, index) => 
          MedicalCard(medicalState.medicalList[index]),
      );
}
```
---
### ✅ Database Batch
- `Batch`는 여러 데이터베이스 작업을 하나로 묶어 실행하며, 작업 중 하나라도 실패하면 롤백되어 데이터의 일관성과 무결성을 보장합니다.

- 성장일기 삭제 기능에서 아래 작업을 `Batch`를 활용해 구현했습니다.<br/>
  ① 해당 문서에 좋아요를 누른 사용자들의 likes 필드에서 성장일기 ID 제거<br/>
  ② 해당 성장일기 문서 삭제<br/>
  ③ 작성자의 diaryCount 감소
- Code<br/>
  ```dart
    WriteBatch batch = firebaseFirestore.batch();

    // 성장일기 좋아요 누른 사용자 찾기
    List<String> likes = await diaryDocRef
        .get()
        .then((value) => List<String>.from(value.data()!['likes']));

    // ① 해당 사용자들의 likes 필드에서 성장일기 ID 제거  
    likes.forEach((uid) {
      batch.update(firebaseFirestore.collection('users').doc(uid), {
        'likes': FieldValue.arrayRemove([diaryModel.diaryId]),
      });
    });

    // ② 성장일기 문서 삭제
    batch.delete(diaryDocRef);

    // ③ 작성자의 diaryCount 감소
    batch.update(writerDocRef, {
      'diaryCount': FieldValue.increment(-1),
    });

    // 실행
    batch.commit();
  ```
---
### ✅ Database Transaction
- `Transaction`은 데이터 변경 시 자동 재시도(최대 5회)를 통해 모든 작업이 성공하거나 실패 시 모두 취소되도록 하여 동시 작업 간 데이터 일관성을 유지합니다.

- 성장일기 좋아요 기능에서 아래 작업을 `Transaction`을 활용해 구현했습니다.<br/>
  ① 해당 성장일기의 likes 필드에서 유저 ID 추가 또는 제거<br/>
  ② 해당 성장일기의 likeCount 증가 또는 감소<br/>
  ③ 좋아요를 누른 유저 문서의 likes 필드에 성장일기 ID 추가 또는 제거

- Code <br/>
  ```dart
  // 성장일기 likes에 사용자 ID가 있는지 확인
  bool isDiaryContains = diaryLikes.contains(uid);

  transaction.update(diaryDocRef, {
    // ① 해당 성장일기 likes 업데이트
    'likes': isDiaryContains
        ? FieldValue.arrayRemove([uid])
        : FieldValue.arrayUnion([uid]),
    // ② 성장일기 likeCount 업데이트
    'likeCount': isDiaryContains
        ? FieldValue.increment(-1)
        : FieldValue.increment(1),
  });

  // ③ 좋아요 누른 사용자의 likes 업데이트
  transaction.update(userDocRef, {
    'likes': userLikes.contains(diaryId)
        ? FieldValue.arrayRemove([diaryId])
        : FieldValue.arrayUnion([diaryId]),
  });
  ```
