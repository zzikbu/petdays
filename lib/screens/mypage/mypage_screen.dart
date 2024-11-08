import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petdays/components/custom_dialog.dart';
import 'package:petdays/components/error_dialog_widget.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/main.dart';
import 'package:petdays/models/user_model.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/auth/my_auth_provider.dart';
import 'package:petdays/providers/profile/profile_provider.dart';
import 'package:petdays/providers/user/user_provider.dart';
import 'package:petdays/providers/user/user_state.dart';
import 'package:petdays/screens/mypage/delete_account_screen.dart';
import 'package:petdays/screens/mypage/like_home_screen.dart';
import 'package:petdays/screens/mypage/open_diary_home_screen.dart';
import 'package:petdays/screens/mypage/terms_policy_screen.dart';
import 'package:petdays/screens/pet/pet_upload_screen.dart';
import 'package:petdays/screens/mypage/update_nickname_screen.dart';
import 'package:provider/provider.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  late final ProfileProvider profileProvider;

  // 사진 선택 함수
  Future<void> selectImage() async {
    ImagePicker imagePicker = new ImagePicker();
    // XFile: 기기의 파일시스템에 접근할 수 있는 클래스
    // 사진을 선택하지 안했을 때는 null 반환
    XFile? file = await imagePicker.pickImage(
      source: ImageSource.gallery,
      // 용량 줄이기
      maxHeight: 512,
      maxWidth: 512,
    );

    if (file != null) {
      Uint8List uint8list = await file.readAsBytes();

      final uid = context.read<UserState>().userModel.uid;

      try {
        // 프로필 이미지 수정 로직
        await context.read<ProfileProvider>().updateProfileImage(
              uid: uid,
              imageFile: uint8list,
            );

        // 상태관리하고 있는 userModel 갱신
        await context.read<UserProvider>().getUserInfo();
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = context.watch<UserState>().userModel;

    String? providerImageUrl;

    if (userModel.providerId == "google.com") {
      providerImageUrl = 'assets/icons/ic_login_google.svg';
    } else if (userModel.providerId == "apple.com") {
      providerImageUrl = 'assets/icons/ic_login_apple.svg';
    }

    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),

              Row(
                children: [
                  // 프로필 이미지
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Palette.lightGray,
                            width: 1.0,
                          ),
                          image: DecorationImage(
                            image: userModel.profileImage == null
                                ? ExtendedAssetImageProvider(
                                    "assets/icons/profile.png")
                                : ExtendedNetworkImageProvider(
                                    userModel.profileImage!),
                            fit: BoxFit.cover, // 이미지를 적절히 맞추는 옵션
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                return CupertinoActionSheet(
                                  actions: [
                                    // 앨범에서 선택
                                    CupertinoActionSheetAction(
                                      child: Text(
                                        '앨범에서 선택',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          color: CupertinoColors.systemBlue,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17,
                                        ),
                                      ),
                                      onPressed: () async {
                                        Navigator.pop(context);

                                        // 프로필 이미지 수정 로직
                                        await selectImage();
                                      },
                                    ),
                                    if (!(userModel.profileImage == null))
                                      // 프로필 이미지 삭제
                                      CupertinoActionSheetAction(
                                        child: Text(
                                          '프로필 이미지 삭제',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            color: CupertinoColors.systemRed,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 17,
                                          ),
                                        ),
                                        onPressed: () async {
                                          Navigator.pop(context);

                                          try {
                                            final uid = context
                                                .read<UserState>()
                                                .userModel
                                                .uid;

                                            // 프로필 이미지 삭제 로직
                                            await context
                                                .read<ProfileProvider>()
                                                .updateProfileImage(
                                                  uid: uid,
                                                  imageFile: null,
                                                );

                                            // 상태관리하고 있는 userModel 갱신
                                            await context
                                                .read<UserProvider>()
                                                .getUserInfo();
                                          } on CustomException catch (e) {
                                            errorDialogWidget(context, e);
                                          }
                                        },
                                      ),
                                  ],
                                  // 취소 버튼
                                  cancelButton: CupertinoActionSheetAction(
                                    isDefaultAction: true,
                                    child: Text(
                                      '취소',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        color: CupertinoColors.systemBlue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 17,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Icon(
                              color: Colors.white,
                              size: 15,
                              Icons.camera_alt,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 12),

                  // 닉네임
                  Text(
                    userModel.nickname,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: Palette.black,
                      letterSpacing: -0.5,
                    ),
                  ),

                  // 닉네임 수정
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateNicknameScreen(),
                          ));
                    },
                    icon: Icon(Icons.edit),
                  ),
                ],
              ),
              SizedBox(height: 40),

              // 구분선
              Container(
                height: 1,
                color: Palette.lightGray,
              ),
              SizedBox(height: 40),

              // MY
              Text(
                'MY',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Palette.black,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 20),

              // 펫추가
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PetUploadScreen()),
                  );
                },
                child: Text(
                  '반려동물 추가',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Palette.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 14),

              // 공개한 성장일기
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OpenDiaryHomeScreen()),
                  );
                },
                child: Text(
                  '공개한 성장일기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Palette.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 14),

              // 공감한 성장일기
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LikeHomeScreen()),
                  );
                },
                child: Text(
                  '좋아요한 성장일기',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Palette.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 40),

              // 구분선
              Container(
                height: 1,
                color: Palette.lightGray,
              ),
              SizedBox(height: 40),

              // 앱
              Text(
                '앱',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 24,
                  color: Palette.black,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 20),

              // 이용약관
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsPolicyScreen(isTerms: true),
                      ));
                },
                child: Text(
                  '이용약관',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Palette.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 14),

              // 개인정보 처리방침
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TermsPolicyScreen(isTerms: false),
                      ));
                },
                child: Text(
                  '개인정보 처리방침',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Palette.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 14),

              // 앱 버전
              Row(
                children: [
                  Text(
                    '앱 버전',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: Palette.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Spacer(),
                  Text('v${packageInfo.version}'),
                ],
              ),
              SizedBox(height: 40),

              // 구분선
              Container(
                height: 1,
                color: Palette.lightGray,
              ),
              SizedBox(height: 40),

              // 계정
              Row(
                children: [
                  Text(
                    '계정',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Palette.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 4),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: providerImageUrl == null
                        ? Icon(Icons.email)
                        : SvgPicture.asset(providerImageUrl),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // 비밀번호 재설정
              if (userModel.providerId == 'password')
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CustomDialog(
                              title: '비밀번호 재설정',
                              message:
                                  '${userModel.email}로\n비밀번호 재설정 링크가 발송됩니다.',
                              onConfirm: () async {
                                try {
                                  await context
                                      .read<MyAuthProvider>()
                                      .sendPasswordResetEmail(
                                          email: userModel.email!);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("전송 완료")));

                                  Navigator.pop(context);
                                } on CustomException catch (e) {
                                  errorDialogWidget(context, e);
                                }
                              },
                            );
                          },
                        );
                      },
                      child: Text(
                        '비밀번호 재설정',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: Palette.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 14),
                  ],
                ),

              // 로그아웃
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: '로그아웃',
                        message: '로그아웃 하시겠습니까?',
                        onConfirm: () async {
                          try {
                            await context.read<MyAuthProvider>().signOut();
                          } on CustomException catch (e) {
                            errorDialogWidget(context, e);
                          }
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
                    color: Palette.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 14),

              // 회원탈퇴
              GestureDetector(
                onTap: () async {
                  if (userModel.providerId == 'password') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeleteAccountScreen(),
                        ));
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          title: '회원탈퇴',
                          message: '탈퇴 시 사용자가 기록한 모든 정보가 삭제됩니다.\n탈퇴하시겠습니까?',
                          onConfirm: () async {
                            Navigator.pop(context);
                            await context
                                .read<MyAuthProvider>()
                                .deleteAccount();
                          },
                        );
                      },
                    );
                  }
                },
                child: Text(
                  '회원탈퇴',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    color: Palette.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
