import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/user_model.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/repositories/profile_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class UserProvider extends StateNotifier<UserState> with LocatorMixin {
  UserProvider() : super(UserState.init());

  Future<void> getUserInfo() async {
    try {
      String uid = read<User>().uid;
      UserModel userModel =
          await read<ProfileRepository>().getProfile(uid: uid);

      state = state.copyWith(userModel: userModel);
    } on CustomException catch (_) {
      rethrow;
    }
  }
}
