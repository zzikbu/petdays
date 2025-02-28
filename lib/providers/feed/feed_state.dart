import 'package:petdays/models/diary_model.dart';

enum FeedStatus {
  init, // FeedState를 최초로 객체 생성한 상태
  submitting, // 게시글을 등록하는 중인 상태
  fetching, // 가져오는 중인 상태
  success, // 작업이 성공한 상태
  error, // 작업이 실패한 상태
}

class FeedState {
  final FeedStatus feedStatus;
  final List<DiaryModel> feedList;
  final List<DiaryModel> hotFeedList;

  const FeedState({
    required this.feedStatus,
    required this.feedList,
    required this.hotFeedList,
  });

  factory FeedState.init() {
    return const FeedState(
      feedStatus: FeedStatus.init,
      feedList: [],
      hotFeedList: [],
    );
  }

  FeedState copyWith({
    FeedStatus? feedStatus,
    List<DiaryModel>? feedList,
    List<DiaryModel>? hotFeedList,
  }) {
    return FeedState(
      feedStatus: feedStatus ?? this.feedStatus,
      feedList: feedList ?? this.feedList,
      hotFeedList: hotFeedList ?? this.hotFeedList,
    );
  }
}
