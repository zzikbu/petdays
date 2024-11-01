import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:pet_log/components/custom_dialog.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/diary/diary_provider.dart';
import 'package:pet_log/providers/diary/diary_state.dart';
import 'package:pet_log/providers/feed/feed_provider.dart';
import 'package:pet_log/providers/feed/feed_state.dart';
import 'package:pet_log/providers/like/like_provider.dart';
import 'package:pet_log/providers/like/like_state.dart';
import 'package:pet_log/providers/user/user_provider.dart';
import 'package:pet_log/providers/user/user_state.dart';
import 'package:pet_log/screens/diary/diary_upload_screen.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

enum ReportType {
  ad('상업적 광고 및 판매', 'adReportCount'),
  abuse('욕설/비하', 'abuseReportCount'),
  adult('음란물', 'adultReportCount'),
  other('기타', 'otherReportCount');

  final String label;
  final String countField; // Firestore count 필드명

  const ReportType(
    this.label,
    this.countField,
  );
}

class DiaryDetailScreen extends StatefulWidget {
  final int index;
  final bool isDiary;
  final bool isLike;

  const DiaryDetailScreen({
    super.key,
    required this.index,
    this.isDiary = false,
    this.isLike = false,
  });

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  bool _isLock = true;
  late bool _isMyDiary;
  late String _currentUserId;

  Future<void> _likeDiary(DiaryModel diaryModel) async {
    try {
      DiaryModel newDiaryModel = await context.read<FeedProvider>().likeDiary(
            diaryId: diaryModel.diaryId,
            diaryLikes: diaryModel.likes,
          );

      context.read<LikeProvider>().likeDiary(newDiaryModel: newDiaryModel);

      if (_currentUserId == diaryModel.uid) {
        context.read<DiaryProvider>().likeDiary(newDiaryModel: newDiaryModel);
      }

      await context
          .read<UserProvider>()
          .getUserInfo(); // 좋아요 했기 때문에 상태관리하고 있는 userModel 갱신
    } on CustomException catch (e) {
      errorDialogWidget(context, e);
    }
  }

  void _lockTap() {
    setState(() {
      _isLock = !_isLock;
    });
  }

  @override
  Widget build(BuildContext context) {
    DiaryModel diaryModel;

    if (widget.isDiary) {
      // DiaryHomeScreen OR HomeScreen에서 push
      diaryModel = context.watch<DiaryState>().diaryList[widget.index];
    } else if (widget.isLike) {
      // LikeHomeScreen에서 push
      diaryModel = context.watch<LikeState>().likeList[widget.index];
    } else {
      // FeedHomeScreen에서 push
      diaryModel = context.watch<FeedState>().feedList[widget.index];
    }

    _currentUserId = context.read<UserState>().userModel.uid;
    bool isLike = diaryModel.likes.contains(_currentUserId);
    _isLock = diaryModel.isLock;
    _isMyDiary = diaryModel.uid == _currentUserId;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Palette.background,
        actions: [
          if (_isMyDiary) ...[
            // 내 다이어리일 때
            GestureDetector(
              onTap: () {
                if (_isLock) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: '성장일기 공개',
                        message: '성장일기를 공개하면 피드에 게시됩니다.\n변경하시겠습니까?',
                        onConfirm: () {
                          _lockTap();
                        },
                      );
                    },
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CustomDialog(
                        title: '성장일기 비공개',
                        message: '성장일기를 비공개하면 피드에서 삭제됩니다.\n변경하시겠습니까?',
                        onConfirm: () {
                          _lockTap();
                        },
                      );
                    },
                  );
                }
              },
              child: _isLock
                  ? SvgPicture.asset('assets/icons/ic_lock.svg')
                  : SvgPicture.asset('assets/icons/ic_unlock.svg'),
            ),
            SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: '수정하기',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiaryUploadScreen(
                            isEditMode: true,
                            originalDiaryModel: diaryModel,
                          ),
                        ),
                      );
                    },
                  ),
                  PullDownMenuItem(
                    title: '삭제하기',
                    isDestructive: true,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialog(
                            title: '성장일기 삭제',
                            message: '성장일기를 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
                            onConfirm: () async {
                              try {
                                Navigator.pop(context);
                                await context
                                    .read<DiaryProvider>()
                                    .deleteDiary(diaryModel: diaryModel);
                                context
                                    .read<FeedProvider>()
                                    .deleteDiary(diaryId: diaryModel.diaryId);
                                context
                                    .read<LikeProvider>()
                                    .deleteDiary(diaryId: diaryModel.diaryId);
                                Navigator.pop(context);
                              } on CustomException catch (e) {
                                errorDialogWidget(context, e);
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
                buttonBuilder: (context, showMenu) => CupertinoButton(
                  onPressed: showMenu,
                  padding: EdgeInsets.zero,
                  child: SvgPicture.asset('assets/icons/ic_more.svg'),
                ),
              ),
            ),
          ] else ...[
            // 남의 다이어리일 때
            SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: PullDownButton(
                itemBuilder: (context) => [
                  PullDownMenuItem(
                    title: '신고하기',
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoActionSheet(
                            title: Text('신고 사유를 선택해주세요.'),
                            message: Text(
                                '신고는 반대의견을 나타내는 기능이 아닙니다.\n신고 사유에 맞지 않는 신고를 햇을 경우, 해당 신고는 처리되지 않습니다.'),
                            actions: [
                              // 상업적 광고 및 판매
                              CupertinoActionSheetAction(
                                child: Text(
                                  ReportType.ad.label,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: CupertinoColors.systemBlue,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await context
                                        .read<FeedProvider>()
                                        .reportDiary(
                                          diaryModel: diaryModel,
                                          countField: ReportType.ad.countField,
                                        );

                                    Navigator.pop(context);

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialog(
                                          title: '신고하기',
                                          message:
                                              '신고가 접수되었습니다.\n검토까지는 최대 24시간 소요됩니다.',
                                          hasCancelButton: false,
                                          onConfirm: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  } on CustomException catch (e) {
                                    Navigator.pop(context);
                                    errorDialogWidget(context, e);
                                  }
                                },
                              ),

                              // 욕설/비하
                              CupertinoActionSheetAction(
                                child: Text(
                                  ReportType.abuse.label,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: CupertinoColors.systemBlue,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await context
                                        .read<FeedProvider>()
                                        .reportDiary(
                                          diaryModel: diaryModel,
                                          countField:
                                              ReportType.abuse.countField,
                                        );

                                    Navigator.pop(context);

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialog(
                                          title: '신고하기',
                                          message:
                                              '신고가 접수되었습니다.\n검토까지는 최대 24시간 소요됩니다.',
                                          hasCancelButton: false,
                                          onConfirm: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  } on CustomException catch (e) {
                                    Navigator.pop(context);
                                    errorDialogWidget(context, e);
                                  }
                                },
                              ),

                              // 음란물
                              CupertinoActionSheetAction(
                                child: Text(
                                  ReportType.adult.label,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: CupertinoColors.systemBlue,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await context
                                        .read<FeedProvider>()
                                        .reportDiary(
                                          diaryModel: diaryModel,
                                          countField:
                                              ReportType.adult.countField,
                                        );

                                    Navigator.pop(context);

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialog(
                                          title: '신고하기',
                                          message:
                                              '신고가 접수되었습니다.\n검토까지는 최대 24시간 소요됩니다.',
                                          hasCancelButton: false,
                                          onConfirm: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  } on CustomException catch (e) {
                                    Navigator.pop(context);
                                    errorDialogWidget(context, e);
                                  }
                                },
                              ),

                              // 기타
                              CupertinoActionSheetAction(
                                child: Text(
                                  ReportType.other.label,
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    color: CupertinoColors.systemBlue,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 17,
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await context
                                        .read<FeedProvider>()
                                        .reportDiary(
                                          diaryModel: diaryModel,
                                          countField:
                                              ReportType.other.countField,
                                        );

                                    Navigator.pop(context);

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialog(
                                          title: '신고하기',
                                          message:
                                              '신고가 접수되었습니다.\n검토까지는 최대 24시간 소요됩니다.',
                                          hasCancelButton: false,
                                          onConfirm: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  } on CustomException catch (e) {
                                    Navigator.pop(context);
                                    errorDialogWidget(context, e);
                                  }
                                },
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              isDefaultAction: true,
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  color: CupertinoColors.systemBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 17,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                  PullDownMenuItem(
                    title: '차단하기',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomDialog(
                            title: '차단하기',
                            message:
                                '이 작성자의 성장일기가 목록에 노출되지 않으며,\n다시 해제하실 수 없습니다.',
                            onConfirm: () async {
                              try {
                                await context
                                    .read<FeedProvider>()
                                    .blockUser(targetUserUid: diaryModel.uid);

                                Navigator.pop(context);
                                Navigator.pop(context);
                              } on CustomException catch (e) {
                                Navigator.pop(context);
                                errorDialogWidget(context, e);
                              }
                            },
                          );
                        },
                      );
                    },
                    isDestructive: true,
                  ),
                ],
                buttonBuilder: (context, showMenu) => CupertinoButton(
                  onPressed: showMenu,
                  padding: EdgeInsets.zero,
                  child: SvgPicture.asset('assets/icons/ic_more.svg'),
                ),
              ),
            ),
          ],
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // 제목
              Center(
                child: Text(
                  diaryModel.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: Palette.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: 24),

              Row(
                children: [
                  // 프로필 사진
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Palette.lightGray,
                        width: 1.0,
                      ),
                      image: DecorationImage(
                        image: diaryModel.writer.profileImage == null
                            ? ExtendedAssetImageProvider(
                                "assets/icons/profile.png")
                            : ExtendedNetworkImageProvider(
                                diaryModel.writer.profileImage!),
                        fit: BoxFit.cover, // 이미지를 적절히 맞추는 옵션
                      ),
                    ),
                  ),
                  SizedBox(width: 6),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 닉네임
                      Text(
                        diaryModel.writer.nickname,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Palette.black,
                          letterSpacing: -0.4,
                        ),
                      ),

                      // 작성 날짜
                      Text(
                        DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(diaryModel.createAt.toDate()),
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 10,
                          color: Palette.mediumGray,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),

                  Spacer(),

                  Row(
                    children: [
                      // 좋아요 버튼
                      GestureDetector(
                        onTap: () async {
                          await _likeDiary(diaryModel);
                        },
                        child: isLike
                            ? Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 24,
                              )
                            : Icon(
                                Icons.favorite_border,
                                color: Palette.darkGray,
                                size: 24,
                              ),
                      ),
                      SizedBox(width: 5),

                      // 좋아요 카운트
                      Text(
                        diaryModel.likeCount.toString(), // 문자열로 변환
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 22,
                          color: Palette.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),

              // 구분선
              Divider(color: Palette.lightGray),
              SizedBox(height: 16),

              // 내용
              Text(
                diaryModel.desc,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Palette.darkGray,
                  letterSpacing: -0.4,
                  height: 21 / 14,
                ),
              ),
              SizedBox(height: 10),

              // 사진
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                itemCount: diaryModel.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 300,
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: ExtendedNetworkImageProvider(
                            diaryModel.imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
