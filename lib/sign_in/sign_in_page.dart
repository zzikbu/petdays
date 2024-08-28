import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          children: [
            const Spacer(),

            /// 카카오
            GestureDetector(
              onTap: () {
                print('카카오 로그인 눌림');
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
                    Spacer(),
                    const Text(
                      '카카오로 시작하기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Spacer(),
                    const SizedBox(
                      width: 38,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            /// 애플
            GestureDetector(
              onTap: () {
                print('애플 로그인 눌림');
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
                    Spacer(),
                    const Text(
                      'APPLE로 시작하기',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
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
    );
  }
}
