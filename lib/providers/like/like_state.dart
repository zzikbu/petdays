import 'package:pet_log/models/diary_model.dart';

enum LikeStatus {
  init, // LikeState를 최초로 객체 생성한 상태
  submitting, // 게시글을 등록하는 중인 상태
  fetching, // 가져오는 중인 상태
  success, // 작업이 성공한 상태
  error, // 작업이 실패한 상태
}

class LikeState {
  final LikeStatus likeStatus;
  final List<DiaryModel> likeList;

  const LikeState({
    required this.likeStatus,
    required this.likeList,
  });

  factory LikeState.init() {
    return LikeState(
      likeStatus: LikeStatus.init,
      likeList: [],
    );
  }

  LikeState copyWith({
    LikeStatus? likeStatus,
    List<DiaryModel>? likeList,
  }) {
    return LikeState(
      likeStatus: likeStatus ?? this.likeStatus,
      likeList: likeList ?? this.likeList,
    );
  }

  @override
  String toString() {
    return 'LikeState{likeStatus: $likeStatus, likeList: $likeList}';
  }
}
