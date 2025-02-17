import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignInSocialButtons extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onGoogleLogin;
  final VoidCallback? onAppleLogin;

  const SignInSocialButtons({
    super.key,
    this.isEnabled = true,
    this.onGoogleLogin,
    this.onAppleLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 구글
        GestureDetector(
          onTap: isEnabled ? onGoogleLogin : null,
          child: SvgPicture.asset(
            width: 56,
            height: 56,
            'assets/icons/ic_login_google.svg',
          ),
        ),

        // 애플
        if (Platform.isIOS)
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: GestureDetector(
              onTap: isEnabled ? onAppleLogin : null,
              child: SvgPicture.asset(
                width: 56,
                height: 56,
                'assets/icons/ic_login_apple.svg',
              ),
            ),
          ),
      ],
    );
  }
}
