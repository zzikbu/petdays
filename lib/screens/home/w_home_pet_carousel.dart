import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:petdays/components/w_avatar.dart';
import 'package:petdays/models/pet_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../palette.dart';
import '../pet/pet_detail_screen.dart';
import '../pet/pet_upload_screen.dart';

class HomePetCarouselWidget extends StatefulWidget {
  final List<PetModel> petList;

  const HomePetCarouselWidget({
    super.key,
    required this.petList,
  });

  @override
  State<HomePetCarouselWidget> createState() => _HomePetCarouselWidgetState();
}

class _HomePetCarouselWidgetState extends State<HomePetCarouselWidget> {
  int _indicatorIndex = 0;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // 이름 & 만난 날 계산
  String _getNameAndDaysSinceMeeting({
    required String name,
    required String meetingDateString,
  }) {
    DateTime meetingDate = DateTime.parse(meetingDateString);
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(meetingDate);
    return '${name}\n만난 지 ${difference.inDays}일째';
  }

  // 나이 계산 & 품종
  String _getAgeAndBreed({
    required String birthDateString,
    required String breed,
  }) {
    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime currentDate = DateTime.now();
    Duration ageDifference = currentDate.difference(birthDate);
    int ageInYears = ageDifference.inDays ~/ 365; // 연도로 변환
    return '${ageInYears}살 ${breed}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      color: Palette.mainGreen,
      child: widget.petList.isEmpty
          ? Padding(
              padding: const EdgeInsets.only(top: 68, bottom: 42),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PetUploadScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Palette.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        size: 32,
                        color: Palette.black,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '반려동물 추가하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Palette.black,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                SizedBox(height: 68),
                CarouselSlider(
                  carouselController: _carouselController,
                  items: widget.petList.map(
                    (petModel) {
                      return Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PetDetailScreen(
                                        index: _indicatorIndex)),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: Palette.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    // 사진
                                    AvatarWidget(
                                      imageUrl: petModel.image,
                                      width: 100,
                                      height: 100,
                                    ),
                                    SizedBox(width: 30),

                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 이름 & 만난 날 계산
                                        Text(
                                          _getNameAndDaysSinceMeeting(
                                            name: petModel.name,
                                            meetingDateString:
                                                petModel.firstMeetingDate,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            color: Palette.black,
                                            letterSpacing: -0.5,
                                            height: 1.2,
                                          ),
                                        ),
                                        SizedBox(height: 6),

                                        // 나이 계산 & 품종
                                        Text(
                                          _getAgeAndBreed(
                                            birthDateString: petModel.birthDay,
                                            breed: petModel.breed,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Palette.mediumGray,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
                    enableInfiniteScroll: false, // 무한 스크롤 비활성화
                    onPageChanged: (index, reason) {
                      setState(() {
                        _indicatorIndex = index;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),

                // Indicator
                AnimatedSmoothIndicator(
                  activeIndex: _indicatorIndex,
                  count: widget.petList.length,
                  effect: JumpingDotEffect(
                    spacing: 6.0,
                    radius: 3.0,
                    dotWidth: 6.0,
                    dotHeight: 6.0,
                    paintStyle: PaintingStyle.fill,
                    strokeWidth: 0,
                    dotColor: Palette.white.withOpacity(0.5),
                    activeDotColor: Palette.white,
                  ),
                ),
              ],
            ),
    );
  }
}
