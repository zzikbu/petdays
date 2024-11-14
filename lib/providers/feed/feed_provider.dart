import 'package:firebase_auth/firebase_auth.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/diary_model.dart';
import 'package:petdays/models/user_model.dart';
import 'package:petdays/providers/feed/feed_state.dart';
import 'package:petdays/repositories/feed_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class FeedProvider extends StateNotifier<FeedState> with LocatorMixin {
  // FeedProvider 만들어질 때 FeedState 같이 만들기
  FeedProvider() : super(FeedState.init());

  // 성장일기 작성자 차단
  Future<void> blockUser({
    required String targetUserUid, // 차단할 유저
  }) async {
    state = state.copyWith(feedStatus: FeedStatus.submitting);

    try {
      String currentUserUid = read<User>().uid;

      await read<FeedRepository>().blockUser(
        currentUserUid: currentUserUid,
        targetUserUid: targetUserUid,
      );
    } on CustomException catch (_) {
      state =
          state.copyWith(feedStatus: FeedStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 성장일기 신고
  Future<void> reportDiary({
    required DiaryModel diaryModel,
    required String countField,
  }) async {
    state = state.copyWith(feedStatus: FeedStatus.submitting);

    try {
      String currentUserUid = read<User>().uid;

      // 신고하기가 눌려서 내용물이 수정된 성장일기
      DiaryModel newDiaryModel = await read<FeedRepository>().reportDiary(
        uid: currentUserUid,
        diaryModel: diaryModel,
        countField: countField,
      );

      List<DiaryModel> newFeedList = state.feedList.map(
        (diary) {
          return diary.diaryId == diaryModel.diaryId ? newDiaryModel : diary;
        },
      ).toList();

      List<DiaryModel> newHotFeedList = state.hotFeedList.map(
        (diary) {
          return diary.diaryId == diaryModel.diaryId ? newDiaryModel : diary;
        },
      ).toList();

      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: newFeedList,
        hotFeedList: newHotFeedList,
      );
    } on CustomException catch (_) {
      state =
          state.copyWith(feedStatus: FeedStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 성장일기 수정
  void updateDiary({
    required DiaryModel updatedDiaryModel,
  }) {
    state = state.copyWith(feedStatus: FeedStatus.submitting);

    try {
      // 기존 LikeList 특정 diaryId와 동일한 항목을 찾아 새로운 diaryModel로 교체
      List<DiaryModel> newFeedList = state.feedList.map((diary) {
        return diary.diaryId == updatedDiaryModel.diaryId
            ? updatedDiaryModel
            : diary;
      }).toList();

      List<DiaryModel> newHotFeedList = state.hotFeedList.map((diary) {
        return diary.diaryId == updatedDiaryModel.diaryId
            ? updatedDiaryModel
            : diary;
      }).toList();

      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: newFeedList,
        hotFeedList: newHotFeedList,
      );
    } on CustomException catch (_) {
      state =
          state.copyWith(feedStatus: FeedStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 성장일기 삭제
  void deleteDiary({
    required String diaryId,
  }) {
    try {
      state = state.copyWith(feedStatus: FeedStatus.submitting);

      List<DiaryModel> newFeedList = state.feedList
          .where((element) => element.diaryId != diaryId)
          .toList();

      List<DiaryModel> newHotFeedList = state.hotFeedList
          .where((element) => element.diaryId != diaryId)
          .toList();

      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: newFeedList,
        hotFeedList: newHotFeedList,
      );
    } on CustomException catch (_) {
      state =
          state.copyWith(feedStatus: FeedStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 성장일기 좋아요
  Future<DiaryModel> likeDiary({
    required String diaryId,
    required List<String> diaryLikes,
  }) async {
    state = state.copyWith(feedStatus: FeedStatus.submitting);

    try {
      String currentUserUid = read<User>().uid;

      // 좋아요가 눌려서 내용물이 수정된 성장일기
      DiaryModel diaryModel = await read<FeedRepository>().likeDiary(
        diaryId: diaryId,
        diaryLikes: diaryLikes,
        uid: currentUserUid,
      );

      List<DiaryModel> newFeedList = state.feedList.map(
        (diary) {
          return diary.diaryId == diaryId ? diaryModel : diary;
        },
      ).toList();

      List<DiaryModel> newHotFeedList = state.hotFeedList.map(
        (diary) {
          return diary.diaryId == diaryId ? diaryModel : diary;
        },
      ).toList();

      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: newFeedList,
        hotFeedList: newHotFeedList,
      );

      return diaryModel;
    } on CustomException catch (_) {
      state =
          state.copyWith(feedStatus: FeedStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 성장일기를 공개로 했을 때 FeedState.feedList 업데이트
  void uploadFeed({
    required DiaryModel diaryModel,
  }) {
    state = state.copyWith(feedStatus: FeedStatus.submitting);

    try {
      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: [
          diaryModel,
          ...state.feedList,
        ], // 공개로 등록한 성장일기를 리스트 맨앞에 추가
      );
    } on CustomException catch (_) {
      state =
          state.copyWith(feedStatus: FeedStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 피드 가져오기
  Future<void> getFeedList() async {
    try {
      state = state.copyWith(feedStatus: FeedStatus.fetching); // 상태 변경

      String currentUserUid = read<User>().uid;

      List<DiaryModel> feedList = await read<FeedRepository>()
          .getFeedList(currentUserUid: currentUserUid);

      List<DiaryModel> hotFeedList =
          feedList.where((feed) => feed.likeCount >= 5).toList();

      state = state.copyWith(
        feedList: feedList,
        hotFeedList: hotFeedList,
        feedStatus: FeedStatus.success, // 상태 변경
      );
    } on CustomException catch (_) {
      state =
          state.copyWith(feedStatus: FeedStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
