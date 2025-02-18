import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:petdays/components/show_custom_dialog.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../components/pd_app_bar.dart';
import '../../components/show_error_dialog.dart';
import '../../components/pd_circle_avatar.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/diary_model.dart';
import '../../palette.dart';
import '../../providers/diary/diary_provider.dart';
import '../../providers/diary/diary_state.dart';
import '../../providers/feed/feed_provider.dart';
import '../../providers/feed/feed_state.dart';
import '../../providers/like/like_provider.dart';
import '../../providers/like/like_state.dart';
import 'diary_upload_screen.dart';

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

enum DiaryType {
  my, // 나의 성장일기
  myLike, // 좋아요한 성장일기
  myOpen, // 공개한 성장일기
  allFeed, // 피드 (전체)
  hotFeed, // 피드 (HOT)
}

class DiaryDetailScreen extends StatefulWidget {
  final int index;
  final DiaryType diaryType;

  const DiaryDetailScreen({
    super.key,
    required this.index,
    required this.diaryType,
  });

  @override
  State<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends State<DiaryDetailScreen> {
  bool _isLiking = false;
  late final bool isMyDiary;
  late final String _currentUserId;

  /// watch를 통해 diaryModel 반환
  DiaryModel _getDiaryModel(BuildContext context, DiaryType diaryType, int index) {
    if (diaryType == DiaryType.my) {
      return context.watch<DiaryState>().diaryList[index];
    } else if (diaryType == DiaryType.myLike) {
      return context.watch<LikeState>().likeList[index];
    } else if (diaryType == DiaryType.myOpen) {
      return context.watch<DiaryState>().openDiaryList[index];
    } else if (diaryType == DiaryType.allFeed) {
      return context.watch<FeedState>().feedList[index];
    } else {
      return context.watch<FeedState>().hotFeedList[index];
    }
  }

  /// 좋아요
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
    } on CustomException catch (e) {
      showErrorDialog(context, e);
    }
  }

  /// 나의 성장일기 일 때 PullDownMenuItem 리스트 반환
  List<PullDownMenuItem> _buildMyDiaryActions({
    required BuildContext context,
    required DiaryModel diaryModel,
  }) {
    return [
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
          _showDeleteDialog(context, diaryModel);
        },
      ),
    ];
  }

  /// 나의 성장일기 아닐 때 PullDownMenuItem 리스트 반환
  List<PullDownMenuItem> _buildOtherDiaryActions(BuildContext context, DiaryModel diaryModel) {
    return [
      PullDownMenuItem(
        title: '신고하기',
        onTap: () {
          _showReportDialog(context, diaryModel);
        },
      ),
      PullDownMenuItem(
        title: '차단하기',
        onTap: () {
          _showBlockDialog(context, diaryModel);
        },
        isDestructive: true,
      ),
    ];
  }

  /// 삭제하기
  Future<void> _showDeleteDialog(BuildContext context, DiaryModel diaryModel) async {
    showCustomDialog(
      context: context,
      title: '성장일기 삭제',
      message: '성장일기를 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
      onConfirm: () async {
        try {
          await context.read<DiaryProvider>().deleteDiary(diaryModel: diaryModel);
          context.read<FeedProvider>().deleteDiary(diaryId: diaryModel.diaryId);
          context.read<LikeProvider>().deleteDiary(diaryId: diaryModel.diaryId);
          Navigator.pop(context);
          Navigator.pop(context);
        } on CustomException catch (e) {
          showErrorDialog(context, e);
        }
      },
    );
  }

  /// 신고하기
  Future<void> _showReportDialog(BuildContext context, DiaryModel diaryModel) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return _buildReportDialog(context, diaryModel);
      },
    );
  }

  /// 신고하기 CupertinoActionSheet
  Widget _buildReportDialog(BuildContext context, DiaryModel diaryModel) {
    return CupertinoActionSheet(
      title: Text('신고 사유를 선택해주세요.'),
      message: Text(
        '신고는 반대의견을 나타내는 기능이 아닙니다.\n신고 사유에 맞지 않는 신고를 햇을 경우, 해당 신고는 처리되지 않습니다.',
      ),
      actions: [
        _buildReportAction(ReportType.ad, diaryModel),
        _buildReportAction(ReportType.abuse, diaryModel),
        _buildReportAction(ReportType.adult, diaryModel),
        _buildReportAction(ReportType.other, diaryModel),
      ],
      cancelButton: _buildCancelAction(context),
    );
  }

  /// 차단하기
  Future<void> _showBlockDialog(BuildContext context, DiaryModel diaryModel) async {
    showCustomDialog(
      context: context,
      title: '차단하기',
      message: '이 작성자의 성장일기가 목록에 노출되지 않으며,\n다시 해제하실 수 없습니다.',
      onConfirm: () async {
        try {
          await context.read<FeedProvider>().blockUser(targetUserUid: diaryModel.uid);
          await context.read<FeedProvider>().getFeedList();

          if (widget.diaryType == DiaryType.myLike) {
            await context.read<LikeProvider>().getLikeList();
          }

          Navigator.pop(context);
          Navigator.pop(context);
        } on CustomException catch (e) {
          Navigator.pop(context);
          showErrorDialog(context, e);
        }
      },
    );
  }

  /// 신고하기 취소
  Widget _buildCancelAction(BuildContext context) {
    return CupertinoActionSheetAction(
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
    );
  }

  /// 신고하기 액션
  Widget _buildReportAction(ReportType reportType, DiaryModel diaryModel) {
    return CupertinoActionSheetAction(
      child: Text(
        reportType.label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          color: CupertinoColors.systemBlue,
          fontWeight: FontWeight.w400,
          fontSize: 17,
        ),
      ),
      onPressed: () async {
        try {
          await context.read<FeedProvider>().reportDiary(
                diaryModel: diaryModel,
                countField: reportType.countField,
              );

          Navigator.pop(context);
          _showReportSuccessDialog(context);
        } on CustomException catch (e) {
          Navigator.pop(context);
          showErrorDialog(context, e);
        }
      },
    );
  }

  /// 신고하기 성공 다이얼로그
  Future<void> _showReportSuccessDialog(BuildContext context) async {
    showCustomDialog(
      context: context,
      title: '신고하기',
      message: '신고가 접수되었습니다.\n검토까지는 최대 24시간 소요됩니다.',
      hasCancelButton: false,
      onConfirm: () {
        Navigator.pop(context);
      },
    );
  }

  /// 제목
  Widget _buildTitle({
    required String title,
  }) {
    return Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontWeight: FontWeight.w600,
          fontSize: 22,
          color: Palette.black,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  /// 프로필이미지
  Widget _buildProfileImage(String? profileImageUrl) {
    return PDCircleAvatar(
      imageUrl: profileImageUrl,
      size: 36,
    );
  }

  /// 닉네임 & 작성날짜
  Widget _buildNicknameAndDate({
    required String nickname,
    required DateTime createdAt,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nickname,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Palette.black,
            letterSpacing: -0.4,
          ),
        ),
        Text(
          DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w400,
            fontSize: 10,
            color: Palette.mediumGray,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  /// 좋아요 버튼
  Widget _buildLikeButton({
    required DiaryModel diaryModel,
    required bool isLike,
  }) {
    return GestureDetector(
      onTap: _isLiking
          ? null
          : () async {
              setState(() {
                _isLiking = true;
              });

              try {
                await _likeDiary(diaryModel);
              } finally {
                if (mounted) {
                  setState(() {
                    _isLiking = false;
                  });
                }
              }
            },
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: child,
          );
        },
        child: _isLiking
            ? SizedBox(
                key: ValueKey('processing'),
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  strokeWidth: 2,
                ),
              )
            : isLike
                ? Icon(
                    key: ValueKey('liked'),
                    Icons.favorite,
                    color: Colors.red,
                    size: 24,
                  )
                : Icon(
                    key: ValueKey('unliked'),
                    Icons.favorite_border,
                    color: Palette.darkGray,
                    size: 24,
                  ),
      ),
    );
  }

  /// 좋아요 카운트
  Widget _buildLikeCount({
    required int likeCount,
  }) {
    return Text(
      likeCount.toString(),
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w500,
        fontSize: 22,
        color: Palette.black,
        letterSpacing: -0.5,
      ),
    );
  }

  /// 내용
  Widget _buildDesc({
    required String desc,
  }) {
    return Text(
      desc,
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: Palette.darkGray,
        letterSpacing: -0.4,
        height: 21 / 14,
      ),
    );
  }

  /// 이미지
  Widget _buildImageList({
    required List<String> imageUrls,
  }) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      primary: false,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Container(
          height: 300,
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
              image: ExtendedNetworkImageProvider(imageUrls[index]),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<User>().uid;
  }

  @override
  Widget build(BuildContext context) {
    DiaryModel diaryModel = _getDiaryModel(
      context,
      widget.diaryType,
      widget.index,
    );

    bool isLike = diaryModel.likes.contains(_currentUserId);
    bool isLock = diaryModel.isLock;
    bool isMyDiary = diaryModel.uid == _currentUserId;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: PDAppBar(
        actions: [
          if (isMyDiary) ...[
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: PullDownButton(
                itemBuilder: (context) => _buildMyDiaryActions(
                  context: context,
                  diaryModel: diaryModel,
                ),
                buttonBuilder: (context, showMenu) => CupertinoButton(
                  onPressed: showMenu,
                  padding: EdgeInsets.zero,
                  child: SvgPicture.asset('assets/icons/ic_more.svg'),
                ),
              ),
            ),
          ] else ...[
            SizedBox(width: 14),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: PullDownButton(
                itemBuilder: (context) => _buildOtherDiaryActions(
                  context,
                  diaryModel,
                ),
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
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 제목
              SizedBox(height: 20),
              _buildTitle(title: diaryModel.title),
              SizedBox(height: 24),

              Row(
                children: [
                  /// 프로필 이미지
                  _buildProfileImage(diaryModel.writer.profileImage),
                  SizedBox(width: 6),

                  /// 닉네임 & 작성 날짜
                  _buildNicknameAndDate(
                    nickname: diaryModel.writer.nickname,
                    createdAt: diaryModel.createdAt.toDate(),
                  ),
                  Spacer(),
                  if (!isLock)
                    Row(
                      children: [
                        /// 좋아요 버튼
                        _buildLikeButton(
                          diaryModel: diaryModel,
                          isLike: isLike,
                        ),
                        SizedBox(width: 5),

                        /// 좋아요 카운트
                        _buildLikeCount(likeCount: diaryModel.likeCount),
                      ],
                    ),
                ],
              ),

              /// 구분선
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Palette.lightGray),
              ),

              /// 내용
              _buildDesc(desc: diaryModel.desc),
              SizedBox(height: 10),

              /// 사진
              _buildImageList(imageUrls: diaryModel.imageUrls),
            ],
          ),
        ),
      ),
    );
  }
}
