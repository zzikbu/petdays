import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_log/components/custom_dialog.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/user_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/auth/my_auth_provider.dart';
import 'package:pet_log/providers/profile/profile_provider.dart';
import 'package:pet_log/providers/profile/profile_state.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/screens/like/like_screen.dart';
import 'package:pet_log/screens/sign_up/sign_up_nickname_screen.dart';
import 'package:pet_log/screens/mypage/pet_upload_screen.dart';
import 'package:provider/provider.dart';

class MypagePageScreen extends StatefulWidget {
  const MypagePageScreen({super.key});

  @override
  State<MypagePageScreen> createState() => _MypagePageScreenState();
}

class _MypagePageScreenState extends State<MypagePageScreen> {
  late final ProfileProvider profileProvider;

  Uint8List? _image; // Uint8List: 이미지나 동영상 같은 바이너리 데이터 취급할 때

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
      Uint8List uint8list =
          await file.readAsBytes(); // 선택한 이미지를 코드로 조작할 수 있게 반환
      setState(() {
        _image = uint8list;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    profileProvider = context.read<ProfileProvider>();
    _getProfile();
  }

  void _getProfile() {
    String uid = context.read<UserState>().userModel.uid;
    // 위젯들이 만들어 진 후에
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await profileProvider.getProfile(uid: uid);
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = context.watch<ProfileState>().userModel;

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
                  // 프로필 사진
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
                          onTap: () async {
                            await selectImage();
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
                            builder: (context) =>
                                SignUpNicknameScreen(isEditMode: true),
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
              GestureDetector(
                onTap: () {},
                child: Text(
                  '획득한 메달',
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
                onTap: () {},
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
                    MaterialPageRoute(builder: (context) => LikeScreen()),
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
                        message: '로그아웃 하시겠습니까??',
                        onConfirm: () async {
                          // 로그아웃 로직
                          await context.read<MyAuthProvider>().signOut();
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
                onTap: () {},
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
