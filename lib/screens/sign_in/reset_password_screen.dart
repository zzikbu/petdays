import 'package:flutter/material.dart';
import 'package:petdays/components/show_error_dialog.dart';
import 'package:petdays/components/w_bottom_confirm_button.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/auth/my_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  /// Properties
  final TextEditingController _emailTEC = TextEditingController();

  bool _isActive = false;
  bool _isEnabled = true;

  /// LifeCycle
  @override
  void dispose() {
    _emailTEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 다른 곳 클릭 시 키보드 내리기
      child: Scaffold(
        appBar: AppBar(backgroundColor: Palette.background),
        backgroundColor: Palette.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30),

              // 제목
              Text(
                '이메일을 입력해주세요',
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
                '해당 이메일로 비밀번호 재설정 링크가 발송됩니다.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Palette.mediumGray,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 40),

              // 이메일
              TextFormField(
                controller: _emailTEC,
                enabled: _isEnabled,
                onChanged: (value) => setState(() {
                  _isActive = isEmail(value.trim());
                }),
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Palette.mainGreen),
                  ),
                  labelText: "이메일",
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomConfirmButtonWidget(
          isActive: _isActive,
          buttonText: "전송하기",
          onConfirm: () async {
            try {
              setState(() {
                _isActive = false;
                _isEnabled = false;
              });

              await context
                  .read<MyAuthProvider>()
                  .sendPasswordResetEmail(email: _emailTEC.text.trim());

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("전송 완료")));

              Navigator.pop(context);
            } on CustomException catch (e) {
              showErrorDialog(context, e);
              setState(() {
                _isActive = true;
                _isEnabled = true;
              });
            }
          },
        ),
      ),
    );
  }
}
