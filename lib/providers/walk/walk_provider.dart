import 'dart:typed_data';

import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/walk_model.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/providers/walk/walk_state.dart';
import 'package:pet_log/repositories/walk_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class WalkProvider extends StateNotifier<WalkState> with LocatorMixin {
  // WalkProvider 만들어질 때 WalkState 같이 만들기
  WalkProvider() : super(WalkState.init());

  // 산책 업로드
  Future<void> uploadWalk({
    required Uint8List mapImage,
    required String distance,
    required String duration,
    required String petId,
  }) async {
    try {
      state = state.copyWith(
          walkStatus: WalkStatus.submitting); // 게시글을 등록하는 중인 상태로 변경

      String uid = read<UserState>().userModel.uid; // 작성자

      WalkModel walkModel = await read<WalkRepository>().uploadWalk(
        uid: uid,
        mapImage: mapImage,
        distance: distance,
        duration: duration,
        petId: petId,
      );

      state = state.copyWith(
          walkStatus: WalkStatus.success, // 등록 완료 상태로 변경
          walkList: [
            walkModel,
            ...state.walkList, // 새로 등록한 산책을 리스트 맨앞에 추가
          ]);
    } on CustomException catch (_) {
      state =
          state.copyWith(walkStatus: WalkStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
