import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/providers/like/like_state.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/repositories/like_repository.dart';

class LikeProvider extends StateNotifier<LikeState> with LocatorMixin {
  LikeProvider() : super(LikeState.init());

  Future<void> getLikeList() async {
    state = state.copyWith(likeStatus: LikeStatus.fetching);

    try {
      String uid = read<UserState>().userModel.uid;

      List<DiaryModel> likeList =
          await read<LikeRepository>().getLikeList(uid: uid);

      state = state.copyWith(
        likeStatus: LikeStatus.success,
        likeList: likeList,
      );
    } on CustomException catch (_) {
      state =
          state.copyWith(likeStatus: LikeStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
