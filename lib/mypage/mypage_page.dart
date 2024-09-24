import 'package:flutter/material.dart';
import 'package:pet_log/components/custom_dialog.dart';
import 'package:pet_log/service/auth_service.dart';
import 'package:pet_log/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';

import '../pallete.dart';

class MypagePage extends StatelessWidget {
  const MypagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Pallete.lightGray,
                        width: 1.0,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '이승민',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Pallete.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Spacer(),
                  Container(
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F3F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '프로필 수정',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Pallete.black,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Container(
                height: 1,
                color: Pallete.lightGray,
              ),
              SizedBox(height: 40),
              Text(
                'MY',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Pallete.black,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '획득한 메달',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Pallete.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 14),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '공개한 성장일기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Pallete.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 14),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '공감한 성장일기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Pallete.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Container(
                height: 1,
                color: Pallete.lightGray,
              ),
              SizedBox(height: 40),
              Text(
                '계정',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Pallete.black,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: '로그아웃',
                        message: '로그아웃 하시겠습니까??',
                        onConfirm: () {
                          // 로그아웃
                          context.read<AuthService>().signOut();

                          // SignInPage로 이동
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SignInPage()),
                          );
                        },
                      );
                    },
                  );
                },
                child: Text(
                  '로그아웃',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Pallete.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 14),
              GestureDetector(
                onTap: () {},
                child: Text(
                  '회원탈퇴',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Pallete.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
