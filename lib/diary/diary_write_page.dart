import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/palette.dart';

import '../components/next_button.dart';
import '../components/textfield_with_title.dart';

class DiaryWritePage extends StatefulWidget {
  final bool isEditMode;

  const DiaryWritePage({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<DiaryWritePage> createState() => _DiaryWritePageState();
}

class _DiaryWritePageState extends State<DiaryWritePage> {
  bool _isLock = true;

  void _lockTap() {
    setState(() {
      _isLock = !_isLock;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Palette.background,
        title: Text(
          "성장일기",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Palette.black,
            letterSpacing: -0.5,
          ),
        ),
        actions: !widget.isEditMode
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    onTap: () {
                      _lockTap();
                    },
                    child: _isLock
                        ? SvgPicture.asset('assets/icons/ic_lock.svg')
                        : SvgPicture.asset('assets/icons/ic_unlock.svg'),
                  ),
                ),
              ]
            : [],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15),
              Text(
                '사진',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Palette.black,
                  letterSpacing: -0.45,
                ),
              ),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Palette.lightGray,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Palette.lightGray,
                ),
              ),
              SizedBox(height: 40),
              TextFieldWithTitle(
                labelText: '제목',
                hintText: '제목을 입력해주세요',
              ),
              SizedBox(height: 40),
              Text(
                '내용',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Palette.black,
                  letterSpacing: -0.45,
                ),
              ),
              Scrollbar(
                child: TextField(
                  autocorrect: false,
                  enableSuggestions: false,
                  cursorColor: Palette.subGreen,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '내용을 입력해주세요',
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
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NextButton(
        isActive: false,
        onTap: () {
          print("작성하기 눌림");
        },
        buttonText: widget.isEditMode ? "수정하기" : "작성하기",
      ),
    );
  }
}
