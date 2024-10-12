import 'package:flutter/material.dart';
import 'package:pet_log/palette.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Palette.background,
        title: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Palette.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Palette.feedBorder,
              width: 1,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: TextField(
                autofocus: true,
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: Palette.subGreen,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '검색할 제목을 입력해주세요',
                  hintStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    letterSpacing: -0.4,
                    color: Palette.lightGray,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: Text('검색'),
      ),
    );
  }
}
