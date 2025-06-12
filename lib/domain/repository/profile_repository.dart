import 'dart:typed_data';

import '../model/user_model.dart';

abstract interface class ProfileRepository {
  /// 프로필 이미지 수정/삭제
  Future<void> updateProfileImage({
    required String uid,
    required Uint8List? imageFile, // null이면 삭제
  });

  /// 닉네임 수정
  Future<void> updateNickname({
    required String uid,
    required String newNickname,
  });

  /// 접속 중인 사용자 정보 가져오기
  Future<UserModel> getProfile({
    required String uid,
  });
}
