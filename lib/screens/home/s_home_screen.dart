import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/screens/home/w_home_diary_list.dart';
import 'package:petdays/screens/home/w_home_medical_list.dart';
import 'package:petdays/screens/home/w_home_pet_carousel.dart';
import 'package:petdays/screens/home/w_home_walk_list.dart';
import 'package:provider/provider.dart';

import '../../components/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/diary_model.dart';
import '../../models/medical_model.dart';
import '../../models/pet_model.dart';
import '../../models/walk_model.dart';
import '../../palette.dart';
import '../../providers/diary/diary_provider.dart';
import '../../providers/diary/diary_state.dart';
import '../../providers/medical/medical_provider.dart';
import '../../providers/medical/medical_state.dart';
import '../../providers/pet/pet_provider.dart';
import '../../providers/pet/pet_state.dart';
import '../../providers/walk/walk_provider.dart';
import '../../providers/walk/walk_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  late final String _currentUserId;

  void _getData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await context.read<PetProvider>().getPetList(uid: _currentUserId);
        await context.read<WalkProvider>().getWalkList(uid: _currentUserId);
        await context.read<DiaryProvider>().getDiaryList(uid: _currentUserId);
        await context
            .read<MedicalProvider>()
            .getMedicalList(uid: _currentUserId);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<User>().uid;
    _getData();
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

    bool isLoading = petState.petStatus == PetStatus.fetching ||
        walkState.walkStatus == WalkStatus.fetching ||
        diaryState.diaryStatus == DiaryStatus.fetching ||
        medicalState.medicalStatus == MedicalStatus.fetching;

    return Scaffold(
      backgroundColor: Palette.background,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Palette.subGreen))
          : RefreshIndicator(
              color: Palette.subGreen,
              backgroundColor: Palette.white,
              onRefresh: () async => _getData(),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                primary: true,
                child: Column(
                  children: [
                    /// 반려동물
                    HomePetCarouselWidget(petList: petList),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 40),
                      child: Column(
                        children: [
                          /// 산책
                          HomeWalkListWidget(walkList: walkList),
                          SizedBox(height: 28),

                          /// 성장일기
                          HomeDiaryListWidget(diaryList: diaryList),
                          SizedBox(height: 28),

                          /// 진료기록
                          HomeMedicalListWidget(medicalList: medicalList),
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
