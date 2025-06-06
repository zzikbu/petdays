import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../exceptions/custom_exception.dart';
import '../models/user_model.dart';
import 'profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;

  const ProfileRepositoryImpl({
    required FirebaseStorage firebaseStorage,
    required FirebaseFirestore firebaseFirestore,
  })  : _firebaseStorage = firebaseStorage,
        _firebaseFirestore = firebaseFirestore;

  @override
  Future<void> updateProfileImage({
    required String uid,
    required Uint8List? imageFile, // null이면 삭제
  }) async {
    try {
      String? downloadURL;
      final ref = _firebaseStorage.ref().child('profile').child(uid);

      if (imageFile != null) {
        // 이미지 수정
        downloadURL = await (await ref.putData(imageFile)).ref.getDownloadURL();
      } else {
        // 이미지 삭제
        await ref.delete();
      }

      // firestore 업데이트
      await _firebaseFirestore.collection("users").doc(uid).update({
        "profileImage": downloadURL,
      });
    } on FirebaseException {
      throw const CustomException(
        title: '프로필 이미지',
        message: '프로필 이미지 변경에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "프로필 이미지",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> updateNickname({
    required String uid,
    required String newNickname,
  }) async {
    try {
      // 닉네임 중복 체크
      QuerySnapshot<Map<String, dynamic>> duplicateCheck = await _firebaseFirestore
          .collection("users")
          .where("nickname", isEqualTo: newNickname)
          .get();

      // 중복되면 throw
      if (duplicateCheck.docs.isNotEmpty) {
        throw const CustomException(
          title: "닉네임 중복",
          message: "이미 사용 중인 닉네임입니다.",
        );
      }

      await _firebaseFirestore.collection("users").doc(uid).update({
        "nickname": newNickname,
      });
    } on CustomException {
      rethrow;
    } on FirebaseException {
      throw const CustomException(
        title: '닉네임',
        message: '닉네임 변경에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "닉네임",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<UserModel> getProfile({
    required String uid,
  }) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firebaseFirestore.collection("users").doc(uid).get();

      return UserModel.fromMap(snapshot.data()!);
    } on FirebaseException {
      throw const CustomException(
        title: '사용자 정보',
        message: '사용자 정보 가져오기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "사용자 정보",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }
}
