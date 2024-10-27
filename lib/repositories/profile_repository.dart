import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore firebaseFirestore;

  const ProfileRepository({
    required this.firebaseFirestore,
  });

  // 닉네임 수정
  Future<void> updateNickname({
    required String uid,
    required String newNickname,
  }) async {
    try {
      // 닉네임 중복 체크
      QuerySnapshot<Map<String, dynamic>> duplicateCheck =
          await firebaseFirestore
              .collection("users")
              .where("nickname", isEqualTo: newNickname)
              .get();

      // 중복되면 throw
      if (duplicateCheck.docs.isNotEmpty) {
        throw CustomException(
          code: "닉네임 중복",
          message: "이미 사용 중인 닉네임입니다.",
        );
      }

      await firebaseFirestore.collection("users").doc(uid).update({
        "nickname": newNickname,
      });
    } on FirebaseException catch (e) {
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }

  // 접속 중인 사용자 정보 가져오기
  Future<UserModel> getProfile({
    required String uid,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await firebaseFirestore.collection("users").doc(uid).get();

      return UserModel.fromMap(snapshot.data()!);
    } on FirebaseException catch (e) {
      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }
}
