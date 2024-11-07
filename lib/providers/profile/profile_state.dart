import 'package:petdays/models/user_model.dart';

enum ProfileStatus {
  init,
  submitting,
  fetching,
  success,
  error,
}

class ProfileState {
  final ProfileStatus profileStatus;
  final UserModel userModel;

  const ProfileState({
    required this.profileStatus,
    required this.userModel,
  });

  factory ProfileState.init() {
    return ProfileState(
      profileStatus: ProfileStatus.init,
      userModel: UserModel.init(),
    );
  }

  ProfileState copyWith({
    ProfileStatus? profileStatus,
    UserModel? userModel,
  }) {
    return ProfileState(
      profileStatus: profileStatus ?? this.profileStatus,
      userModel: userModel ?? this.userModel,
    );
  }
}
