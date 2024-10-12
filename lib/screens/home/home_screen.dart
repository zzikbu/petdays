import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/components/home_section_header.dart';
import 'package:pet_log/dummy.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/models/medical_model.dart';
import 'package:pet_log/models/pet_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/diary/diary_provider.dart';
import 'package:pet_log/providers/diary/diary_state.dart';
import 'package:pet_log/providers/medical/medical_provider.dart';
import 'package:pet_log/providers/medical/medical_state.dart';
import 'package:pet_log/providers/pet/pet_provider.dart';
import 'package:pet_log/providers/pet/pet_state.dart';
import 'package:pet_log/screens/diary/diary_detail_screen.dart';
import 'package:pet_log/screens/diary/diary_home_screen.dart';
import 'package:pet_log/screens/medical/medical_detail_screen.dart';
import 'package:pet_log/screens/medical/medical_home_screen.dart';
import 'package:pet_log/screens/walk/walk_detail_screen.dart';
import 'package:pet_log/screens/walk/walk_home_screen.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  late final PetProvider petProvider;
  late final DiaryProvider diaryProvider;
  late final MedicalProvider medicalProvider;

  int _indicatorIndex = 0;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // 다른 화면에서 돌아올 때
  // 데이터를 매번 가져오지 않도록
  @override
  bool get wantKeepAlive => true;

  // 만난 날 계산
  String _calculateDaysSinceMeeting(String meetingDateString) {
    DateTime meetingDate = DateTime.parse(meetingDateString);
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(meetingDate);
    return 'D+${difference.inDays}';
  }

  // 나이 계산 & 품종
  String _calculateAge(String birthDateString, String breed) {
    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime currentDate = DateTime.now();
    Duration ageDifference = currentDate.difference(birthDate);
    int ageInYears = ageDifference.inDays ~/ 365; // 연도로 변환
    return '${ageInYears}살 ${breed}';
  }

  // 데이터 가져오기
  void _getData() {
    String uid = context.read<User>().uid;

    // 위젯들이 만들어 진 후에
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await petProvider.getPetList(uid: uid); // 펫 가져오기
        await diaryProvider.getDiaryList(uid: uid); // 성장일기 가져오기
        await medicalProvider.getMedicalList(uid: uid); // 진료기록 가져오기
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    petProvider = context.read<PetProvider>();
    diaryProvider = context.read<DiaryProvider>();
    medicalProvider = context.read<MedicalProvider>();

    _getData(); // 데이터 가져오기
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    PetState petState = context.watch<PetState>();
    List<PetModel> petList = petState.petList;

    DiaryState diaryState = context.watch<DiaryState>();
    List<DiaryModel> diaryList = diaryState.diaryList;

    MedicalState medicalState = context.watch<MedicalState>();
    List<MedicalModel> medicalList = medicalState.medicalList;

    if (petState.petStatus == PetStatus.fetching ||
        diaryState.diaryStatus == DiaryStatus.fetching ||
        medicalState.medicalStatus == MedicalStatus.fetching) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Palette.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 최상단 초록색 영역
            Container(
              height: 260,
              color: Palette.mainGreen,
              child: Column(
                children: [
                  SizedBox(height: 68),

                  // TODO 값 비었을 때 펫 추가 버튼 구현 해주기
                  petList.isEmpty
                      ? SizedBox()
                      : CarouselSlider(
                          // Carousel 영역
                          carouselController: _carouselController,
                          items: dummyPets.map(
                            (pet) {
                              return Builder(
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      print(_indicatorIndex);
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 24),
                                      decoration: BoxDecoration(
                                        color: Palette.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          children: [
                                            // 사진
                                            Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Palette.lightGray,
                                                  width: 0.4,
                                                ),
                                                image: DecorationImage(
                                                  image:
                                                      ExtendedNetworkImageProvider(
                                                          petList[_indicatorIndex]
                                                              .image),
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
                                                // 만난 날 계산
                                                Text(
                                                  _calculateDaysSinceMeeting(
                                                      petList[_indicatorIndex]
                                                          .firstMeetingDate),
                                                  style: TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 22,
                                                    color: Palette.black,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),

                                                // 이름
                                                Text(
                                                  petList[_indicatorIndex].name,
                                                  style: TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    color: Palette.black,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),

                                                // 나이 계산 & 품종
                                                Text(
                                                  _calculateAge(
                                                      petList[_indicatorIndex]
                                                          .birthDay,
                                                      petList[_indicatorIndex]
                                                          .breed),
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
                            onPageChanged: (index, reason) {
                              setState(() {
                                // _indicatorIndex가 petList의 길이를 초과하지 못하도록
                                _indicatorIndex = index % petList.length;
                              });
                            },
                          ),
                        ),
                  SizedBox(height: 20),

                  // Indicator
                  AnimatedSmoothIndicator(
                    activeIndex: _indicatorIndex,
                    count: petList.length,
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
            ),
            SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // 산책
                  HomeSectionHeader(
                    title: '산책',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WalkHomeScreen()),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  dummyPets.isEmpty
                      ? Container(
                          margin: EdgeInsets.only(bottom: 12),
                          height: 70,
                          decoration: BoxDecoration(
                            color: Palette.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Palette.black.withOpacity(0.05),
                                offset: Offset(8, 8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "산책 기록이 없습니다",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Palette.mediumGray,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: List.generate(
                            dummyPets.length > 3
                                ? 3
                                : dummyPets.length, // 최대 3개
                            (index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WalkDetailScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Palette.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Palette.black.withOpacity(0.05),
                                        offset: Offset(8, 8),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 14),
                                      Text(
                                        "2024.08.16 금",
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                          color: Palette.black,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: ListView.builder(
                                          padding: EdgeInsets.only(right: 14),
                                          scrollDirection:
                                              Axis.horizontal, // 수평 스크롤
                                          itemCount: dummyPets.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              width: 36,
                                              height: 36,
                                              margin: EdgeInsets.only(right: 4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Palette.lightGray,
                                                  width: 0.4,
                                                ),
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                    dummyPets[index]['image']!,
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                  SizedBox(height: 28),

                  // 성장일기
                  Column(
                    children: [
                      HomeSectionHeader(
                        title: '성장일기',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DiaryHomeScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      if (diaryList.isEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          height: 70,
                          decoration: BoxDecoration(
                            color: Palette.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Palette.black.withOpacity(0.05),
                                offset: Offset(8, 8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "성장일기가 없습니다",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Palette.mediumGray,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: List.generate(
                            diaryList.length > 3
                                ? 3
                                : diaryList.length, // 최대 3개
                            (index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DiaryDetailScreen(
                                            diaryModel: diaryList[index])),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Palette.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Palette.black.withOpacity(0.05),
                                        offset: Offset(8, 8),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 제목
                                        Text(
                                          diaryList[index].title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: Palette.black,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                        SizedBox(height: 2),

                                        // 날짜
                                        Text(
                                          DateFormat('yyyy-MM-dd').format(
                                            diaryList[index].createAt.toDate(),
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            color: Palette.mediumGray,
                                            letterSpacing: -0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 28),

                  // 진료기록
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HomeSectionHeader(
                        title: '진료기록',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MedicalHomeScreen()),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      if (medicalList.isEmpty)
                        Container(
                          margin: EdgeInsets.only(bottom: 12),
                          height: 70,
                          decoration: BoxDecoration(
                            color: Palette.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Palette.black.withOpacity(0.05),
                                offset: Offset(8, 8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "진료기록이 없습니다",
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                color: Palette.mediumGray,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal, // 수평 스크롤 설정
                          child: Row(
                            children: List.generate(
                              medicalList.length > 3
                                  ? 7
                                  : medicalList.length, // 최대 7개
                              (index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MedicalDetailScreen(
                                                  medicalModel:
                                                      medicalList[index])),
                                    );
                                  },

                                  // 흰색 카드 영역
                                  child: Container(
                                    margin:
                                        EdgeInsets.only(right: 12, bottom: 10),
                                    height: 150,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Palette.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Palette.black.withOpacity(0.05),
                                          offset: Offset(8, 8),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              // 사진
                                              Container(
                                                width: 36,
                                                height: 36,
                                                margin:
                                                    EdgeInsets.only(right: 4),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Palette.lightGray,
                                                    width: 0.4,
                                                  ),
                                                  image: DecorationImage(
                                                    image:
                                                        ExtendedNetworkImageProvider(
                                                            medicalList[index]
                                                                .pet
                                                                .image),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              // SizedBox(width: 4),

                                              // 이름
                                              Expanded(
                                                child: Text(
                                                  medicalList[index].pet.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: 'Pretendard',
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    color: Palette.black,
                                                    letterSpacing: -0.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 12),

                                          // 방문 날짜
                                          Text(
                                            medicalList[index].visitDate,
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Palette.mediumGray,
                                              letterSpacing: -0.4,
                                            ),
                                          ),
                                          SizedBox(height: 6),

                                          // 이유
                                          Text(
                                            medicalList[index].reason,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16,
                                              color: Palette.black,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
