import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  SharedPreferences prefs;

  final userCollection = FirebaseFirestore.instance.collection('user');

  AuthService(this.prefs);

  /// 현재 유저(로그인 되지 않은 경우 null 반환)
  User? currentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  /// 구글 로그인
  void signInWithGoogle({
    required Function() onSuccess, // 로그인 성공시 호출되는 함수
  }) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      onSuccess(); // 성공 함수 호출
      notifyListeners(); // 로그인 상태 변경 알림
    }).onError((error, StackTrace) {
      print("error $error");
      return;
    });
  }

  /// 로그아웃
  void signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    notifyListeners(); // 로그인 상태 변경 알림
  }

  /// user 컬렉션 create
  void create({required String uid}) async {
    // 유저 컬렉션에 문서를 생성합니다.
    await userCollection.doc(uid).set({
      'uid': uid,
    });

    // pets 서브컬렉션 create
    await userCollection
        .doc(uid) // uid를 가진 사용자 문서에 접근
        .collection('pets')
        .add({
      'selectedPetType': prefs.getString("selectedPetType"),
      'petName': prefs.getString("nickname"),
      'breed': prefs.getString("breed"),
      'birthday': prefs.getString("birthday"),
      'meetingDate': prefs.getString("meetingDate"),
      'gender': prefs.getString("selectedGender"),
      'neutering': prefs.getString("selectedNeutering"),
    });

    // prefs 초기화
    await prefs.clear();
  }

  // 닉네임 저장
  set nickname(String value) {
    prefs.setString("nickname", value);
  }

  // 닉네임 불러오기
  String get nickname {
    return prefs.getString("nickname") ?? "";
  }

  // 선택된 반려동물 종류 저장
  set selectedPetType(String value) {
    prefs.setString("selectedPetType", value);
  }

  // 선택된 반려동물 종류 불러오기
  String get selectedPetType {
    return prefs.getString("selectedPetType") ?? "";
  }

  // 이름 저장
  set name(String value) {
    prefs.setString("name", value);
  }

  // 이름 불러오기
  String get name {
    return prefs.getString("name") ?? "";
  }

  // 품종 저장
  set breed(String value) {
    prefs.setString("breed", value);
  }

  // 품종 불러오기
  String get breed {
    return prefs.getString("breed") ?? "";
  }

  // 생일 저장
  set birthday(String value) {
    prefs.setString("birthday", value);
  }

  // 생일 불러오기
  String get birthday {
    return prefs.getString("birthday") ?? "";
  }

  // 만날 날 저장
  set meetingDate(String value) {
    prefs.setString("meetingDate", value);
  }

  // 만난 날 불러오기
  String get meetingDate {
    return prefs.getString("meetingDate") ?? "";
  }

  // 성별 저장
  set selectedGender(String value) {
    prefs.setString("selectedGender", value);
  }

  // 성별 불러오기
  String get selectedGender {
    return prefs.getString("selectedGender") ?? "";
  }

  // 중성화 여부 저장
  set selectedNeutering(String value) {
    prefs.setString("selectedNeutering", value);
  }

  // 중성화 여부 불러오기
  String get selectedNeutering {
    return prefs.getString("selectedNeutering") ?? "";
  }
}
