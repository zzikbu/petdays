abstract interface class AuthRepository {
  /// 이메일 회원가입
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  });

  /// 이메일 로그인
  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  /// 구글 로그인
  Future<void> signInWithGoogle();

  /// 애플 로그인
  Future<void> signInWithApple();

  /// 로그아웃
  Future<void> signOut();

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail({
    required String email,
  });

  /// 회원 탈퇴
  Future<void> deleteAccount({
    String? password,
  });

  /// 랜덤 닉네임 생성
  Future<String> generateRandomNickname();
}
