import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/auth/my_auth_provider.dart';
import 'package:pet_log/screens/sign_up/sign_up_email_screen.dart';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>(); // 검증 로직을 위한

  final TextEditingController _emailTEC = TextEditingController();
  final TextEditingController _passwordTEC = TextEditingController();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool _isEnabled = true; // 회원가입 버튼 누르면 텍스트필드 & 버튼 비활성화를 위한

  @override
  void dispose() {
    // TextEditingController는 화면이 dispose되도 자동으로 메모리에서 사라지지 않음
    _emailTEC.dispose();
    _passwordTEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // 뒤로가기 막기 (iOS는 확인해봐야할듯‼️)
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 다른 곳 클릭 시 키보드 내리기
        child: Scaffold(
          backgroundColor: Palette.white,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                // 검증 로직을 위해 Form으로 감싸기
                key: _globalKey,
                autovalidateMode: _autovalidateMode,
                child: ListView(
                  shrinkWrap: true,
                  reverse: true,
                  children: [
                    // 로고

                    // 이메일
                    TextFormField(
                      enabled: _isEnabled,
                      controller: _emailTEC,
                      keyboardType: TextInputType.emailAddress,
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
                        prefixIcon: Icon(Icons.email),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty ||
                            !isEmail(value.trim())) {
                          return "이메일을 입력해주세요.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // 패스워드
                    TextFormField(
                      enabled: _isEnabled,
                      controller: _passwordTEC,
                      obscureText: true,
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "패스워드를 입력해주세요.";
                        }
                        // 파이어베이스에서 비밀번호 6글자 이상 강제하기 때문에 미리 처리
                        if (value.length < 6) {
                          return "패스워드는 6글자 이상 입력해주세요.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // 로그인 버튼
                    GestureDetector(
                      onTap: _isEnabled
                          ? () async {
                              final form = _globalKey.currentState;

                              if (form == null || !form.validate()) {
                                return; // 검증이 통과되지 않으면 멈춤
                              }

                              // 검증 로직 후에
                              setState(() {
                                _isEnabled = false;
                                _autovalidateMode = AutovalidateMode.always;
                              });

                              // 로그인 로직
                              try {
                                await context.read<MyAuthProvider>().signIn(
                                      email: _emailTEC.text,
                                      password: _passwordTEC.text,
                                    );
                              } on CustomException catch (e) {
                                setState(() {
                                  _isEnabled = true; // 다시 활성화
                                });

                                errorDialogWidget(context, e);
                              }
                            }
                          : null,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Palette.mainGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '로그인',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Palette.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // 회원가입 하기 버튼
                    GestureDetector(
                      onTap: _isEnabled
                          ? () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupEmailScreen(),
                              ))
                          : null,
                      child: Align(
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              color: Palette.mediumGray,
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                            children: [
                              TextSpan(text: "회원이 아니신가요? "),
                              TextSpan(
                                text: "회원가입 하기",
                                style: TextStyle(
                                  color: Palette.subGreen,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    Divider(height: 1, color: Palette.lightGray),
                    SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 구글
                        GestureDetector(
                          onTap: () async {
                            try {
                              await context
                                  .read<MyAuthProvider>()
                                  .signInWithGoogle();
                            } on CustomException catch (e) {
                              errorDialogWidget(context, e);
                            }
                          },
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: SvgPicture.asset(
                                'assets/icons/ic_login_google.svg'),
                          ),
                        ),
                        SizedBox(width: 14),

                        // 카카오
                        GestureDetector(
                          onTap: () {},
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: SvgPicture.asset(
                                'assets/icons/ic_login_kakao.svg'),
                          ),
                        ),
                        SizedBox(width: 14),

                        // 애플
                        GestureDetector(
                          onTap: () {},
                          child: SizedBox(
                            width: 56,
                            height: 56,
                            child: SvgPicture.asset(
                                'assets/icons/ic_login_apple.svg'),
                          ),
                        ),
                      ],
                    ),
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
