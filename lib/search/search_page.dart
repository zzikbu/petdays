import 'package:flutter/material.dart';
import 'package:pet_log/pallete.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Pallete.background,
        title: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Pallete.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Pallete.feedBorder,
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
                cursorColor: Pallete.subGreen,
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
                    color: Pallete.lightGray,
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
