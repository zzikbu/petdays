import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/show_error_dialog.dart';
import '../../common/widgets/sign_text_form_field.dart';
import '../../exceptions/custom_exception.dart';
import '../../palette.dart';
import '../../providers/auth/my_auth_provider.dart';
import 'widgets/sign_in_additional_links.dart';
import 'widgets/sign_in_button.dart';
import 'widgets/sign_in_logo.dart';
import 'widgets/sign_in_social_buttons.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController _emailTEC = TextEditingController();
  final TextEditingController _passwordTEC = TextEditingController();

  late final MyAuthProvider _authProvider;

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    _authProvider = context.read<MyAuthProvider>();
  }

  // 이메일 로그인 로직
  Future<void> _handleSignIn() async {
    final form = _globalKey.currentState;

    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isEnabled = false;
      _autovalidateMode = AutovalidateMode.always;
    });

    try {
      await _authProvider.signIn(
        email: _emailTEC.text,
        password: _passwordTEC.text,
      );
    } on CustomException catch (e) {
      setState(() {
        _isEnabled = true;
      });
      showErrorDialog(context, e);
    }
  }

  // 소셜 로그인 로직
  Future<void> _handleSocialLogin(Future<void> Function() socialLoginMethod) async {
    if (!_isEnabled) return;

    setState(() {
      _isEnabled = false;
    });

    try {
      await socialLoginMethod();
    } on CustomException catch (e) {
      showErrorDialog(context, e);
    } finally {
      setState(() {
        _isEnabled = true;
      });
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
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _globalKey,
                  autovalidateMode: _autovalidateMode,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 로고
                        const SignInLogo(),
                        const SizedBox(height: 40),

                        // 이메일
                        SignTextFormField(
                          controller: _emailTEC,
                          isEnabled: _isEnabled,
                          labelText: "이메일",
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          customValidator: SignTextFormField.emailValidator,
                          textInputAction: TextInputAction.next,
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
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: 20),

                        // 이메일 로그인
                        SignInButton(
                          isEnabled: _isEnabled,
                          onTap: _handleSignIn,
                        ),
                        const SizedBox(height: 14),

                        // 회원가입 / 비밀번호 재설정
                        SignInAdditionalLinks(isEnabled: _isEnabled),
                        const SizedBox(height: 20),

                        // 구분선
                        const Divider(height: 1, color: Palette.lightGray),
                        const SizedBox(height: 20),

                        // 소셜 로그인
                        SignInSocialButtons(
                          isEnabled: _isEnabled,
                          onGoogleLogin: () => _handleSocialLogin(
                            () => _authProvider.signInWithGoogle(),
                          ),
                          onAppleLogin: () => _handleSocialLogin(
                            () => _authProvider.signInWithApple(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
