import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/pd_app_bar.dart';
import '../../common/widgets/show_custom_dialog.dart';
import '../../common/widgets/show_error_dialog.dart';
import '../../common/widgets/pd_circle_avatar.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/pet_model.dart';
import '../../palette.dart';
import '../../providers/pet/pet_provider.dart';
import '../../providers/pet/pet_state.dart';
import 'pet_upload_screen.dart';

class PetDetailScreen extends StatefulWidget {
  final int index;

  const PetDetailScreen({
    super.key,
    required this.index,
  });

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  /// Method
  String _getAge({
    required String birthDateString,
  }) {
    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime currentDate = DateTime.now();
    Duration ageDifference = currentDate.difference(birthDate);
    int ageInYears = ageDifference.inDays ~/ 365;
    return '$ageInYears살';
  }

  // 만난 날 계산
  String _getDaysSinceMeeting({
    required String meetingDateString,
  }) {
    DateTime meetingDate = DateTime.parse(meetingDateString);
    DateTime currentDate = DateTime.now();
    Duration difference = currentDate.difference(meetingDate);
    return '만난 지 ${difference.inDays}일째';
  }

  /// LifeCycle
  @override
  Widget build(BuildContext context) {
    PetModel petModel = context.watch<PetState>().petList[widget.index];

    return Scaffold(
      appBar: PDAppBar(
        actions: [
          IconButton(
            onPressed: () {
              showCustomDialog(
                context: context,
                title: '반려동물 삭제',
                message: '반려동물을 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
                onConfirm: () async {
                  try {
                    await context.read<PetProvider>().deletePet(petId: petModel.petId);
                    context.go('/home');
                  } on CustomException catch (e) {
                    showErrorDialog(context, e);
                  }
                },
              );
            },
            icon: const Icon(CupertinoIcons.delete),
          ),
        ],
      ),
      backgroundColor: Palette.background,
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 24, right: 24),
        child: Column(
          children: [
            Container(
              height: 342,
              decoration: BoxDecoration(
                color: Palette.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PDCircleAvatar(
                          imageUrl: petModel.image,
                          size: 100,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                petModel.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  color: Palette.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                petModel.breed,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Palette.mediumGray,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.go(
                            '/home/pet_detail/${widget.index}/edit',
                            extra: petModel,
                          ),
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 86,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Palette.black,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '생년월일',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Palette.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        petModel.birthDay,
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Palette.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 86,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Palette.black,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '나이',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Palette.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getAge(birthDateString: petModel.birthDay),
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Palette.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 86,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Palette.black,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '성별',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Palette.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        petModel.gender == "male" ? "수컷" : "암컷",
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Palette.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 86,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Palette.black,
                                    width: 2,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '중성화',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          color: Palette.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        petModel.isNeutering == true ? "O" : "X",
                                        style: const TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Palette.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 60,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Palette.mainGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _getDaysSinceMeeting(meetingDateString: petModel.firstMeetingDate),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: Palette.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
