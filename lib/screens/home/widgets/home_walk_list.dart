import 'package:flutter/material.dart';

import '../../../models/walk_model.dart';
import '../../walk/walk_home_screen.dart';
import '../../../common/widgets/pd_title_with_more_button.dart';
import 'home_content_empty.dart';
import 'home_walk_list_card.dart';

class HomeWalkList extends StatelessWidget {
  final List<WalkModel> walkList;

  const HomeWalkList({
    super.key,
    required this.walkList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PDTitleWithMoreButton(
          title: '산책',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalkHomeScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        walkList.isEmpty
            ? const HomeContentEmpty(title: '산책 기록이 없습니다')
            : Column(
                children: List.generate(
                  walkList.length,
                  (index) => WalkListCard(
                    walkModel: walkList[index],
                    index: index,
                  ),
                ),
              ),
      ],
    );
  }
}
