import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/components/custom_dialog.dart';
import 'package:pet_log/components/info_column.dart';
import 'package:pet_log/palette.dart';

class WalkDetailScreen extends StatelessWidget {
  const WalkDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.background,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CustomDialog(
                      title: '산책 기록 삭제',
                      message: '산책 기록을 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
                      onConfirm: () {
                        print('삭제됨');
                      },
                    );
                  },
                );
              },
              child: SvgPicture.asset('assets/icons/ic_delete.svg'),
            ),
          ),
        ],
      ),
      backgroundColor: Palette.background,
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
              decoration: BoxDecoration(
                color: Palette.lightGray,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 200,
            )
          ],
        ),
      ),
    );
  }
}
