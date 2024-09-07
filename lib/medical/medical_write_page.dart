import 'package:flutter/material.dart';
import 'package:pet_log/pallete.dart';

import '../components/next_button.dart';
import '../components/textfield_with_title.dart';

class MedicalWritePage extends StatefulWidget {
  final bool isEditMode;

  const MedicalWritePage({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<MedicalWritePage> createState() => _MedicalWritePageState();
}

class _MedicalWritePageState extends State<MedicalWritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Pallete.background,
        title: Text(
          "진료기록",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Pallete.black,
            letterSpacing: -0.5,
          ),
        ),
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
                  color: Pallete.black,
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
                    color: Pallete.lightGray,
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.add,
                  color: Pallete.lightGray,
                ),
              ),
              SizedBox(height: 40),
              TextFieldWithTitle(
                labelText: '진료일 *',
                hintText: '2000-08-07 형식으로 입력해주세요',
              ),
              SizedBox(height: 40),
              TextFieldWithTitle(
                labelText: '이유 *',
                hintText: '병원에 간 이유를 입력해주세요',
              ),
              SizedBox(height: 40),
              TextFieldWithTitle(
                labelText: '병원',
                hintText: '병원 이름을 입력해주세요',
              ),
              SizedBox(height: 40),
              TextFieldWithTitle(
                labelText: '수의사',
                hintText: '수의사 이름을 입력해주세요',
              ),
              SizedBox(height: 40),
              Text(
                '메모',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: Pallete.black,
                  letterSpacing: -0.45,
                ),
              ),
              Scrollbar(
                child: TextField(
                  autocorrect: false,
                  enableSuggestions: false,
                  cursorColor: Pallete.subGreen,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '특이사항이나 메모를 입력해주세요',
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
