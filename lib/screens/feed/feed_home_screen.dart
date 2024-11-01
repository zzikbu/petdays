import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/feed/feed_provider.dart';
import 'package:pet_log/providers/feed/feed_state.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/screens/diary/diary_detail_screen.dart';
import 'package:provider/provider.dart';

class FeedHomeScreen extends StatefulWidget {
  const FeedHomeScreen({super.key});

  @override
  _FeedHomeScreenState createState() => _FeedHomeScreenState();
}

class _FeedHomeScreenState extends State<FeedHomeScreen>
    with AutomaticKeepAliveClientMixin<FeedHomeScreen> {
  // 다른 화면에서 돌아올 때
  // 데이터를 매번 가져오지 않도록
  @override
  bool get wantKeepAlive => true; // AutomaticKeepAliveClientMixin

  /// Properties
  late final FeedProvider feedProvider;
  bool _isHotFeed = true;

  void _getFeedList() {
    // 위젯들이 만들어 진 후에
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await feedProvider.getFeedList();
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  /// Lifecycle
  @override
  void initState() {
    super.initState();
    feedProvider = context.read<FeedProvider>();
    _getFeedList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentUserId = context.read<UserState>().userModel.uid;

    FeedState feedState = context.watch<FeedState>();
    List<DiaryModel> feedList = feedState.feedList;
    List<DiaryModel> hotFeedList = feedState.hotFeedList;

    if (feedState.feedStatus == FeedStatus.fetching) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isHotFeed = true;
                    });
                  },
                  child: Container(
                    height: 42,
                    width: 80,
                    decoration: BoxDecoration(
                      color:
                          _isHotFeed ? Palette.mainGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        'HOT',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _isHotFeed ? Palette.white : Palette.lightGray,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isHotFeed = false;
                    });
                  },
                  child: Container(
                    height: 42,
                    width: 80,
                    decoration: BoxDecoration(
                      color:
                          _isHotFeed ? Colors.transparent : Palette.mainGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        '전체',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: _isHotFeed ? Palette.lightGray : Palette.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 16),
        //     child: GestureDetector(
        //       onTap: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => SearchScreen()),
        //         );
        //       },
        //       child: SvgPicture.asset('assets/icons/ic_magnifier.svg'),
        //     ),
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        // 새로고침
        color: Palette.subGreen,
        backgroundColor: Palette.white,
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1)); // 딜레이 추가
          _getFeedList();
        },

        // 리스트뷰
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: _isHotFeed ? hotFeedList.length : feedList.length,
          itemBuilder: (context, index) {
            final feed = _isHotFeed ? hotFeedList[index] : feedList[index];
            bool isLike = feed.likes.contains(currentUserId);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiaryDetailScreen(
                      index: index,
                      isHotFeed: _isHotFeed ? true : false,
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  // 사진
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Palette.feedBorder,
                        width: 1,
                      ),
                      image: DecorationImage(
                        image: ExtendedNetworkImageProvider(feed.imageUrls[0]),
                        fit: BoxFit.cover, // 이미지를 적절히 맞추는 옵션
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.black.withOpacity(0.05),
                          offset: Offset(8, 8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    // 흰색 부분
                    child: Container(
                      height: 88,
                      decoration: BoxDecoration(
                        color: Palette.white.withOpacity(0.9),
                        border: Border(
                          left: BorderSide(
                            color: Palette.feedBorder,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                          right: BorderSide(
                            color: Palette.feedBorder,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                          bottom: BorderSide(
                            color: Palette.feedBorder,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              // 제목
                              child: Text(
                                feed.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Palette.black,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                // 좋아요 아이콘
                                isLike
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 16,
                                      )
                                    : Icon(
                                        Icons.favorite_border,
                                        color: Palette.darkGray,
                                        size: 16,
                                      ),
                                SizedBox(width: 4),

                                // 좋아요 개수
                                Text(
                                  feed.likeCount.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Palette.darkGray,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                SizedBox(width: 8), // 여유 공간 추가

                                // 세로 구분선
                                Container(
                                  width: 1,
                                  height: 10,
                                  color: Palette.mediumGray, // 구분선 색상
                                ),
                                SizedBox(width: 8),

                                // 날짜
                                Text(
                                  feed.createAt
                                      .toDate()
                                      .toString()
                                      .split(" ")[0],
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Palette.mediumGray,
                                    letterSpacing: -0.35,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
