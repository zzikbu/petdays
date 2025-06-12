import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../common/widgets/pd_circle_avatar.dart';
import '../../../domain/model/pet_model.dart';
import '../../../palette.dart';
import 'home_pet_empty.dart';

class HomePetCarousel extends StatefulWidget {
  final List<PetModel> petList;

  const HomePetCarousel({
    super.key,
    required this.petList,
  });

  @override
  State<HomePetCarousel> createState() => _HomePetCarouselState();
}

class _HomePetCarouselState extends State<HomePetCarousel> {
  final CarouselSliderController _carouselController = CarouselSliderController();

  int _indicatorIndex = 0;

  // 이름 & 만난 날 계산
  String _getNameAndDaysSinceMeeting({
    required String name,
    required String meetingDateString,
  }) {
    DateTime meetingDate = DateTime.parse(meetingDateString);
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(meetingDate);
    return '$name\n만난 지 ${difference.inDays}일째';
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
    return '$ageInYears살 $breed';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      color: Palette.mainGreen,
      child: widget.petList.isEmpty
          ? const HomePetEmpty()
          : Column(
              children: [
                const SizedBox(height: 68),
                CarouselSlider(
                  carouselController: _carouselController,
                  items: widget.petList.map(
                    (petModel) {
                      return Builder(
                        builder: (context) {
                          return GestureDetector(
                            onTap: () => context.go('/home/pet_detail/$_indicatorIndex'),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: Palette.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    // 사진
                                    PDCircleAvatar(
                                      imageUrl: petModel.image,
                                      size: 100,
                                    ),
                                    const SizedBox(width: 30),

                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 이름 & 만난 날 계산
                                        Text(
                                          _getNameAndDaysSinceMeeting(
                                            name: petModel.name,
                                            meetingDateString: petModel.firstMeetingDate,
                                          ),
                                          style: const TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            color: Palette.black,
                                            letterSpacing: -0.5,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 6),

                                        // 나이 계산 & 품종
                                        Text(
                                          _getAgeAndBreed(
                                            birthDateString: petModel.birthDay,
                                            breed: petModel.breed,
                                          ),
                                          style: const TextStyle(
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
                const SizedBox(height: 20),

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
