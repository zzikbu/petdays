import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/components/pd_loading_circular.dart';
import 'package:petdays/components/pd_refresh_indicator.dart';
import 'package:provider/provider.dart';

import '../../components/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../palette.dart';
import '../../providers/home/home_provider.dart';
import '../../providers/home/home_state.dart';
import 'widgets/home_diary_list.dart';
import 'widgets/home_medical_list.dart';
import 'widgets/home_pet_carousel.dart';
import 'widgets/home_walk_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin<HomeScreen> {
  @override
  bool get wantKeepAlive => true;

  void _getData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final String currentUserId = context.read<User>().uid;
        await context.read<HomeProvider>().getHomeData(uid: currentUserId);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
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
          ? const PDLoadingCircular()
          : PDRefreshIndicator(
              onRefresh: () async => _getData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                primary: true,
                child: Column(
                  children: [
                    /// 반려동물
                    HomePetCarousel(petList: homeState.homePetList),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: Column(
                        children: [
                          /// 산책
                          HomeWalkList(walkList: homeState.homeWalkList.take(3).toList()),
                          const SizedBox(height: 28),

                          /// 성장일기
                          HomeDiaryList(diaryList: homeState.homeDiaryList.take(3).toList()),
                          const SizedBox(height: 28),

                          /// 진료기록
                          HomeMedicalList(medicalList: homeState.homeMedicalList.take(7).toList()),
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
