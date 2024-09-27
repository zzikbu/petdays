import 'package:flutter/material.dart';
import 'package:pet_log/walk/walk_map_page.dart';

import 'components/next_button.dart';
import 'dummy.dart';
import 'medical/medical_write_page.dart';
import 'palette.dart';

class SelectPetPage extends StatelessWidget {
  final bool isFromMedicalPage;

  const SelectPetPage({
    super.key,
    required this.isFromMedicalPage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  isFromMedicalPage ? '누구와 병원에 갔나요?' : '누구와 산책하나요?',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Palette.black,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  isFromMedicalPage ? '중복 선택이 불가능합니다.' : '중복 선택이 가능합니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Palette.mediumGray,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 150, // 높이
                ),
                itemCount: dummyPets.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Palette.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: index == 2 ? Palette.black : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Palette.black.withOpacity(0.05),
                          offset: Offset(8, 8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(dummyPets[index]['image']!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          dummyPets[index]['name']!,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Palette.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NextButton(
        isActive: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  isFromMedicalPage ? MedicalWritePage() : WalkMapPage(),
            ),
          );
        },
        buttonText: "시작하기",
      ),
    );
  }
}
