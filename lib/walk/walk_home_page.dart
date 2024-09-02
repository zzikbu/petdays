import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pet_log/pallete.dart';
import 'package:pet_log/walk/walk_detail.page.dart';
import 'package:pet_log/walk/walk_select_pet_page.dart';

class WalkHomePage extends StatelessWidget {
  const WalkHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Pallete.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "산책",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Pallete.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
      backgroundColor: Pallete.background,
      body: Scrollbar(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WalkDetailPage(),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 20),
                height: 130,
                decoration: BoxDecoration(
                  color: Pallete.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Pallete.black.withOpacity(0.05),
                      offset: Offset(8, 8),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 14),
                    SizedBox(
                      height: 36,
                      child: ListView.builder(
                        padding: EdgeInsets.only(left: 14, right: 10),
                        scrollDirection: Axis.horizontal, // 수평
                        itemBuilder: (context, index) {
                          return Container(
                            width: 36,
                            margin: EdgeInsets.only(right: 4),
                            child: CircleAvatar(
                              backgroundColor: Pallete.lightGray,
                            ),
                          );
                        },
                        itemCount: 10,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 18,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "날짜",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Pallete.mediumGray,
                                letterSpacing: -0.35,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "2024.08.16 금",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Pallete.black,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "거리",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Pallete.mediumGray,
                                letterSpacing: -0.35,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "10.2KM",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Pallete.black,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 32,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "시간",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Pallete.mediumGray,
                                letterSpacing: -0.35,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "114분",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Pallete.black,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          itemCount: 9,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WalkSelectPetPage()),
          );
        },
        backgroundColor: Pallete.darkGray,
        elevation: 0, // 그림자 제거
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          Icons.add,
          color: Pallete.white,
        ),
      ),
    );
  }
}
