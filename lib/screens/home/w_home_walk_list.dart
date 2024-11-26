import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petdays/models/walk_model.dart';

import '../../palette.dart';
import '../walk/walk_detail_screen.dart';
import '../walk/walk_home_screen.dart';
import 'w_home_section_header.dart';

class HomeWalkListWidget extends StatelessWidget {
  final List<WalkModel> walkList;

  const HomeWalkListWidget({
    super.key,
    required this.walkList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HomeSectionHeaderWidget(
          title: '산책',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WalkHomeScreen()),
            );
          },
        ),
        SizedBox(height: 10),
        walkList.isEmpty
            ? Container(
                margin: EdgeInsets.only(bottom: 12),
                height: 70,
                decoration: BoxDecoration(
                  color: Palette.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Palette.black.withOpacity(0.05),
                      offset: Offset(8, 8),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "산책 기록이 없습니다",
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Palette.mediumGray,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              )
            : Column(
                children: List.generate(
                  walkList.length > 3 ? 3 : walkList.length, // 최대 3개
                  (index) {
                    final walkModel = walkList[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WalkDetailScreen(index: index),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        height: 70,
                        decoration: BoxDecoration(
                          color: Palette.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Palette.black.withOpacity(0.05),
                              offset: Offset(8, 8),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 날짜
                              Text(
                                DateFormat('yyyy-MM-dd E', 'ko_KR')
                                    .format(walkModel.createdAt.toDate()),
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Palette.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(width: 10),

                              // 사진
                              Expanded(
                                child: SizedBox(
                                  height: 36,
                                  child: SingleChildScrollView(
                                    primary: false,
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: List.generate(
                                        walkModel.pets.length,
                                        (index) {
                                          final petModel =
                                              walkModel.pets[index];
                                          return Container(
                                            width: 36,
                                            height: 36,
                                            margin: EdgeInsets.only(right: 4),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.grey,
                                                  width: 0.4,
                                                ),
                                                image: DecorationImage(
                                                  image:
                                                      ExtendedNetworkImageProvider(
                                                          petModel.image),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
