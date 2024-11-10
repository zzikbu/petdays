import 'package:petdays/models/walk_model.dart';

enum WalkStatus {
  init,
  submitting,
  fetching,
  success,
  error,
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
