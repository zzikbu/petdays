import 'package:petdays/providers/home/home_state.dart';
import 'package:state_notifier/state_notifier.dart';

import '../diary/diary_provider.dart';
import '../diary/diary_state.dart';
import '../medical/medical_provider.dart';
import '../medical/medical_state.dart';
import '../pet/pet_provider.dart';
import '../pet/pet_state.dart';
import '../walk/walk_provider.dart';
import '../walk/walk_state.dart';

class HomeProvider extends StateNotifier<HomeState> with LocatorMixin {
  HomeProvider() : super(HomeState.init());

  @override
  void update(Locator watch) {
    final petState = watch<PetState>();
    final walkState = watch<WalkState>();
    final diaryState = watch<DiaryState>();
    final medicalState = watch<MedicalState>();

    state = state.copyWith(
      homeStatus: _determineHomeStatus(
        petState.petStatus,
        walkState.walkStatus,
        diaryState.diaryStatus,
        medicalState.medicalStatus,
      ),
      homePetList: petState.petList,
      homeWalkList: walkState.walkList,
      homeDiaryList: diaryState.diaryList,
      homeMedicalList: medicalState.medicalList,
    );
  }

  HomeStatus _determineHomeStatus(
    PetStatus petStatus,
    WalkStatus walkStatus,
    DiaryStatus diaryStatus,
    MedicalStatus medicalStatus,
  ) {
    if (petStatus == PetStatus.fetching ||
        walkStatus == WalkStatus.fetching ||
        diaryStatus == DiaryStatus.fetching ||
        medicalStatus == MedicalStatus.fetching) {
      return HomeStatus.fetching;
    }

    if (petStatus == PetStatus.error ||
        walkStatus == WalkStatus.error ||
        diaryStatus == DiaryStatus.error ||
        medicalStatus == MedicalStatus.error) {
      return HomeStatus.error;
    }

    return HomeStatus.success;
  }

  Future<void> getHomeData({
    required String uid,
  }) async {
    await read<PetProvider>().getPetList(uid: uid);
    await read<WalkProvider>().getWalkList(uid: uid);
    await read<DiaryProvider>().getDiaryList(uid: uid);
    await read<MedicalProvider>().getMedicalList(uid: uid);
  }
}
