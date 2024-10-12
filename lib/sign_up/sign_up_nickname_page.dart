import 'package:flutter/material.dart';
import 'package:pet_log/components/next_button.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/sign_up/sign_up_select_pet_type_page.dart';

class SignUpNicknamePage extends StatefulWidget {
  final bool isEditMode;

  const SignUpNicknamePage({
    super.key,
    required this.isEditMode,
  });

  @override
  _SignUpNicknamePageState createState() => _SignUpNicknamePageState();
}

class _SignUpNicknamePageState extends State<SignUpNicknamePage> {
  final TextEditingController _nicknameTEC = TextEditingController();

  bool _isActive = false; // 작성하기 버튼 활성화 여부

  void _checkBottomActive() {
    setState(() {
      _isActive = _nicknameTEC.text.isNotEmpty && _nicknameTEC.text.length > 1;
    });
  }

  @override
  void initState() {
    super.initState();

    _nicknameTEC.addListener(_checkBottomActive);
  }

  @override
  void dispose() {
    _nicknameTEC.removeListener(_checkBottomActive);
    _nicknameTEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 다른 곳 클릭 시 키보드 내리기
      child: Scaffold(
        backgroundColor: Palette.white,
        appBar: AppBar(
          backgroundColor: Palette.white,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // 제목
              Text(
                '닉네임을 입력해주세요',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Palette.black,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 5),

              // 설명
              Text(
                '두글 자 이상, 최대 여섯 글자까지 가능합니다.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Palette.mediumGray,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 100),

              // 입력 칸
              TextField(
                controller: _nicknameTEC,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 6, // 최대 글자 수를 6으로 제한
                cursorColor: Palette.mainGreen,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
                decoration: InputDecoration(
                  hintText: '홍길동',
                  hintStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w500,
                    color: Palette.lightGray,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Palette.black, width: 2), // 활성화
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Palette.black, width: 2), // 비활성화
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NextButton(
          isActive: _isActive,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SignUpSelectPetTypePage()),
            );
          },
          buttonText: widget.isEditMode ? "수정하기" : "시작하기",
        ),
      ),
    );
  }
}
