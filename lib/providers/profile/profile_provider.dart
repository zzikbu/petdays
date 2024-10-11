import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/user_model.dart';
import 'package:pet_log/providers/profile/profile_state.dart';
import 'package:pet_log/repositories/profile_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class ProfileProvider extends StateNotifier<ProfileState> with LocatorMixin {
  ProfileProvider() : super(ProfileState.init());

  // 프로필 페이지 데이터 가져오기
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
    }
  }
}
