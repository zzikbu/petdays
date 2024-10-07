import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_log/exceptions/custom_exception.dart';

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  const AuthRepository({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  /// 로그인
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 인증 메일 클릭 여부
      bool isVerified = userCredential.user!.emailVerified;
      if (!isVerified) {
        await userCredential.user!.sendEmailVerification();
        await firebaseAuth.signOut();
        throw CustomException(
          code: "Exception",
          message: "인증되지 않은 이메일",
        );
      }
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

  /// 회원가입
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // 회원가입과 동시에 로그인이 됨
      UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await userCredential.user!.sendEmailVerification(); // 인증 메일 보내기

      // uid를 문서 ID로 설정 후 파이어스토어에 저장
      await firebaseFirestore.collection("users").doc(uid).set({
        "uid": uid,
        "email": email,
        "profileImage": null,
        "nickname": null,
        "walkCount": 0,
        "diaryCount": 0,
        "medicalCount": 0,
        "likes": [], // 좋아요한 글
        "blocks": [] // 차단한 멤버 uid
      });

      firebaseAuth.signOut(); // 회원가입과 동시에 로그인이 되기 때문에 로그아웃 (메일 인증 전)
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
