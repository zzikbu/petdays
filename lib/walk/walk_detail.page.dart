import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/pallete.dart';

import '../components/info_column.dart';

class WalkDetailPage extends StatelessWidget {
  const WalkDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pallete.background,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {},
              child: SvgPicture.asset('assets/icons/ic_delete.svg'),
            ),
          ),
        ],
      ),
      backgroundColor: Pallete.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            InfoColumn(
              title: '함께한 반려동물',
              content: '망고, 보리',
            ),
            SizedBox(
              height: 20,
            ),
            InfoColumn(
              title: '날짜',
              content: '2024.08.14 수요일',
            ),
            SizedBox(
              height: 20,
            ),
            InfoColumn(
              title: '시간',
              content: '14:08 ~ 16:02 (114분)',
            ),
            SizedBox(
              height: 20,
            ),
            InfoColumn(
              title: '거리',
              content: '10.2KM',
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 200,
              color: Pallete.lightGray,
            )
          ],
        ),
      ),
    );
  }
}
