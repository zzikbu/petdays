import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

import '../../../palette.dart';

class SignInEmailTextFormField extends StatelessWidget {
  final bool isEnabled;
  final TextEditingController controller;

  const SignInEmailTextFormField({
    super.key,
    required this.isEnabled,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: isEnabled,
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Palette.mainGreen),
        ),
        labelText: "이메일",
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: const Icon(Icons.email),
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty || !isEmail(value.trim())) {
          return "이메일을 입력해주세요.";
        }
        return null;
      },
    );
  }
}
