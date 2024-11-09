import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../palette.dart';

class TextFieldWithTitle extends StatefulWidget {
  final String labelText;
  final int? maxLength; // 옵셔널
  final String hintText;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final bool isMultiLine;
  final bool? enabled;

  const TextFieldWithTitle({
    super.key,
    required this.labelText,
    this.maxLength,
    required this.hintText,
    this.keyboardType = TextInputType.text, // 기본값 설정
    this.controller,
    this.isMultiLine = false, // 기본값 false
    this.enabled = true,
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
        TextFormField(
          controller: widget.controller,
          autocorrect: false,
          enableSuggestions: false,
          maxLength: widget.maxLength,
          maxLines: widget.isMultiLine ? null : 1, // null이면 여러 줄 허용
          enabled: widget.enabled,
          keyboardType: widget.isMultiLine
              ? TextInputType.multiline
              : widget.keyboardType, // multiline일 경우
          cursorColor: Palette.subGreen,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            fontSize: 16,
            letterSpacing: -0.4,
            color: Palette.black,
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
            // filled: true,
            // fillColor: Colors.transparent,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Palette.black, width: 2),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Palette.black, width: 2),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Palette.black, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
