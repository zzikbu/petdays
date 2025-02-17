import 'package:flutter/material.dart';
import 'package:string_validator/string_validator.dart';

import '../palette.dart';

class SignTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final bool isEnabled;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? customValidator;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;

  const SignTextFormField({
    super.key,
    this.controller,
    this.isEnabled = true,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.customValidator,
    this.textInputAction,
    this.focusNode,
    this.onEditingComplete,
  });

  // 이메일 검증
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty || !isEmail(value.trim())) {
      return "이메일을 입력해주세요.";
    }
    return null;
  }

  // 비밀번호 검증
  static String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "비밀번호를 입력해주세요.";
    }
    if (value.length < 6) {
      return "비밀번호는 6글자 이상 입력해주세요.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      enabled: isEnabled,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Palette.mainGreen),
        ),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.black),
        prefixIcon: Icon(prefixIcon),
        filled: true,
      ),
      validator: customValidator,
    );
  }
}
