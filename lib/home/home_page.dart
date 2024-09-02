import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pet_log/medical/medical_home_page.dart';
import 'package:pet_log/pallete.dart';
import 'package:pet_log/walk/walk_home_page.dart';

import '../diary/diary_home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "산책",
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Pallete.black,
                    letterSpacing: -0.5,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WalkHomePage()),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "더보기",
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Pallete.mediumGray,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/ic_home_more.svg',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "성장일기",
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Pallete.black,
                    letterSpacing: -0.5,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DiaryHomePage()),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "더보기",
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Pallete.mediumGray,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/ic_home_more.svg',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "진료기록",
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Pallete.black,
                    letterSpacing: -0.5,
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MedicalHomePage()),
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        "더보기",
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Pallete.mediumGray,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SvgPicture.asset(
                        'assets/icons/ic_home_more.svg',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
