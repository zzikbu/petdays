import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignInLogo extends StatelessWidget {
  const SignInLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      width: 140,
      height: 140,
      'assets/icons/ic_app_logo.svg',
    );
  }
}
