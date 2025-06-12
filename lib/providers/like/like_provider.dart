import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/domain/model/diary_model.dart';
import 'package:petdays/providers/like/like_state.dart';
import 'package:petdays/domain/repository/like_repository.dart';

class LikeProvider extends StateNotifier<LikeState> with LocatorMixin {
  LikeProvider() : super(LikeState.init());

  // 성장일기 수정
  void updateDiary({
    required DiaryModel updatedDiaryModel,
  }) {
    state = state.copyWith(likeStatus: LikeStatus.submitting);

    try {
      // 기존 LikeList 특정 diaryId와 동일한 항목을 찾아 새로운 diaryModel로 교체
      List<DiaryModel> newLikeList = state.likeList.map((diary) {
        return diary.diaryId == updatedDiaryModel.diaryId ? updatedDiaryModel : diary;
      }).toList();

      state = state.copyWith(
        likeStatus: LikeStatus.success,
        likeList: newLikeList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(likeStatus: LikeStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 성장일기 삭제
  void deleteDiary({
    required String diaryId,
  }) {
    try {
      state = state.copyWith(likeStatus: LikeStatus.submitting);

      List<DiaryModel> newLikeList =
          state.likeList.where((element) => element.diaryId != diaryId).toList();

      state = state.copyWith(
        likeStatus: LikeStatus.success,
        likeList: newLikeList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(likeStatus: LikeStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // LikeHomeScreen을 통해 좋아요 했을 때 LikeState.LikeList 업데이트
  void likeDiary({
    required DiaryModel newDiaryModel,
  }) {
    state = state.copyWith(likeStatus: LikeStatus.submitting);

    try {
      // 기존 LikeList 특정 diaryId와 동일한 항목을 찾아 새로운 diaryModel로 교체
      List<DiaryModel> newLikeList = state.likeList.map((diary) {
        return diary.diaryId == newDiaryModel.diaryId ? newDiaryModel : diary;
      }).toList();

      state = state.copyWith(
        likeStatus: LikeStatus.success,
        likeList: newLikeList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(likeStatus: LikeStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 좋아요한 성장일기 가져오기
  Future<void> getLikeList() async {
    state = state.copyWith(likeStatus: LikeStatus.fetching);

    try {
      String currentUserUid = read<User>().uid;

      List<DiaryModel> likeList = await read<LikeRepository>().getLikeList(uid: currentUserUid);

      state = state.copyWith(
        likeStatus: LikeStatus.success,
        likeList: likeList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(likeStatus: LikeStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
