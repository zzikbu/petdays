import 'package:flutter/material.dart';

import '../../../palette.dart';

class SignUpButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const SignUpButton({
    super.key,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Palette.mainGreen,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Align(
          alignment: Alignment.center,
          child: Text(
            '회원가입',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Palette.white,
            ),
          ),
        ),
      ),
    );
  }
}
