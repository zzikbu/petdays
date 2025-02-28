import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/diary_card_widget.dart';
import '../../common/widgets/pd_app_bar.dart';
import '../../common/widgets/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/diary_model.dart';
import '../../palette.dart';
import '../../providers/diary/diary_provider.dart';
import '../../providers/diary/diary_state.dart';
import 'diary_detail_screen.dart';
import 'diary_upload_screen.dart';

class DiaryHomeScreen extends StatefulWidget {
  const DiaryHomeScreen({super.key});

  @override
  State<DiaryHomeScreen> createState() => _DiaryHomeScreenState();
}

class _DiaryHomeScreenState extends State<DiaryHomeScreen>
    with AutomaticKeepAliveClientMixin<DiaryHomeScreen> {
  @override
  bool get wantKeepAlive => true;

  late final String _currentUserId;

  void _getDiaryList() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<DiaryProvider>().getDiaryList(uid: _currentUserId);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<User>().uid;
    _getDiaryList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    DiaryState diaryState = context.watch<DiaryState>();
    List<DiaryModel> diaryList = diaryState.diaryList;

    bool isLoading = diaryState.diaryStatus == DiaryStatus.fetching;
    bool isEmpty = diaryState.diaryStatus == DiaryStatus.success && diaryList.isEmpty;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: const PDAppBar(titleText: '성장일기'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Palette.subGreen))
          : isEmpty
              ? const Center(
                  child: Text(
                    '작성한 성장일기가\n없습니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Palette.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: Palette.subGreen,
                  backgroundColor: Palette.white,
                  onRefresh: () async {
                    _getDiaryList();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: diaryList.length,
                    itemBuilder: (context, index) {
                      final diaryModel = diaryList[index];
                      final isLike = diaryModel.likes.contains(_currentUserId);

                      return DiaryCardWidget(
                        diaryModel: diaryModel,
                        index: index,
                        diaryType: DiaryType.my,
                        isLike: isLike,
                        showLock: true,
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DiaryUploadScreen()),
          );
        },
        backgroundColor: Palette.darkGray,
        elevation: 0, // 그림자 제거
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: const Icon(
          Icons.edit,
          color: Palette.white,
        ),
      ),
    );
  }
}
