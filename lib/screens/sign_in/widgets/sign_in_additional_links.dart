import 'package:flutter/material.dart';

import '../../../palette.dart';
import '../../sign_up/sign_up_email_screen.dart';
import '../reset_password_screen.dart';

class SignInAdditionalLinks extends StatelessWidget {
  final bool isEnabled;

  const SignInAdditionalLinks({
    super.key,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // 회원가입
        GestureDetector(
          onTap: isEnabled
              ? () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignupEmailScreen(),
                  ))
              : null,
          child: const Text(
            "회원가입",
            style: TextStyle(
              color: Palette.black,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),

        // 비밀번호 재설정
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordScreen(),
                ));
          },
          child: const Text(
            ' / 비밀번호 재설정',
            style: TextStyle(
              color: Palette.mediumGray,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
