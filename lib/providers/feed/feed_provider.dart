import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/models/user_model.dart';
import 'package:pet_log/providers/feed/feed_state.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/repositories/feed_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class FeedProvider extends StateNotifier<FeedState> with LocatorMixin {
  // FeedProvider 만들어질 때 FeedState 같이 만들기
  FeedProvider() : super(FeedState.init());

  // 성장일기 좋아요
  Future<DiaryModel> likeDiary({
    required String diaryId,
    required List<String> diaryLikes,
  }) async {
    state = state.copyWith(feedStatus: FeedStatus.submitting);

    try {
      UserModel userModel = read<UserState>().userModel;

      // 좋아요가 눌려서 내용물이 수정된 성장일기
      DiaryModel diaryModel = await read<FeedRepository>().likeDiary(
        diaryId: diaryId,
        diaryLikes: diaryLikes,
        uid: userModel.uid,
        userLikes: userModel.likes,
      );

      List<DiaryModel> newFeedList = state.feedList.map(
        (diary) {
          return diary.diaryId == diaryId ? diaryModel : diary;
        },
      ).toList();

      state = state.copyWith(
        feedStatus: FeedStatus.success,
        feedList: newFeedList,
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

      List<DiaryModel> feedList = await read<FeedRepository>().getFeedList();

      state = state.copyWith(
        feedList: feedList,
        feedStatus: FeedStatus.success, // 상태 변경
      );
    } on CustomException catch (_) {
      state =
          state.copyWith(feedStatus: FeedStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
