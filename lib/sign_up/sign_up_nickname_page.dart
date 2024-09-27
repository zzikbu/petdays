import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_log/components/next_button.dart';
import 'package:pet_log/components/step_progress_indicator.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/service/auth_service.dart';
import 'package:provider/provider.dart';

class SignUpNicknamePage extends StatefulWidget {
  const SignUpNicknamePage({super.key});

  @override
  _SignUpNicknamePageState createState() => _SignUpNicknamePageState();
}

class _SignUpNicknamePageState extends State<SignUpNicknamePage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isNextButtonActive = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_updateButtonState);
    _nicknameController.text = context.read<AuthService>().nickname;
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_updateButtonState);
    _nicknameController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isNextButtonActive = _nicknameController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Palette.white,
      appBar: AppBar(
        backgroundColor: Palette.white,
      ),
      bottomNavigationBar: NextButton(
        isActive: _isNextButtonActive,
        onTap: () {
          context.read<AuthService>().nickname = _nicknameController.text;
          context.go('/sign_up/pet_type');
        },
        buttonText: "다음",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            StepProgressIndicator(
              totalSteps: 3,
              currentStep: 1,
              selectedColor: Palette.black,
              unselectedColor: Palette.lightGray,
            ),
            SizedBox(height: 30),
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
            Text(
              '최대 여섯글자까지 입력가능합니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Palette.mediumGray,
                letterSpacing: -0.6,
              ),
            ),
            SizedBox(height: 80),
            TextField(
              autocorrect: false,
              enableSuggestions: false,
              controller: _nicknameController,
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
                  borderSide: BorderSide(color: Palette.black, width: 2), // 활성화
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
    );
  }
}
