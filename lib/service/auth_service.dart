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
}
