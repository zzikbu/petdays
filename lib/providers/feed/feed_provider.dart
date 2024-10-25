import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/providers/feed/feed_state.dart';
import 'package:pet_log/repositories/feed_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class FeedProvider extends StateNotifier<FeedState> with LocatorMixin {
  // FeedProvider 만들어질 때 FeedState 같이 만들기
  FeedProvider() : super(FeedState.init());

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
      state = state.copyWith(
        feedStatus: FeedStatus.error,
      ); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
