import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/common/widgets/pd_app_bar.dart';
import 'package:petdays/models/diary_model.dart';
import 'package:petdays/screens/diary/diary_detail_screen.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/diary_card_widget.dart';
import '../../common/widgets/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../palette.dart';
import '../../providers/feed/feed_provider.dart';
import '../../providers/feed/feed_state.dart';

class FeedHomeScreen extends StatefulWidget {
  const FeedHomeScreen({super.key});

  @override
  _FeedHomeScreenState createState() => _FeedHomeScreenState();
}

class _FeedHomeScreenState extends State<FeedHomeScreen>
    with AutomaticKeepAliveClientMixin<FeedHomeScreen> {
  @override
  bool get wantKeepAlive => true;

  late final String _currentUserId;
  bool _isHotFeed = true;

  void _getFeedList() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<FeedProvider>().getFeedList();
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<User>().uid;
    _getFeedList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final feedState = context.watch<FeedState>();
    final isLoading = feedState.feedStatus == FeedStatus.fetching;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: PDAppBar(
        titleWidget: Container(
          height: 48,
          width: 170,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            child: Row(
              children: [
                FeedToggleButton(
                  isHot: true,
                  isSelected: _isHotFeed,
                  onTap: () => setState(() => _isHotFeed = true),
                  text: 'HOT',
                ),
                FeedToggleButton(
                  isHot: false,
                  isSelected: !_isHotFeed,
                  onTap: () => setState(() => _isHotFeed = false),
                  text: '전체',
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Palette.subGreen))
          : Stack(
              children: [
                // offstage: true => 위젯을 화면에서 숨김
                // offstage: false => 위젯을 화면에 표시
                Offstage(
                  offstage: !_isHotFeed,
                  child: FeedListView(
                    feedList: feedState.hotFeedList,
                    currentUserId: _currentUserId,
                    isHotFeed: true,
                    onRefresh: _getFeedList,
                  ),
                ),
                Offstage(
                  offstage: _isHotFeed,
                  child: FeedListView(
                    feedList: feedState.feedList,
                    currentUserId: _currentUserId,
                    isHotFeed: false,
                    onRefresh: _getFeedList,
                  ),
                ),
              ],
            ),
    );
  }
}

/// HOT/전체 토글 버튼 위젯
class FeedToggleButton extends StatelessWidget {
  final bool isHot;
  final bool isSelected;
  final VoidCallback onTap;
  final String text;

  const FeedToggleButton({
    super.key,
    required this.isHot,
    required this.isSelected,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? Palette.mainGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: isSelected ? Palette.white : Palette.lightGray,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// 피드 리스트뷰 위젯
class FeedListView extends StatelessWidget {
  final List<DiaryModel> feedList;
  final String currentUserId;
  final bool isHotFeed;
  final VoidCallback onRefresh;

  const FeedListView({
    super.key,
    required this.feedList,
    required this.currentUserId,
    required this.isHotFeed,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Palette.subGreen,
      backgroundColor: Palette.white,
      onRefresh: () async {
        onRefresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: feedList.length,
        itemBuilder: (context, index) {
          final diaryModel = feedList[index];
          final isLike = diaryModel.likes.contains(currentUserId);

          return DiaryCardWidget(
            diaryModel: diaryModel,
            index: index,
            diaryType: isHotFeed ? DiaryType.hotFeed : DiaryType.allFeed,
            isLike: isLike,
            showLock: false,
          );
        },
      ),
    );
  }
}
