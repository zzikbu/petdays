import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pet_log/components/home_section_header.dart';
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
  int currentPetPageIndex = 0;

  final CarouselSliderController _myPetCarouselSliderController =
      CarouselSliderController();

  List colorList = [
    Colors.white,
    Colors.blue,
    Colors.grey,
    Colors.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 260,
              color: Pallete.mainGreen,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24, bottom: 42),
                  child: CarouselSlider(
                    carouselController: _myPetCarouselSliderController,
                    items: colorList.map(
                      (color) {
                        return Builder(
                          builder: (context) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Pallete.lightGray,
                                          width: 0.4,
                                        ),
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/icons/dummy_dog.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 30),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'D+2100',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 22,
                                            color: Pallete.black,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Text(
                                          '보리',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 18,
                                            color: Pallete.black,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        Text(
                                          '5살 치와와',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Pallete.mediumGray,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ).toList(),
                    options: CarouselOptions(
                      initialPage: 0,
                      height: 150,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          currentPetPageIndex = index;
                          print(index);
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  HomeSectionHeader(
                    title: '산책',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WalkHomePage()),
                      );
                    },
                  ),
                  SizedBox(height: 40),
                  HomeSectionHeader(
                    title: '성장일기',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DiaryHomePage()),
                      );
                    },
                  ),
                  SizedBox(height: 40),
                  HomeSectionHeader(
                    title: '진료기록',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MedicalHomePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
