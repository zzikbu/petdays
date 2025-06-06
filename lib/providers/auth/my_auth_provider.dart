import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/repository/auth_repository.dart';
import 'package:state_notifier/state_notifier.dart';

import 'auth_state.dart';

class MyAuthProvider extends StateNotifier<AuthState> with LocatorMixin {
  MyAuthProvider() : super(AuthState.init());

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await read<AuthRepository>().sendPasswordResetEmail(email: email);
    } on CustomException catch (_) {
      rethrow;
    }
  }

  /// 회원 탈퇴
  Future<void> deleteAccount({
    String? password,
  }) async {
    try {
      await read<AuthRepository>().deleteAccount(
        password: password,
      );
    } on CustomException catch (_) {
      rethrow;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      await read<AuthRepository>().signOut();
    } on CustomException catch (_) {
      rethrow;
    }
  }

  /// 이메일 회원가입
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await read<AuthRepository>().signUpWithEmail(
        email: email,
        password: password,
      );
    } on CustomException catch (_) {
      // MyAuthProvider.signUp을 호출한 곳에다가 다시 rethrow
      rethrow;
    }
  }

  /// 이메일 로그인
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await read<AuthRepository>().signInWithEmail(
        email: email,
        password: password,
      );
    } on CustomException catch (_) {
      // MyAuthProvider.signIn을 호출한 곳에다가 다시 rethrow
      rethrow;
    }
  }

  /// 구글 로그인
  Future<void> signInWithGoogle() async {
    try {
      await read<AuthRepository>().signInWithGoogle();
    } on CustomException catch (_) {
      rethrow;
    }
  }

  /// 애플 로그인
  Future<void> signInWithApple() async {
    try {
      await read<AuthRepository>().signInWithApple();
    } on CustomException catch (_) {
      rethrow;
    }
  }
}
