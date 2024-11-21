import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/diary_card_widget.dart';
import '../../components/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/diary_model.dart';
import '../../palette.dart';
import '../../providers/diary/diary_provider.dart';
import '../../providers/diary/diary_state.dart';
import 'diary_detail_screen.dart';

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
    bool isEmpty =
        diaryState.diaryStatus == DiaryStatus.success && diaryList.isEmpty;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "성장일기",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Palette.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Palette.subGreen))
          : isEmpty
              ? Center(
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
    );
  }
}
