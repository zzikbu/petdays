import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petdays/models/diary_model.dart';

import '../../palette.dart';
import '../diary/diary_detail_screen.dart';
import '../diary/diary_home_screen.dart';
import '../../components/pd_title_with_more_button.dart';

class HomeDiaryListWidget extends StatelessWidget {
  final List<DiaryModel> diaryList;

  const HomeDiaryListWidget({
    super.key,
    required this.diaryList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PDTitleWithMoreButton(
          title: '성장일기',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DiaryHomeScreen()),
            );
          },
        ),
        SizedBox(height: 10),
        diaryList.isEmpty
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
                    "성장일기가 없습니다",
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
                  diaryList.length > 3 ? 3 : diaryList.length, // 최대 3개
                  (index) {
                    DiaryModel diaryModel = diaryList[index];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiaryDetailScreen(
                              index: index,
                              diaryType: DiaryType.my,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        height: 70,
                        width: double.infinity,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 제목
                              Text(
                                diaryModel.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Palette.black,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              SizedBox(height: 2),

                              // 날짜
                              Text(
                                DateFormat('yyyy-MM-dd').format(diaryModel.createdAt.toDate()),
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Palette.mediumGray,
                                  letterSpacing: -0.4,
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
