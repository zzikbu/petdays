import 'dart:typed_data';

import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/user_model.dart';
import 'package:petdays/providers/profile/profile_state.dart';
import 'package:petdays/repositories/profile_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class ProfileProvider extends StateNotifier<ProfileState> with LocatorMixin {
  ProfileProvider() : super(ProfileState.init());

  // 프로필 이미지 수정/삭제
  Future<void> updateProfileImage({
    required String uid,
    required Uint8List? imageFile, // null이면 삭제
  }) async {
    state = state.copyWith(profileStatus: ProfileStatus.submitting);

    try {
      await read<ProfileRepository>().updateProfileImage(
        uid: uid,
        imageFile: imageFile,
      );

      state = state.copyWith(profileStatus: ProfileStatus.success);
    } on CustomException catch (_) {
      state = state.copyWith(profileStatus: ProfileStatus.error);
      rethrow;
    }
  }

  // 닉네임 수정
  Future<void> updateNickname({
    required String uid,
    required String newNickname,
  }) async {
    state = state.copyWith(profileStatus: ProfileStatus.fetching); // 상태 변경

    try {
      await read<ProfileRepository>().updateNickname(
        uid: uid,
        newNickname: newNickname,
      );

      state = state.copyWith(profileStatus: ProfileStatus.success); // 상태 변경
    } on CustomException catch (_) {
      state = state.copyWith(profileStatus: ProfileStatus.error); // 에러 상태로 변경
      rethrow;
    }
  }

  // 프로필 데이터 가져오기
  Future<void> getProfile({
    required String uid,
  }) async {
    state = state.copyWith(profileStatus: ProfileStatus.fetching); // 상태 변경

    try {
      UserModel userModel =
          await read<ProfileRepository>().getProfile(uid: uid); // 접속 중인 사용자 정보

      state = state.copyWith(
        profileStatus: ProfileStatus.success, // 상태 변경
        userModel: userModel,
      );
    } on CustomException catch (_) {
      state = state.copyWith(profileStatus: ProfileStatus.error); // 에러 상태로 변경
      rethrow;
    }
  }
}
