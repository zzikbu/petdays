import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/domain/model/walk_model.dart';
import 'package:petdays/providers/walk/walk_state.dart';
import 'package:petdays/domain/repository/walk_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class WalkProvider extends StateNotifier<WalkState> with LocatorMixin {
  // WalkProvider 만들어질 때 WalkState 같이 만들기
  WalkProvider() : super(WalkState.init());

  // 산책 삭제
  Future<void> deleteWalk({
    required WalkModel walkModel,
  }) async {
    state = state.copyWith(walkStatus: WalkStatus.submitting);

    try {
      await read<WalkRepository>().deleteWalk(walkModel: walkModel);

      List<WalkModel> newWalkList = state.walkList
          .where((element) => element.walkId != walkModel.walkId)
          .toList(); // 삭제하지 않은 모델만 뽑아 새로운 리스트 생성

      state = state.copyWith(
        walkStatus: WalkStatus.success,
        walkList: newWalkList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(walkStatus: WalkStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 산책 가져오기
  Future<void> getWalkList({
    required String uid,
  }) async {
    try {
      state = state.copyWith(walkStatus: WalkStatus.fetching); // 상태 변경

      List<WalkModel> medicalList = await read<WalkRepository>().getWalkList(uid: uid);

      state = state.copyWith(
        walkList: medicalList,
        walkStatus: WalkStatus.success, // 상태 변경
      );
    } on CustomException catch (_) {
      state = state.copyWith(walkStatus: WalkStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 산책 업로드
  Future<void> uploadWalk({
    required Uint8List mapImage,
    required String distance,
    required String duration,
    required List<String> petIds,
  }) async {
    try {
      state = state.copyWith(walkStatus: WalkStatus.submitting); // 게시글을 등록하는 중인 상태로 변경

      String currentUserUid = read<User>().uid;

      WalkModel walkModel = await read<WalkRepository>().uploadWalk(
        uid: currentUserUid,
        mapImage: mapImage,
        distance: distance,
        duration: duration,
        petIds: petIds,
      );

      state = state.copyWith(
          walkStatus: WalkStatus.success, // 등록 완료 상태로 변경
          walkList: [
            walkModel,
            ...state.walkList, // 새로 등록한 산책을 리스트 맨앞에 추가
          ]);
    } on CustomException catch (_) {
      state = state.copyWith(walkStatus: WalkStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
