import 'package:flutter/material.dart';

import '../../../palette.dart';

class SignInPasswordTextFormField extends StatelessWidget {
  final bool isEnabled;
  final TextEditingController controller;

  const SignInPasswordTextFormField({
    super.key,
    required this.isEnabled,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: isEnabled,
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Palette.mainGreen),
        ),
        labelText: "비밀번호",
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: const Icon(Icons.lock),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "비밀번호를 입력해주세요.";
        }
        if (value.length < 6) {
          return "비밀번호는 6글자 이상 입력해주세요.";
        }
        return null;
      },
    );
  }
}
