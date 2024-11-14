import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/components/show_error_dialog.dart';
import 'package:petdays/components/next_button.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/auth/my_auth_provider.dart';
import 'package:provider/provider.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  /// Properties
  final TextEditingController _passwordTEC = TextEditingController();

  bool _isActive = false;
  bool _isEnabled = true;

  /// LifeCycle
  @override
  void dispose() {
    _passwordTEC.dispose();

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
                '비밀번호를 입력해주세요',
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
                '탈퇴 시 사용자가 기록한 모든 정보가 삭제됩니다.',
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
                enabled: false,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  labelText: context.read<User>().email,
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                ),
              ),
              SizedBox(height: 20),

              // 비밀번호
              TextFormField(
                controller: _passwordTEC,
                obscureText: true,
                enabled: _isEnabled,
                onChanged: (value) => setState(() {
                  _isActive = value.length >= 6;
                }),
                decoration: InputDecoration(
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Palette.mainGreen),
                  ),
                  labelText: "비밀번호",
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.lock),
                  filled: true,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NextButton(
          isActive: _isActive,
          buttonText: "탈퇴하기",
          onTap: () async {
            try {
              setState(() {
                _isActive = false;
                _isEnabled = false;
              });

              await context
                  .read<MyAuthProvider>()
                  .deleteAccount(password: _passwordTEC.text);
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
