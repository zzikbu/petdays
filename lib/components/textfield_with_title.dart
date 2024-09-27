import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../palette.dart';

class TextFieldWithTitle extends StatefulWidget {
  final String labelText;
  final int? maxLength; // 옵셔널
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const TextFieldWithTitle({
    super.key,
    required this.labelText,
    this.maxLength,
    required this.hintText,
    this.keyboardType = TextInputType.text, // 기본값 설정
    this.controller,
  });

  @override
  _TextFieldWithTitleState createState() => _TextFieldWithTitleState();
}

class _TextFieldWithTitleState extends State<TextFieldWithTitle> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Palette.black,
            letterSpacing: -0.45,
          ),
        ),
        TextField(
          controller: widget.controller,
          autocorrect: false,
          enableSuggestions: false,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          cursorColor: Palette.subGreen,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            letterSpacing: -0.4,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 16,
              letterSpacing: -0.4,
              color: Palette.lightGray,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Palette.black, width: 2),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Palette.black, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
