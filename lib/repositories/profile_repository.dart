import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/user_model.dart';

class ProfileRepository {
  final FirebaseFirestore firebaseFirestore;

  const ProfileRepository({
    required this.firebaseFirestore,
  });

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
