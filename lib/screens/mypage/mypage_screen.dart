import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_log/components/custom_dialog.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/user_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/auth/my_auth_provider.dart';
import 'package:pet_log/providers/profile/profile_provider.dart';
import 'package:pet_log/providers/user/user_provider.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/screens/mypage/like_home_screen.dart';
import 'package:pet_log/screens/mypage/open_diary_home_screen.dart';
import 'package:pet_log/screens/pet/pet_upload_screen.dart';
import 'package:pet_log/screens/mypage/update_nickname_screen.dart';
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
                  '펫 추가',
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

              // 획득한 메달
              // GestureDetector(
              //   onTap: () {},
              //   child: Text(
              //     '획득한 메달',
              //     style: TextStyle(
              //       fontFamily: 'Pretendard',
              //       fontWeight: FontWeight.w400,
              //       fontSize: 20,
              //       color: Palette.black,
              //       letterSpacing: -0.5,
              //     ),
              //   ),
              // ),
              // SizedBox(height: 14),

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

              // 계정
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
              SizedBox(height: 20),

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
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: '회원탈퇴',
                        message: '탈퇴 시 사용자가 기록한 모든 정보가 삭제됩니다.\n탈퇴 하시겠습니까?',
                        onConfirm: () async {
                          try {
                            await context
                                .read<MyAuthProvider>()
                                .deleteAccount();
                          } on CustomException catch (e) {
                            errorDialogWidget(context, e);
                          }
                        },
                      );
                    },
                  );
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
