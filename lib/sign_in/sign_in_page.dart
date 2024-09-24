import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/components/custom_bottom_navigation_bar.dart';
import 'package:pet_log/pallete.dart';
import 'package:pet_log/service/auth_service.dart';
import 'package:pet_log/sign_up/sign_up_nickname_page.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(builder: (context, authService, child) {
      print(authService.currentUser());
      return Scaffold(
        backgroundColor: Pallete.white,
        body: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: Column(
              children: [
                const Spacer(),

                /// 구글
                GestureDetector(
                  onTap: () {
                    authService.signInWithGoogle(
                      onSuccess: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("로그인 성공"),
                        ));

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CustomBottomNavigationBar()),
                        );
                      },
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(6.0),
                        border: Border.all(color: Color(0xFF747775))),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: SvgPicture.asset(
                            'assets/icons/ic_login_google.svg',
                          ),
                        ),
                        Expanded(
                          child: const Text(
                            'Google로 시작하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 38),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// 카카오
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpNicknamePage()),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE500),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: SvgPicture.asset(
                            'assets/icons/ic_login_kakao.svg',
                          ),
                        ),
                        Expanded(
                          child: const Text(
                            'Kakao로 시작하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 38),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// 애플
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpNicknamePage()),
                    );
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF050708),
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 21.0),
                          child: SvgPicture.asset(
                            'assets/icons/ic_login_apple.svg',
                          ),
                        ),
                        Expanded(
                          child: const Text(
                            'APPLE로 시작하기',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 36,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
