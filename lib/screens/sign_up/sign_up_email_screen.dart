import 'package:flutter/material.dart';
import 'package:petdays/screens/sign_up/widgets/sign_in_redirect_button.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/show_error_dialog.dart';
import '../../common/widgets/sign_text_form_field.dart';
import '../../exceptions/custom_exception.dart';
import '../../palette.dart';
import '../../providers/auth/my_auth_provider.dart';
import '../sign_in/sign_in_screen.dart';
import 'widgets/sign_up_button.dart';

class SignupEmailScreen extends StatefulWidget {
  const SignupEmailScreen({super.key});

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController _emailTEC = TextEditingController();
  final TextEditingController _passwordTEC = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isEnabled = true;

  // 회원가입 로직
  Future<void> _handleSignUp() async {
    final form = _globalKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isEnabled = false;
      _autovalidateMode = AutovalidateMode.always;
    });

    try {
      await context.read<MyAuthProvider>().signUp(
            email: _emailTEC.text,
            password: _passwordTEC.text,
          );

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SignInScreen(),
          ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("인증 메일을 전송했습니다."),
          duration: Duration(seconds: 120),
        ),
      );
    } on CustomException catch (e) {
      setState(() {
        _isEnabled = true;
      });

      showErrorDialog(context, e);
    }
  }

  @override
  void dispose() {
    _emailTEC.dispose();
    _passwordTEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Palette.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _globalKey,
                autovalidateMode: _autovalidateMode,
                child: ListView(
                  shrinkWrap: true,
                  reverse: true,
                  children: [
                    // 이메일
                    SignTextFormField(
                      controller: _emailTEC,
                      isEnabled: _isEnabled,
                      labelText: "이메일",
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      customValidator: SignTextFormField.emailValidator,
                    ),
                    const SizedBox(height: 20),

                    // 비밀번호
                    SignTextFormField(
                      controller: _passwordTEC,
                      isEnabled: _isEnabled,
                      labelText: "비밀번호",
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      customValidator: SignTextFormField.passwordValidator,
                    ),
                    const SizedBox(height: 20),

                    // 비밀번호 확인
                    SignTextFormField(
                      isEnabled: _isEnabled,
                      labelText: "비밀번호 확인",
                      prefixIcon: Icons.lock,
                      obscureText: true,
                      customValidator: (value) {
                        if (_passwordTEC.text != value) {
                          return "비밀번호가 일치하지 않습니다.";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // 회원가입
                    SignUpButton(
                      isEnabled: _isEnabled,
                      onTap: _handleSignUp,
                    ),
                    const SizedBox(height: 40),

                    // 로그인 하기
                    SignInRedirectButton(isEnabled: _isEnabled),
                  ].reversed.toList(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
