import 'package:flutter/material.dart';
import 'package:pet_log/components/next_button.dart';
import 'package:pet_log/pallete.dart';
import 'package:pet_log/sign_up/sing_up_pet_info_page.dart';

class SignUpNicknamePage extends StatefulWidget {
  const SignUpNicknamePage({super.key});

  @override
  _SignUpNicknamePageState createState() => _SignUpNicknamePageState();
}

class _SignUpNicknamePageState extends State<SignUpNicknamePage> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isButtonActive = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_updateButtonState);
    _nicknameController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonActive = _nicknameController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Pallete.white,
      appBar: AppBar(
        backgroundColor: Pallete.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: StepProgressIndicator(
              totalSteps: 3,
              currentStep: 1,
              selectedColor: Pallete.black,
              unselectedColor: Pallete.lightGray,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '닉네임을 입력해주세요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Pallete.black,
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
                    color: Pallete.mediumGray,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 80),
                TextField(
                  autocorrect: false,
                  enableSuggestions: false,
                  controller: _nicknameController,
                  maxLength: 6, // 최대 글자 수를 6으로 제한
                  cursorColor: Pallete.mainGreen,
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
                      color: Pallete.lightGray,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Pallete.black,
                        width: 2,
                      ), // 활성화
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Pallete.black,
                        width: 2,
                      ), // 비활성화
                    ),
                  ),
                ),
              ],
            ),
          ),
          Spacer(),
          NextButton(
            isActive: _isButtonActive,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SingUpPetInfoPage()),
              );
            },
            buttonText: "다음",
          ),
        ],
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color selectedColor;
  final Color unselectedColor;

  StepProgressIndicator({
    required this.totalSteps,
    required this.currentStep,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: index < currentStep ? selectedColor : unselectedColor,
            ),
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            height: 3.0,
          ),
        );
      }),
    );
  }
}
