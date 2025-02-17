import 'package:flutter/material.dart';

import '../../../palette.dart';
import '../../sign_in/sign_in_screen.dart';

class SignInRedirectButton extends StatelessWidget {
  final bool isEnabled;

  const SignInRedirectButton({
    super.key,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled
          ? () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const SignInScreen(),
              ))
          : null,
      child: Center(
        child: RichText(
          text: const TextSpan(
            style: TextStyle(
              color: Palette.mediumGray,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            children: [
              TextSpan(text: "이미 회원이신가요? "),
              TextSpan(
                text: "로그인 하기",
                style: TextStyle(
                  color: Palette.subGreen,
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
