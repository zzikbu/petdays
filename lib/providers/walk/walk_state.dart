import 'package:pet_log/models/walk_model.dart';

enum WalkStatus {
  init, // DiaryState를 최초로 객체 생성한 상태
  submitting, // 게시글을 등록하는 중인 상태
  fetching, // 가져오는 중인 상태
  success, // 작업이 성공한 상태
  error, // 작업이 실패한 상태
}

class WalkState {
  final WalkStatus walkStatus;
  final List<WalkModel> walkList;

  const WalkState({
    required this.walkStatus,
    required this.walkList,
  });

  factory WalkState.init() {
    return WalkState(
      walkStatus: WalkStatus.init,
      walkList: [],
    );
  }

  WalkState copyWith({
    WalkStatus? walkStatus,
    List<WalkModel>? walkList,
  }) {
    return WalkState(
      walkStatus: walkStatus ?? this.walkStatus,
      walkList: walkList ?? this.walkList,
    );
  }
}
