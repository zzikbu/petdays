import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/common/widgets/pd_app_bar.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/diary_card_widget.dart';
import '../../common/widgets/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/diary_model.dart';
import '../../palette.dart';
import '../../providers/like/like_provider.dart';
import '../../providers/like/like_state.dart';
import '../diary/diary_detail_screen.dart';

class LikeHomeScreen extends StatefulWidget {
  const LikeHomeScreen({super.key});

  @override
  State<LikeHomeScreen> createState() => _LikeHomeScreenState();
}

class _LikeHomeScreenState extends State<LikeHomeScreen>
    with AutomaticKeepAliveClientMixin<LikeHomeScreen> {
  @override
  bool get wantKeepAlive => true;

  late final String _currentUserId;

  void _getLikeList() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<LikeProvider>().getLikeList();
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<User>().uid;
    _getLikeList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final likeState = context.watch<LikeState>();
    List<DiaryModel> likeList = likeState.likeList;

    bool isLoading = likeState.likeStatus == LikeStatus.fetching;
    bool isEmpty = likeState.likeStatus == LikeStatus.success && likeList.isEmpty;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: const PDAppBar(titleText: '좋아요한 성장일기'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Palette.subGreen))
          : isEmpty
              ? const Center(
                  child: Text(
                    '좋아요한 성장일기가\n없습니다',
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
                    _getLikeList();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    itemCount: likeList.length,
                    itemBuilder: (context, index) {
                      final diaryModel = likeList[index];
                      final isLike = diaryModel.likes.contains(_currentUserId);

                      return DiaryCardWidget(
                        diaryModel: diaryModel,
                        index: index,
                        diaryType: DiaryType.myLike,
                        isLike: isLike,
                        showLock: false,
                      );
                    },
                  ),
                ),
    );
  }
}
