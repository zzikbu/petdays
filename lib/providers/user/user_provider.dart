import 'package:firebase_auth/firebase_auth.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/user_model.dart';
import 'package:petdays/providers/user/user_state.dart';
import 'package:petdays/repositories/profile_repository.dart';
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
