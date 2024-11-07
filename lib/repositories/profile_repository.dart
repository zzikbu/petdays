import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/user_model.dart';

class ProfileRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const ProfileRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  // 프로필 이미지 수정/삭제
  Future<void> updateProfileImage({
    required String uid,
    required Uint8List? imageFile, // null이면 삭제
  }) async {
    try {
      String? downloadURL = null;
      final ref = firebaseStorage.ref().child('profile').child(uid);

      if (imageFile != null) {
        // 이미지 수정
        downloadURL = await (await ref.putData(imageFile)).ref.getDownloadURL();
      } else {
        // 이미지 삭제
        await ref.delete();
      }

      // firestore 업데이트
      await firebaseFirestore.collection("users").doc(uid).update({
        "profileImage": downloadURL,
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
