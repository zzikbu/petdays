import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/repositories/auth_repository.dart';
import 'package:state_notifier/state_notifier.dart';

import 'auth_state.dart';

class MyAuthProvider extends StateNotifier<AuthState> with LocatorMixin {
  MyAuthProvider() : super(AuthState.init());

  // LocatorMixin에 정의되어 있는 함수
  @override
  void update(Locator watch) {
    // provider에 등록된 상태관리를 하고있는 User값이 변경이 되면
    // update함수가 자동으로 호출이 됨
    final user = watch<User?>();

    // 회원가입 상황일 때(User는 반환하지만, emailVerified = false)는 return
    if (user != null && !user.emailVerified) {
      return;
    }

    // 미인증 이메일로 로그인 할 때 return
    if (user == null && state.authStatus == AuthStatus.unauthenticated) {
      return;
    }

    if (user != null) {
      // 로그인 상태로 변경
      state = state.copyWith(authStatus: AuthStatus.authenticated);
    } else {
      // 로그아웃 상태로 변경
      state = state.copyWith(authStatus: AuthStatus.unauthenticated);
    }
  }

  /// 회원 탈퇴
  Future<void> deleteAccount({
    String? password,
  }) async {
    try {
      String uid = read<User>().uid;

      await read<AuthRepository>().deleteAccount(
        uid: uid,
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
}
