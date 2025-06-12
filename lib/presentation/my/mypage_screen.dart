import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/show_custom_dialog.dart';
import '../../common/widgets/show_error_dialog.dart';
import '../../common/widgets/pd_circle_avatar.dart';
import '../../exceptions/custom_exception.dart';
import '../../main.dart';
import '../../palette.dart';
import '../../providers/auth/my_auth_provider.dart';
import '../../providers/profile/profile_provider.dart';
import '../../providers/profile/profile_state.dart';
import '../../utils/permission_utils.dart';
import '../pet/pet_upload_screen.dart';
import 'delete_account_screen.dart';
import 'like_home_screen.dart';
import 'open_diary_home_screen.dart';
import 'terms_policy_screen.dart';
import 'update_nickname_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  late final ProfileProvider profileProvider;
  late String currentUserUid = context.read<User>().uid;

  // 사진 선택 함수
  Future<void> selectImage() async {
    final hasPermission = await PermissionUtils.checkPhotoPermission(context);
    if (!hasPermission) return;

    ImagePicker imagePicker = ImagePicker();

    XFile? file = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
    );

    if (file != null) {
      Uint8List uint8list = await file.readAsBytes();

      try {
        // 프로필 이미지 수정 로직
        await context.read<ProfileProvider>().updateProfileImage(
              uid: currentUserUid,
              imageFile: uint8list,
            );

        await profileProvider.getProfile(uid: currentUserUid);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    }
  }

  void _getProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid;

        await profileProvider.getProfile(uid: uid);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    profileProvider = context.read<ProfileProvider>();
    _getProfile();
  }

  @override
  Widget build(BuildContext context) {
    ProfileState profileState = context.watch<ProfileState>();

    bool isLoading = (profileState.profileStatus == ProfileStatus.fetching) ||
        (profileState.profileStatus == ProfileStatus.submitting);

    String? providerImageUrl;

    if (profileState.userModel.providerId == "google.com") {
      providerImageUrl = 'assets/icons/ic_login_google.svg';
    } else if (profileState.userModel.providerId == "apple.com") {
      providerImageUrl = 'assets/icons/ic_login_apple.svg';
    }

    return Scaffold(
      backgroundColor: Palette.background,
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Palette.subGreen))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    Row(
                      children: [
                        // 프로필 이미지
                        Stack(
                          children: [
                            PDCircleAvatar(
                              imageUrl: profileState.userModel.profileImage,
                              size: 60,
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
                                            child: const Text(
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
                                          if (!(profileState.userModel.profileImage == null))
                                            // 프로필 이미지 삭제
                                            CupertinoActionSheetAction(
                                              child: const Text(
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
                                                  // 프로필 이미지 삭제 로직
                                                  await context
                                                      .read<ProfileProvider>()
                                                      .updateProfileImage(
                                                        uid: currentUserUid,
                                                        imageFile: null,
                                                      );

                                                  // 상태관리하고 있는 userModel 갱신
                                                  await profileProvider.getProfile(
                                                      uid: currentUserUid);
                                                } on CustomException catch (e) {
                                                  showErrorDialog(context, e);
                                                }
                                              },
                                            ),
                                        ],
                                        // 취소 버튼
                                        cancelButton: CupertinoActionSheetAction(
                                          isDefaultAction: true,
                                          child: const Text(
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
                                  child: const Icon(
                                    color: Colors.white,
                                    size: 15,
                                    Icons.camera_alt,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // 닉네임
                        Text(
                          profileState.userModel.nickname,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Palette.black,
                            letterSpacing: -0.5,
                          ),
                        ),

                        // 닉네임 수정
                        IconButton(
                          onPressed: () => context.go('/my/update_nickname'),
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 구분선
                    Container(
                      height: 1,
                      color: Palette.lightGray,
                    ),
                    const SizedBox(height: 40),

                    // MY
                    const Text(
                      'MY',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: Palette.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 반려동물 추가
                    GestureDetector(
                      onTap: () => context.go('/my/add_pet'),
                      child: const Text(
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
                    const SizedBox(height: 14),

                    // 공개한 성장일기
                    GestureDetector(
                      onTap: () => context.go('/my/open_diary'),
                      child: const Text(
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
                    const SizedBox(height: 14),

                    // 공감한 성장일기
                    GestureDetector(
                      onTap: () => context.go('/my/like_diary'),
                      child: const Text(
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
                    const SizedBox(height: 40),

                    // 구분선
                    Container(
                      height: 1,
                      color: Palette.lightGray,
                    ),
                    const SizedBox(height: 40),

                    // 앱
                    const Text(
                      '앱',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,
                        color: Palette.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 이용약관
                    GestureDetector(
                      onTap: () => context.go('/my/terms'),
                      child: const Text(
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
                    const SizedBox(height: 14),

                    // 개인정보 처리방침
                    GestureDetector(
                      onTap: () => context.go('/my/policy'),
                      child: const Text(
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
                    const SizedBox(height: 14),

                    // 앱 버전
                    Row(
                      children: [
                        const Text(
                          '앱 버전',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            color: Palette.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        Text('v${packageInfo.version}'),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // 구분선
                    Container(
                      height: 1,
                      color: Palette.lightGray,
                    ),
                    const SizedBox(height: 40),

                    // 계정
                    Row(
                      children: [
                        const Text(
                          '계정',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                            color: Palette.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: providerImageUrl == null
                              ? const Icon(Icons.email)
                              : SvgPicture.asset(providerImageUrl),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 비밀번호 재설정
                    if (profileState.userModel.providerId == 'password')
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showCustomDialog(
                                context: context,
                                title: '비밀번호 재설정',
                                message: '${profileState.userModel.email}로\n비밀번호 재설정 링크가 발송됩니다.',
                                onConfirm: () async {
                                  try {
                                    await context.read<MyAuthProvider>().sendPasswordResetEmail(
                                        email: profileState.userModel.email!);

                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(content: Text("전송 완료")));

                                    Navigator.pop(context);
                                  } on CustomException catch (e) {
                                    showErrorDialog(context, e);
                                  }
                                },
                              );
                            },
                            child: const Text(
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
                          const SizedBox(height: 14),
                        ],
                      ),

                    // 로그아웃
                    GestureDetector(
                      onTap: () {
                        showCustomDialog(
                          context: context,
                          title: '로그아웃',
                          message: '로그아웃 하시겠습니까?',
                          onConfirm: () async {
                            try {
                              await context.read<MyAuthProvider>().signOut();
                            } on CustomException catch (e) {
                              showErrorDialog(context, e);
                            }
                          },
                        );
                      },
                      child: const Text(
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
                    const SizedBox(height: 14),

                    // 회원탈퇴
                    GestureDetector(
                      onTap: () async {
                        if (profileState.userModel.providerId == 'password') {
                          context.go('/my/delete_account');
                        } else {
                          showCustomDialog(
                            context: context,
                            title: '회원탈퇴',
                            message: '탈퇴 시 사용자가 기록한 모든 정보가 삭제됩니다.\n탈퇴하시겠습니까?',
                            onConfirm: () async {
                              try {
                                await context.read<MyAuthProvider>().deleteAccount();
                              } on CustomException catch (e) {
                                Navigator.pop(context);
                                showErrorDialog(context, e);
                              }
                            },
                          );
                        }
                      },
                      child: const Text(
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
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
