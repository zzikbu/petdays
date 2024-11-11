import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:petdays/components/show_error_dialog.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/diary_model.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/diary/diary_provider.dart';
import 'package:petdays/providers/diary/diary_state.dart';
import 'package:petdays/providers/user/user_state.dart';
import 'package:petdays/screens/diary/diary_detail_screen.dart';
import 'package:petdays/screens/diary/diary_upload_screen.dart';
import 'package:provider/provider.dart';

class DiaryHomeScreen extends StatefulWidget {
  const DiaryHomeScreen({super.key});

  @override
  State<DiaryHomeScreen> createState() => _DiaryHomeScreenState();
}

class _DiaryHomeScreenState extends State<DiaryHomeScreen>
    with AutomaticKeepAliveClientMixin<DiaryHomeScreen> {
  late final DiaryProvider diaryProvider;

  // 다른 화면에서 돌아올 때
  // 데이터를 매번 가져오지 않도록
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    diaryProvider = context.read<DiaryProvider>();
    _getFeedList();
  }

  void _getFeedList() {
    String uid = context.read<User>().uid;

    // 위젯들이 만들어 진 후에
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await diaryProvider.getDiaryList(uid: uid);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentUserId = context.read<UserState>().userModel.uid;

    DiaryState diaryState = context.watch<DiaryState>();
    List<DiaryModel> diaryList = diaryState.diaryList;

    bool isLoading = diaryState.diaryStatus == DiaryStatus.fetching;

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
          ? Center(child: CircularProgressIndicator(color: Palette.subGreen))
          : RefreshIndicator(
              // 새로고침
              color: Palette.subGreen,
              backgroundColor: Palette.white,
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 1)); // 딜레이 추가
                _getFeedList(); // diaryList를 watch하고 있기 때문에 변경사항이 발생하면 화면을 새롭게 그림
              },
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: diaryList.length,
                  itemBuilder: (context, index) {
                    bool isLike =
                        diaryList[index].likes.contains(currentUserId);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryDetailScreen(
                              index: index,
                              isDiary: true,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2),
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
                                        if (diaryList[index].isLock == false)
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
                                                diaryList[index]
                                                    .likeCount
                                                    .toString(),
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
                                                color: Palette
                                                    .mediumGray, // 구분선 색상
                                              ),
                                              SizedBox(width: 8),
                                            ],
                                          ),

                                        // 날짜
                                        Text(
                                          diaryList[index]
                                              .createdAt
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
                                          diaryList[index].isLock
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DiaryUploadScreen()),
          );
        },
        backgroundColor: Palette.darkGray,
        elevation: 0, // 그림자 제거
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          Icons.edit,
          color: Palette.white,
        ),
      ),
    );
  }
}
