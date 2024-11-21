import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../models/diary_model.dart';
import '../palette.dart';
import '../screens/diary/diary_detail_screen.dart';

class DiaryCardWidget extends StatelessWidget {
  final DiaryModel diaryModel;
  final int index;
  final DiaryType diaryType;
  final bool isLike;
  final bool showLock;

  const DiaryCardWidget({
    super.key,
    required this.diaryModel,
    required this.index,
    required this.diaryType,
    required this.isLike, // 좋아요 여부
    required this.showLock, // 자물쇠 표시 여부
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiaryDetailScreen(
              index: index,
              diaryType: diaryType,
            ),
          ),
        );
      },
      child: Stack(
        children: [
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
                image: ExtendedNetworkImageProvider(diaryModel.imageUrls[0]),
                fit: BoxFit.cover,
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
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        diaryModel.title,
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
                        if (!diaryModel.isLock) ...[
                          Icon(
                            isLike ? Icons.favorite : Icons.favorite_border,
                            color: isLike ? Colors.red : Palette.darkGray,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            diaryModel.likeCount.toString(),
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Palette.darkGray,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(width: 8),
                          Container(
                            width: 1,
                            height: 10,
                            color: Palette.mediumGray,
                          ),
                          SizedBox(width: 8),
                        ],
                        Text(
                          diaryModel.createdAt
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
                        if (showLock) ...[
                          SizedBox(width: 8),
                          SvgPicture.asset(
                            diaryModel.isLock
                                ? 'assets/icons/ic_lock.svg'
                                : 'assets/icons/ic_unlock.svg',
                            width: 14,
                            height: 14,
                            color: Palette.mediumGray,
                          ),
                        ],
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
  }
}
