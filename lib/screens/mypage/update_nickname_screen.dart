import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/common/widgets/pd_app_bar.dart';
import 'package:petdays/common/widgets/show_error_dialog.dart';
import 'package:petdays/common/widgets/w_bottom_confirm_button.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/profile/profile_provider.dart';
import 'package:provider/provider.dart';

class UpdateNicknameScreen extends StatefulWidget {
  const UpdateNicknameScreen({super.key});

  @override
  _UpdateNicknameScreenState createState() => _UpdateNicknameScreenState();
}

class _UpdateNicknameScreenState extends State<UpdateNicknameScreen> {
  /// Properties
  final TextEditingController _nicknameTEC = TextEditingController();
  late String currentUserUid = context.read<User>().uid;

  bool _isActive = false;

  /// Method
  void _checkBottomActive() {
    setState(() {
      _isActive = _nicknameTEC.text.isNotEmpty && _nicknameTEC.text.length > 1;
    });
  }

  /// LifeCycle
  @override
  void initState() {
    super.initState();
    _nicknameTEC.addListener(_checkBottomActive);
  }

  @override
  void dispose() {
    _nicknameTEC.removeListener(_checkBottomActive);
    _nicknameTEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 다른 곳 클릭 시 키보드 내리기
      child: Scaffold(
        backgroundColor: Palette.white,
        appBar: const PDAppBar(backgroundColor: Palette.white),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // 제목
              Text(
                '닉네임을 입력해주세요',
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
                '2글자 이상 10글자 이하로 입력해주세요.',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Palette.mediumGray,
                  letterSpacing: -0.6,
                ),
              ),
              SizedBox(height: 100),

              // 입력 칸
              TextField(
                controller: _nicknameTEC,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 10, // 10 글자 제한
                cursorColor: Palette.mainGreen,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  letterSpacing: -0.5,
                ),
                decoration: InputDecoration(
                  hintText: '홍길동',
                  hintStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20,
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w500,
                    color: Palette.lightGray,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.black, width: 2), // 활성화
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.black, width: 2), // 비활성화
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomConfirmButtonWidget(
          isActive: _isActive,
          buttonText: "수정하기",
          onConfirm: () async {
            try {
              setState(() {
                _isActive = false;
              });

              // 수정 로직
              await context.read<ProfileProvider>().updateNickname(
                    uid: currentUserUid,
                    newNickname: _nicknameTEC.text,
                  );

              // 상태관리하고 있는 userModel 갱신
              await context.read<ProfileProvider>().getProfile(uid: currentUserUid);

              Navigator.pop(context);
            } on CustomException catch (e) {
              showErrorDialog(context, e);

              setState(() {
                _isActive = true;
              });
            }
          },
        ),
      ),
    );
  }
}
