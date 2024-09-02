import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/pallete.dart';

import '../components/info_column.dart';

class MedicalDetailPage extends StatelessWidget {
  const MedicalDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pallete.background,
        scrolledUnderElevation: 0,
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
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              InfoColumn(
                title: '진료받은 반려동물',
                content: '나비',
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '진료일',
                content: '2024.08.14 수요일',
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '이유',
                content: '4차 예방접종',
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '병원',
                content: '새싹동물병원',
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '수의사',
                content: '이승민',
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '메모',
                content:
                    '수의사가 접종 후 경미한 부종은 정상적인 반응일 수 있다고 했다. 그러나 증상이 계속되거나 심해질 경우에는 추가적인 검사가 필요하다고 말했다.',
              ),
              SizedBox(height: 10),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    height: 300,
                    color: Pallete.lightGray,
                    margin: EdgeInsets.symmetric(vertical: 10),
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
