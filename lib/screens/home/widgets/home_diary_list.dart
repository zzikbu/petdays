import 'package:flutter/material.dart';

import '../../../models/diary_model.dart';
import '../../diary/diary_home_screen.dart';
import '../../../components/pd_title_with_more_button.dart';
import 'home_content_empty.dart';
import 'home_diary_list_card.dart';

class HomeDiaryList extends StatelessWidget {
  final List<DiaryModel> diaryList;

  const HomeDiaryList({
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
              MaterialPageRoute(builder: (context) => const DiaryHomeScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        diaryList.isEmpty
            ? const HomeContentEmpty(title: '성장일기가 없습니다')
            : Column(
                children: List.generate(
                  diaryList.length,
                  (index) => HomeDiaryListCard(
                    diaryModel: diaryList[index],
                    index: index,
                  ),
                ),
              ),
      ],
    );
  }
}
