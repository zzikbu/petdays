import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/diary_model.dart';
import '../../../palette.dart';

class HomeDiaryListCard extends StatelessWidget {
  final DiaryModel diaryModel;
  final int index;

  const HomeDiaryListCard({
    super.key,
    required this.diaryModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/home/diary_detail/$index'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 70,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Palette.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Palette.black.withOpacity(0.05),
              offset: const Offset(8, 8),
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
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Palette.black,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),

              // 날짜
              Text(
                DateFormat('yyyy-MM-dd').format(diaryModel.createdAt.toDate()),
                style: const TextStyle(
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
  }
}
