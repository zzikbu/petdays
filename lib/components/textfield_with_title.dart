import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../pallete.dart';

class TextFieldWithTitle extends StatefulWidget {
  final String labelText;
  final int? maxLength; // 옵셔널
  final String hintText;
  final TextInputType keyboardType;
  final bool isCupertinoPicker;
  final List<String>? pickerItems; // 옵셔널
  final String? selectedValue; // 옵셔널
  final ValueChanged<String?>? onChanged; // 옵셔널

  const TextFieldWithTitle({
    super.key,
    required this.labelText,
    this.maxLength,
    required this.hintText,
    this.keyboardType = TextInputType.text, // 기본값 설정
    this.isCupertinoPicker = false, // 기본값 설정
    this.pickerItems,
    this.onChanged,
    this.selectedValue,
  });

  @override
  _TextFieldWithTitleState createState() => _TextFieldWithTitleState();
}

class _TextFieldWithTitleState extends State<TextFieldWithTitle> {
  @override
  Widget build(BuildContext context) {
    if (widget.isCupertinoPicker) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Pallete.black,
              letterSpacing: -0.45,
            ),
          ),
          GestureDetector(
            onTap: () => _showCupertinoPicker(context),
            child: AbsorbPointer(
              child: TextField(
                autocorrect: false,
                enableSuggestions: false,
                controller: TextEditingController(text: widget.selectedValue),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: -0.4,
                    color: Pallete.lightGray,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Pallete.black, width: 2),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Pallete.black, width: 2),
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: Pallete.black,
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  letterSpacing: -0.4,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Pallete.black,
              letterSpacing: -0.45,
            ),
          ),
          TextField(
            autocorrect: false,
            enableSuggestions: false,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            cursorColor: Pallete.subGreen,
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
                color: Pallete.lightGray,
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Pallete.black, width: 2),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Pallete.black, width: 2),
              ),
            ),
          ),
        ],
      );
    }
  }

  void _showCupertinoPicker(BuildContext context) {
    FocusScope.of(context).unfocus(); // 키보드 내리기
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return CupertinoActionSheet(
          actions: widget.pickerItems!.map((String item) {
            return CupertinoActionSheetAction(
              child: Text(
                item,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Pallete.black,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                widget.onChanged?.call(item);
              },
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              '취소',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: Colors.red, // 취소 버튼의 글씨 색상
              ),
            ),
          ),
        );
      },
    );
  }
}
