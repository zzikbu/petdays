import 'package:firebase_auth/firebase_auth.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/domain/model/diary_model.dart';
import 'package:petdays/providers/diary/diary_state.dart';
import 'package:petdays/domain/repository/diary_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class DiaryProvider extends StateNotifier<DiaryState> with LocatorMixin {
  // DiaryProvider 만들어질 때 DiaryState도 같이 만들기
  DiaryProvider() : super(DiaryState.init());

  // 성장일기 수정
  Future<DiaryModel> updateDiary({
    required String diaryId,
    required List<String> files, // 새로 추가된 이미지들
    required List<String> remainImageUrls, // 유지할 기존 이미지 URL들
    required List<String> deleteImageUrls, // 삭제할 기존 이미지 URL들
    required String title,
    required String desc,
  }) async {
    try {
      state = state.copyWith(diaryStatus: DiaryStatus.submitting);

      String uid = read<User>().uid;

      // 수정된 성장일기 모델 받아오기
      DiaryModel updatedDiary = await read<DiaryRepository>().updateDiary(
        diaryId: diaryId,
        uid: uid,
        files: files,
        remainImageUrls: remainImageUrls,
        deleteImageUrls: deleteImageUrls,
        title: title,
        desc: desc,
      );

      // diaryList에서 수정된 일기로 교체
      List<DiaryModel> newDiaryList = state.diaryList.map((diary) {
        return diary.diaryId == diaryId ? updatedDiary : diary;
      }).toList();

      List<DiaryModel> newOpenDiaryList = state.diaryList.map((diary) {
        return diary.diaryId == diaryId ? updatedDiary : diary;
      }).toList();

      state = state.copyWith(
        diaryStatus: DiaryStatus.success,
        diaryList: newDiaryList,
        openDiaryList: newOpenDiaryList,
      );

      return updatedDiary;
    } on CustomException catch (_) {
      state = state.copyWith(diaryStatus: DiaryStatus.error);
      rethrow;
    }
  }

  // 성장일기 삭제
  Future<void> deleteDiary({
    required DiaryModel diaryModel,
  }) async {
    state = state.copyWith(diaryStatus: DiaryStatus.submitting);

    try {
      await read<DiaryRepository>().deleteDiary(diaryModel: diaryModel);

      List<DiaryModel> newDiaryList = state.diaryList
          .where((element) => element.diaryId != diaryModel.diaryId)
          .toList(); // 삭제하지 않은 모델만 뽑아 새로운 리스트 생성

      List<DiaryModel> newOpenDiaryList =
          state.diaryList.where((element) => element.diaryId != diaryModel.diaryId).toList();

      state = state.copyWith(
        diaryStatus: DiaryStatus.success,
        diaryList: newDiaryList,
        openDiaryList: newOpenDiaryList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(diaryStatus: DiaryStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 성장일기 좋아요
  void likeDiary({
    required DiaryModel newDiaryModel,
  }) {
    state = state.copyWith(diaryStatus: DiaryStatus.submitting);

    try {
      // 기존 diaryList 특정 diaryId와 동일한 항목을 찾아 새로운 diaryModel로 교체
      List<DiaryModel> newDiaryList = state.diaryList.map((diary) {
        return diary.diaryId == newDiaryModel.diaryId ? newDiaryModel : diary;
      }).toList();

      List<DiaryModel> newOpenDiaryList = state.openDiaryList.map((diary) {
        return diary.diaryId == newDiaryModel.diaryId ? newDiaryModel : diary;
      }).toList();

      state = state.copyWith(
        diaryStatus: DiaryStatus.success,
        diaryList: newDiaryList,
        openDiaryList: newOpenDiaryList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(diaryStatus: DiaryStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 성장일기 가져오기
  Future<void> getDiaryList({
    required String uid,
  }) async {
    try {
      state = state.copyWith(diaryStatus: DiaryStatus.fetching); // 상태 변경

      List<DiaryModel> diaryList;

      diaryList = await read<DiaryRepository>().getDiaryList(uid: uid); // 접속 중인 사용자 필터해서 가져오기

      List<DiaryModel> openDiaryList = diaryList.where((diary) => diary.isLock == false).toList();

      state = state.copyWith(
        diaryList: diaryList,
        openDiaryList: openDiaryList,
        diaryStatus: DiaryStatus.success, // 상태 변경
      );
    } on CustomException catch (_) {
      state = state.copyWith(diaryStatus: DiaryStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 성장일기 업로드
  Future<DiaryModel> uploadDiary({
    required List<String> files, // 이미지들
    required String title, // 제목
    required String desc, // 내용
    required bool isLock, // 공개여부
  }) async {
    try {
      state = state.copyWith(diaryStatus: DiaryStatus.submitting); // 게시글을 등록하는 중인 상태로 변경

      String uid = read<User>().uid; // 작성자

      // 새로 등록한 성장일기를 리스트 맨앞에 추가 해주기 위해 변수에 저장
      DiaryModel diaryModel = await read<DiaryRepository>().uploadDiary(
        files: files,
        desc: desc,
        uid: uid,
        title: title,
        isLock: isLock,
      );

      state = state.copyWith(
        diaryStatus: DiaryStatus.success, // 등록 완료 상태로 변경
        diaryList: [
          diaryModel,
          ...state.diaryList, // 새로 등록한 성장일기를 리스트 맨앞에 추가
        ],
      );

      return diaryModel;
    } on CustomException catch (_) {
      state = state.copyWith(diaryStatus: DiaryStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
