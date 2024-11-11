import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:petdays/components/custom_dialog.dart';
import 'package:petdays/components/show_error_dialog.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/walk_model.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/pet/pet_state.dart';
import 'package:petdays/providers/user/user_state.dart';
import 'package:petdays/providers/walk/walk_provider.dart';
import 'package:petdays/providers/walk/walk_state.dart';
import 'package:petdays/screens/walk/walk_detail_screen.dart';
import 'package:petdays/screens/select_pet_screen.dart';
import 'package:provider/provider.dart';

class WalkHomeScreen extends StatefulWidget {
  const WalkHomeScreen({super.key});

  @override
  State<WalkHomeScreen> createState() => _WalkHomeScreenState();
}

class _WalkHomeScreenState extends State<WalkHomeScreen> {
  late final WalkProvider _walkProvider;

  @override
  void initState() {
    super.initState();

    _walkProvider = context.read<WalkProvider>();
    _getWalkList();
  }

  void _getWalkList() {
    String uid = context.read<UserState>().userModel.uid;

    // 위젯들이 만들어 진 후에
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _walkProvider.getWalkList(uid: uid);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    WalkState walkState = context.watch<WalkState>();
    List<WalkModel> walkList = walkState.walkList;

    bool isLoading = walkState.walkStatus == WalkStatus.fetching;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          "산책",
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Palette.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
      backgroundColor: Palette.background,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Palette.subGreen))
          : RefreshIndicator(
              // 새로고침
              color: Palette.subGreen,
              backgroundColor: Palette.white,
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 1));
                _getWalkList();
              },
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: walkList.length,
                  itemBuilder: (context, index) {
                    final walkModel = walkList[index];

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
                        margin: EdgeInsets.only(bottom: 20),
                        height: 130,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 14),
                            SizedBox(
                              height: 36,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                scrollDirection: Axis.horizontal, // 수평
                                itemCount: walkModel.pets.length,
                                itemBuilder: (context, index) {
                                  final petModel = walkModel.pets[index];

                                  return Container(
                                    width: 36,
                                    height: 36,
                                    margin: EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: ExtendedNetworkImageProvider(
                                            petModel.image),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "날짜",
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Palette.mediumGray,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        walkModel.createdAt
                                            .toDate()
                                            .toString()
                                            .substring(0, 10),
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Palette.black,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "거리",
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Palette.mediumGray,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${(double.parse(walkModel.distance) / 1000).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16, // 기본 폰트 크기
                                                color: Palette.black,
                                                letterSpacing: -0.4,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'KM',
                                              style: TextStyle(
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12, // 작은 폰트 크기
                                                color: Palette.black,
                                                letterSpacing: -0.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "시간",
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color: Palette.mediumGray,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${(int.parse(walkModel.duration.split(':')[1]) + int.parse(walkModel.duration.split(':')[0]) * 60)}',
                                              style: TextStyle(
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                color: Palette.black,
                                                letterSpacing: -0.4,
                                              ),
                                            ),
                                            TextSpan(
                                              text: '분',
                                              style: TextStyle(
                                                fontFamily: 'Pretendard',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: Palette.black,
                                                letterSpacing: -0.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.read<PetState>().petList.isEmpty) {
            showDialog(
              context: context,
              builder: (context) {
                return CustomDialog(
                  title: '산책',
                  message: '반려동물을 추가해주세요.',
                  hasCancelButton: false,
                  onConfirm: () => Navigator.pop(context),
                );
              },
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectPetScreen(isMedical: false),
              ),
            );
          }
        },
        backgroundColor: Palette.darkGray,
        elevation: 0, // 그림자 제거
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(
          Icons.add,
          color: Palette.white,
        ),
      ),
    );
  }
}
