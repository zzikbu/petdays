import 'package:flutter/material.dart';
import 'package:petdays/components/error_dialog_widget.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/auth/my_auth_provider.dart';
import 'package:petdays/screens/sign_in/sign_in_screen.dart';
import 'package:provider/provider.dart';
import 'package:string_validator/string_validator.dart';

class SignupEmailScreen extends StatefulWidget {
  const SignupEmailScreen({super.key});

  @override
  State<SignupEmailScreen> createState() => _SignupEmailScreenState();
}

class _SignupEmailScreenState extends State<SignupEmailScreen> {
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
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

                    // 비밀번호
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
                          return "비밀번호를 입력해주세요.";
                        }
                        // 파이어베이스에서 비밀번호 6글자 이상 강제하기 때문에 미리 처리
                        if (value.length < 6) {
                          return "비밀번호는 6글자 이상 입력해주세요.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // 비밀번호 확인
                    TextFormField(
                      enabled: _isEnabled,
                      obscureText: true,
                      decoration: InputDecoration(
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Palette.mainGreen),
                        ),
                        labelText: "비밀번호 확인",
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIcon: Icon(Icons.lock),
                        filled: true,
                      ),
                      validator: (value) {
                        if (_passwordTEC.text != value) {
                          return "비밀번호가 일치하지 않습니다.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // 회원가입 버튼
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
                                _autovalidateMode =
                                    AutovalidateMode.always; // 실시간으로 변하게
                              });

                              // 회원가입 로직
                              try {
                                await context.read<MyAuthProvider>().signUp(
                                      email: _emailTEC.text,
                                      password: _passwordTEC.text,
                                    );

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignInScreen(),
                                    ));

                                // 스낵바 띄우기
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("인증 메일을 전송했습니다."),
                                    duration: Duration(seconds: 120),
                                  ),
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
                            '회원가입',
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
                    SizedBox(height: 40),

                    // 로그인 하기 버튼
                    GestureDetector(
                      onTap: _isEnabled
                          ? () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInScreen(),
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
                              TextSpan(text: "이미 회원이신가요? "),
                              TextSpan(
                                text: "로그인 하기",
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
