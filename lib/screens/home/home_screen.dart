import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:petdays/components/error_dialog_widget.dart';
import 'package:petdays/components/home_section_header.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/diary_model.dart';
import 'package:petdays/models/medical_model.dart';
import 'package:petdays/models/pet_model.dart';
import 'package:petdays/models/walk_model.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/diary/diary_provider.dart';
import 'package:petdays/providers/diary/diary_state.dart';
import 'package:petdays/providers/medical/medical_provider.dart';
import 'package:petdays/providers/medical/medical_state.dart';
import 'package:petdays/providers/pet/pet_provider.dart';
import 'package:petdays/providers/pet/pet_state.dart';
import 'package:petdays/providers/walk/walk_provider.dart';
import 'package:petdays/providers/walk/walk_state.dart';
import 'package:petdays/screens/diary/diary_detail_screen.dart';
import 'package:petdays/screens/diary/diary_home_screen.dart';
import 'package:petdays/screens/medical/medical_detail_screen.dart';
import 'package:petdays/screens/medical/medical_home_screen.dart';
import 'package:petdays/screens/pet/pet_detail_screen.dart';
import 'package:petdays/screens/pet/pet_upload_screen.dart';
import 'package:petdays/screens/walk/walk_detail_screen.dart';
import 'package:petdays/screens/walk/walk_home_screen.dart';
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
  late final WalkProvider walkProvider;
  late final DiaryProvider diaryProvider;
  late final MedicalProvider medicalProvider;

  int _indicatorIndex = 0;

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  // 다른 화면에서 돌아올 때
  // 데이터를 매번 가져오지 않도록
  @override
  bool get wantKeepAlive => true;

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

  // 데이터 가져오기
  void _getData() {
    String uid = context.read<User>().uid;

    // 위젯들이 만들어 진 후에
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await petProvider.getPetList(uid: uid); // 펫 가져오기
        await walkProvider.getWalkList(uid: uid); // 삭제 가져오기
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
    walkProvider = context.read<WalkProvider>();
    diaryProvider = context.read<DiaryProvider>();
    medicalProvider = context.read<MedicalProvider>();

    _getData(); // 데이터 가져오기
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 펫 리스트의 길이가 인디케이터 인덱스보다 작으면 인디케이터 리셋
    final petList = context.watch<PetState>().petList;
    if (petList.length <= _indicatorIndex) {
      setState(() {
        _indicatorIndex = petList.isEmpty ? 0 : petList.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    PetState petState = context.watch<PetState>();
    List<PetModel> petList = petState.petList;

    WalkState walkState = context.watch<WalkState>();
    List<WalkModel> walkList = walkState.walkList;

    DiaryState diaryState = context.watch<DiaryState>();
    List<DiaryModel> diaryList = diaryState.diaryList;

    MedicalState medicalState = context.watch<MedicalState>();
    List<MedicalModel> medicalList = medicalState.medicalList;

    // if (petState.petStatus == PetStatus.fetching ||
    //     diaryState.diaryStatus == DiaryStatus.fetching ||
    //     medicalState.medicalStatus == MedicalStatus.fetching) {
    //   return Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    return Scaffold(
      backgroundColor: Palette.background,
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 최상단 초록색 영역
              Container(
                height: 260,
                color: Palette.mainGreen,
                child: petList.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 68, bottom: 42),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PetUploadScreen()),
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
                            items: petList.map(
                              (pet) {
                                return Builder(
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  PetDetailScreen(
                                                      index: _indicatorIndex)),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 24),
                                        decoration: BoxDecoration(
                                          color: Palette.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                                            pet.image),
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
                                                  // 이름 & 만난 날 계산
                                                  Text(
                                                    _getNameAndDaysSinceMeeting(
                                                      name: pet.name,
                                                      meetingDateString:
                                                          pet.firstMeetingDate,
                                                    ),
                                                    style: TextStyle(
                                                      fontFamily: 'Pretendard',
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                      birthDateString:
                                                          pet.birthDay,
                                                      breed: pet.breed,
                                                    ),
                                                    style: TextStyle(
                                                      fontFamily: 'Pretendard',
                                                      fontWeight:
                                                          FontWeight.w600,
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
                    walkList.isEmpty
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
                              walkList.length > 3
                                  ? 3
                                  : walkList.length, // 최대 3개
                              (index) {
                                final walkModel = walkList[index];
                                final walkDate =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        walkModel
                                            .createAt.millisecondsSinceEpoch);
                                final formattedDate =
                                    DateFormat('yyyy.MM.dd EEE', 'ko_KR')
                                        .format(walkDate);

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            WalkDetailScreen(index: index),
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
                                          color:
                                              Palette.black.withOpacity(0.05),
                                          offset: Offset(8, 8),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // 날짜
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15,
                                              color: Palette.black,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          SizedBox(width: 10),

                                          // 사진
                                          Expanded(
                                            child: SizedBox(
                                              height: 36,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  children: List.generate(
                                                    walkModel.pets.length,
                                                    (index) {
                                                      final petModel =
                                                          walkModel.pets[index];
                                                      return Container(
                                                        width: 36,
                                                        height: 36,
                                                        margin: EdgeInsets.only(
                                                            right: 4),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                              color:
                                                                  Colors.grey,
                                                              width: 0.4,
                                                            ),
                                                            image:
                                                                DecorationImage(
                                                              image:
                                                                  ExtendedNetworkImageProvider(
                                                                      petModel
                                                                          .image),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
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
                                          index: index,
                                          isDiary: true,
                                        ),
                                      ),
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
                                          color:
                                              Palette.black.withOpacity(0.05),
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
                                              diaryList[index]
                                                  .createAt
                                                  .toDate(),
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
                                                  index: index,
                                                )),
                                      );
                                    },

                                    // 흰색 카드 영역
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          right: 12, bottom: 10),
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

                                                // 이름
                                                Expanded(
                                                  child: Text(
                                                    medicalList[index].pet.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontFamily: 'Pretendard',
                                                      fontWeight:
                                                          FontWeight.w500,
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
      ),
    );
  }
}
