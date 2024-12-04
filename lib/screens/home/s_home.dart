import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:petdays/providers/home/home_provider.dart';
import 'package:petdays/screens/home/w_home_diary_list.dart';
import 'package:petdays/screens/home/w_home_medical_list.dart';
import 'package:petdays/screens/home/w_home_pet_carousel.dart';
import 'package:petdays/screens/home/w_home_walk_list.dart';
import 'package:provider/provider.dart';

import '../../components/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../palette.dart';
import '../../providers/home/home_state.dart';

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
        await context.read<HomeProvider>().getHomeData(uid: _currentUserId);
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

    HomeState homeState = context.watch<HomeState>();
    bool isLoading = homeState.homeStatus == HomeStatus.fetching;

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
                    HomePetCarouselWidget(petList: homeState.homePetList),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 40),
                      child: Column(
                        children: [
                          /// 산책
                          HomeWalkListWidget(walkList: homeState.homeWalkList),
                          SizedBox(height: 28),

                          /// 성장일기
                          HomeDiaryListWidget(
                              diaryList: homeState.homeDiaryList),
                          SizedBox(height: 28),

                          /// 진료기록
                          HomeMedicalListWidget(
                              medicalList: homeState.homeMedicalList),
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
