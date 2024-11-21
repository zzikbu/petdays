import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/screens/diary/diary_detail_screen.dart';
import 'package:provider/provider.dart';

import '../../components/diary_card_widget.dart';
import '../../components/show_error_dialog.dart';
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

  /// HOT/전체 토글 버튼 위젯
  Widget _buildToggleButton({
    required bool isHot,
    required VoidCallback onTap,
    required String text,
  }) {
    final isSelected = isHot == _isHotFeed;
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
    final currentFeedList =
        _isHotFeed ? feedState.hotFeedList : feedState.feedList;
    final isLoading = feedState.feedStatus == FeedStatus.fetching;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Container(
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
                _buildToggleButton(
                  isHot: true,
                  onTap: () => setState(() => _isHotFeed = true),
                  text: 'HOT',
                ),
                _buildToggleButton(
                  isHot: false,
                  onTap: () => setState(() => _isHotFeed = false),
                  text: '전체',
                ),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Palette.subGreen))
          : RefreshIndicator(
              color: Palette.subGreen,
              backgroundColor: Palette.white,
              onRefresh: () async {
                _getFeedList();
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: currentFeedList.length,
                itemBuilder: (context, index) {
                  final diaryModel = currentFeedList[index];
                  final isLike = diaryModel.likes.contains(_currentUserId);

                  return DiaryCardWidget(
                    diaryModel: diaryModel,
                    index: index,
                    diaryType:
                        _isHotFeed ? DiaryType.hotFeed : DiaryType.allFeed,
                    isLike: isLike,
                    showLock: false,
                  );
                },
              ),
            ),
    );
  }
}
