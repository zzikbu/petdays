import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/components/custom_dialog.dart';
import 'package:pet_log/components/info_column.dart';
import 'package:pet_log/dummy.dart';
import 'package:pet_log/palette.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MedicalDetailScreen extends StatelessWidget {
  const MedicalDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem(
                  title: '수정하기',
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         MedicalWritePage(isEditMode: true),
                    //   ),
                    // );
                  },
                ),
                PullDownMenuItem(
                  title: '삭제하기',
                  isDestructive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          title: '진료기록 삭제',
                          message: '진료기록을 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
                          onConfirm: () {
                            print('삭제됨');
                          },
                        );
                      },
                    );
                  },
                ),
              ],
              buttonBuilder: (context, showMenu) => CupertinoButton(
                onPressed: showMenu,
                padding: EdgeInsets.zero,
                child: SvgPicture.asset('assets/icons/ic_more.svg'),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Palette.background,
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
                itemCount: dummyPets.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 300,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(dummyPets[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
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
