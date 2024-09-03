import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/diary/diary_detail_page.dart';
import 'package:pet_log/pallete.dart';
import 'package:pet_log/search/search_page.dart';
import 'package:pet_log/select_pet_page.dart';

import '../dummy.dart';
import 'medical_detail_page.dart';

class MedicalHomePage extends StatelessWidget {
  const MedicalHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Pallete.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "진료기록",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Pallete.black,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              },
              child: SvgPicture.asset('assets/icons/ic_magnifier.svg'),
            ),
          ),
        ],
      ),
      body: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemCount: dummyPets.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicalDetailPage()),
                );
              },
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    height: 220,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(dummyPets[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Pallete.feedBorder,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Pallete.black.withOpacity(0.05),
                          offset: Offset(8, 8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 20,
                    child: Container(
                      height: 88,
                      decoration: BoxDecoration(
                        color: Pallete.white.withOpacity(0.94),
                        border: Border(
                          left: BorderSide(
                            color: Pallete.feedBorder,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                          right: BorderSide(
                            color: Pallete.feedBorder,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                          bottom: BorderSide(
                            color: Pallete.feedBorder,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 22, left: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/icons/ic_unlock_small.svg',
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '2024.08.14',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Pallete.mediumGray,
                                    letterSpacing: -0.35,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2),
                              child: Text(
                                '다같이 애견카페 가서 놀은 날',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Pallete.black,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SelectPetPage(isFromMedicalPage: true),
            ),
          );
        },
        backgroundColor: Pallete.darkGray,
        elevation: 0, // 그림자 제거
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          Icons.edit,
          color: Pallete.white,
        ),
      ),
    );
  }
}
