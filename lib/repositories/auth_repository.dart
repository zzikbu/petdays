import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_log/exceptions/custom_exception.dart';

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  AuthRepository({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  /// 랜덤 닉네임 생성
  Future<String> randomNickname() async {
    // 감정 리스트
    List<String> emotions = [
      "상냥한",
      "착한",
      "행복한",
      "슬픈",
      "용감한",
      "사랑스러운",
      "활발한",
      "차분한",
      "겸손한",
      "신나는",
      "지혜로운",
      "재밌는",
      "똑똑한",
      "충성스러운",
      "조용한",
      "적극적인",
      "기운찬",
      "자상한",
      "귀여운",
      "명랑한"
    ];

    // 동물 리스트
    List<String> animals = [
      "악어",
      "토끼",
      "호랑이",
      "코끼리",
      "사자",
      "늑대",
      "여우",
      "고양이",
      "강아지",
      "곰",
      "다람쥐",
      "사슴",
      "기린",
      "표범",
      "수달",
      "너구리",
      "펭귄",
      "코알라",
      "돌고래",
      "하마"
    ];

    String generatedNickname = "";
    bool isUnique = false;

    CollectionReference<Map<String, dynamic>> userCollection =
        firebaseFirestore.collection("users");

    // 중복되지 않는 닉네임이 생성될 때까지 반복
    while (!isUnique) {
      String randomEmotion = emotions[Random().nextInt(emotions.length)];
      String randomAnimal = animals[Random().nextInt(animals.length)];
      int randomNumber = Random().nextInt(1000); // 0부터 999까지의 랜덤 숫자

      generatedNickname = '$randomEmotion$randomAnimal$randomNumber';

      // 닉네임 중복 확인
      QuerySnapshot querySnapshot = await userCollection
          .where('nickname', isEqualTo: generatedNickname)
          .get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true; // 중복되지 않는 닉네임이 발견되면 루프 탈출
      }
    }

    return generatedNickname;
  }

  /// 로그아웃
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  /// 이메일 로그인
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

  /// 이메일 회원가입
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

      String nickname = await randomNickname();

      // uid를 문서 ID로 설정 후 파이어스토어에 저장
      await firebaseFirestore.collection("users").doc(uid).set({
        "uid": uid,
        "email": email,
        "profileImage": null,
        "nickname": nickname,
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
