import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/like/like_provider.dart';
import 'package:pet_log/providers/like/like_state.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/screens/diary/diary_detail_screen.dart';
import 'package:provider/provider.dart';

class LikeHomeScreen extends StatefulWidget {
  const LikeHomeScreen({super.key});

  @override
  State<LikeHomeScreen> createState() => _LikeHomeScreenState();
}

class _LikeHomeScreenState extends State<LikeHomeScreen>
    with AutomaticKeepAliveClientMixin<LikeHomeScreen> {
  // 다른 화면에서 돌아올 때
  // 데이터를 매번 가져오지 않도록
  @override
  bool get wantKeepAlive => true; // AutomaticKeepAliveClientMixin

  late final LikeProvider likeProvider;

  void _getLikeList() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await likeProvider.getLikeList();
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    likeProvider = context.read<LikeProvider>();
    _getLikeList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentUserId = context.read<UserState>().userModel.uid;

    final likeState = context.watch<LikeState>();
    List<DiaryModel> likeList = likeState.likeList;

    // if (likeState.likeStatus == LikeStatus.success && likeList.isEmpty) {
    //   return Center(
    //     child: Text('좋아요한 성장일기가 없습니다.'),
    //   );
    // }

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "좋아요한 성장일기",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Palette.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: RefreshIndicator(
        // 새로고침
        color: Palette.subGreen,
        backgroundColor: Palette.white,
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1)); // 딜레이 추가
          _getLikeList();
        },
        child: Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: likeList.length,
            itemBuilder: (context, index) {
              bool isLike = likeList[index].likes.contains(currentUserId);
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiaryDetailScreen(
                        index: index,
                        isLike: true,
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
                          image: ExtendedNetworkImageProvider(
                              likeList[index].imageUrls[0]),
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
                                  likeList[index].title,
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
                                    likeList[index].likeCount.toString(),
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
                                    likeList[index]
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
                                  SizedBox(width: 8),

                                  // 공개여부 좌물쇠
                                  SvgPicture.asset(
                                    likeList[index].isLock
                                        ? 'assets/icons/ic_lock.svg'
                                        : 'assets/icons/ic_unlock.svg',
                                    width: 14,
                                    height: 14,
                                    color: Palette.mediumGray,
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
      ),
    );
  }
}
