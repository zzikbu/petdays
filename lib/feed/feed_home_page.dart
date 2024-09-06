import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../diary/diary_detail_page.dart';
import '../dummy.dart';
import '../pallete.dart';
import '../search/search_page.dart';

class FeedHomePage extends StatefulWidget {
  const FeedHomePage({super.key});

  @override
  _FeedHomePageState createState() => _FeedHomePageState();
}

class _FeedHomePageState extends State<FeedHomePage> {
  bool isAllSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Pallete.background,
        scrolledUnderElevation: 0,
        title: Container(
          height: 48,
          width: 170,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAllSelected = true; // Set "전체" as selected
                    });
                  },
                  child: Container(
                    height: 42,
                    width: 80,
                    decoration: BoxDecoration(
                      color: isAllSelected
                          ? Pallete.mainGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        '전체',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color:
                              isAllSelected ? Pallete.white : Pallete.lightGray,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isAllSelected = false; // Set "HOT" as selected
                    });
                  },
                  child: Container(
                    height: 42,
                    width: 80,
                    decoration: BoxDecoration(
                      color: !isAllSelected
                          ? Pallete.mainGreen
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Text(
                        'HOT',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: !isAllSelected
                              ? Pallete.white
                              : Pallete.lightGray,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          print("새로고침");
          await Future.delayed(Duration(seconds: 1));
        },
        child: Scrollbar(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: dummyPets.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DiaryDetailPage()),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Pallete.feedBorder,
                          width: 1,
                        ),
                        image: DecorationImage(
                          image: AssetImage(dummyPets[index]['image']!),
                          fit: BoxFit.cover,
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
                          color: Pallete.white.withOpacity(0.9),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Text(
                                  '다같이 애견카페 가서 놀은 날 다같이 애견카페 가서 놀은 날 다같이 애견카페 가서 놀은 날 ',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
      ),
    );
  }
}
