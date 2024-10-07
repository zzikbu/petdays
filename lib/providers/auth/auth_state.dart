enum AuthStatus {
  authenticated, // 로그인 상태
  unauthenticated, // 로그아웃 상태
}

class AuthState {
  final AuthStatus authStatus;

  AuthState({
    required this.authStatus,
  });

  factory AuthState.init() {
    return AuthState(authStatus: AuthStatus.unauthenticated);
  }

  AuthState copyWith({
    AuthStatus? authStatus,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
    );
  }
}
