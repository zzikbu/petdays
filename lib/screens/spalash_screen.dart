import 'package:flutter/material.dart';
import 'package:petdays/screens/main_screen.dart';
import 'package:petdays/providers/auth/auth_state.dart';
import 'package:petdays/screens/sign_in/sign_in_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthState>().authStatus;

    // build 함수 내 위젯들이 전부 다 완성되기 이전에
    // 화면 이동을 하려고 하면 에러가 발생함
    // WidgetsBinding.instance.addPostFrameCallback 을 사용해 해결
    // (위젯을 전부 완성을 시킨 후)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // pushAndRemoveUntil: 화면 위젯들을 전부 없앤 후 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => authStatus == AuthStatus.authenticated
              ? MainScreen()
              : SignInScreen(),
        ),
        (route) => route.isFirst, // 첫번째 화면은 남겨둔 채로 (splash 화면 남기기)
      );
    });

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
