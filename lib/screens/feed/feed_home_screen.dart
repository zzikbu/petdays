import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/diary/diary_provider.dart';
import 'package:pet_log/providers/diary/diary_state.dart';
import 'package:pet_log/screens/diary/diary_detail_screen.dart';
import 'package:pet_log/screens/search/search_screen.dart';
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
  late final DiaryProvider diaryProvider;
  bool isAllSelected = true;

  void _getFeedList() {
    // 위젯들이 만들어 진 후에
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await diaryProvider.getDiaryList();
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  /// Lifecycle
  @override
  void initState() {
    super.initState();
    diaryProvider = context.read<DiaryProvider>();
    _getFeedList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    DiaryState diaryState = context.watch<DiaryState>();
    List<DiaryModel> diaryList = diaryState.diaryList;

    if (diaryState.diaryStatus == DiaryStatus.fetching) {
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
                      isAllSelected = true;
                    });
                  },
                  child: Container(
                    height: 42,
                    width: 80,
                    decoration: BoxDecoration(
                      color: isAllSelected
                          ? Palette.mainGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        '전체',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color:
                              isAllSelected ? Palette.white : Palette.lightGray,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAllSelected = false;
                    });
                  },
                  child: Container(
                    height: 42,
                    width: 80,
                    decoration: BoxDecoration(
                      color: !isAllSelected
                          ? Palette.mainGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        'HOT',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: !isAllSelected
                              ? Palette.white
                              : Palette.lightGray,
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchScreen()),
                );
              },
              child: SvgPicture.asset('assets/icons/ic_magnifier.svg'),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        // 새로고침
        color: Palette.subGreen,
        backgroundColor: Palette.white,
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1)); // 딜레이 추가
          _getFeedList(); // diaryList를 watch하고 있기 때문에 변경사항이 발생하면 화면을 새롭게 그림
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: diaryList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DiaryDetailScreen(diaryModel: diaryList[index])),
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
                        image: ExtendedNetworkImageProvider(
                            diaryList[index].imageUrls[0]),
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
                                diaryList[index].title,
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
                                Icon(
                                  Icons.pets,
                                  color: Palette.darkGray,
                                  size: 16,
                                ),
                                SizedBox(width: 4),

                                // 좋아요 개수
                                Text(
                                  diaryList[index].likeCount.toString(),
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
                                  diaryList[index]
                                      .createAt
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
