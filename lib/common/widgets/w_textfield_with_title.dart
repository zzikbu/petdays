import 'package:flutter/material.dart';

import '../../palette.dart';

class TextFieldWithTitleWidget extends StatelessWidget {
  final String labelText;
  final int? maxLength;
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool isMultiLine;
  final bool? enabled;
  final VoidCallback? onTap;

  const TextFieldWithTitleWidget({
    super.key,
    required this.labelText,
    this.maxLength,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.isMultiLine = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Palette.black,
            letterSpacing: -0.45,
          ),
        ),
        TextField(
          controller: controller,
          autocorrect: false,
          enableSuggestions: false,
          maxLength: maxLength,
          maxLines: isMultiLine ? null : 1, // null이면 여러 줄 허용
          enabled: enabled,
          readOnly: onTap != null,
          onTap: onTap,
          keyboardType: isMultiLine ? TextInputType.multiline : keyboardType, // multiline일 경우
          cursorColor: Palette.subGreen,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            letterSpacing: -0.4,
            color: Palette.black,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              letterSpacing: -0.4,
              color: Palette.lightGray,
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Palette.black, width: 2),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Palette.black, width: 2),
            ),
            disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Palette.black, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
