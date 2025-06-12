import 'package:petdays/domain/model/diary_model.dart';
import 'package:petdays/domain/model/medical_model.dart';
import 'package:petdays/domain/model/walk_model.dart';

import '../../domain/model/pet_model.dart';

enum HomeStatus {
  init,
  fetching,
  success,
  error,
}

class HomeState {
  final HomeStatus homeStatus;
  final List<PetModel> homePetList;
  final List<WalkModel> homeWalkList;
  final List<DiaryModel> homeDiaryList;
  final List<MedicalModel> homeMedicalList;

  const HomeState({
    required this.homeStatus,
    required this.homePetList,
    required this.homeWalkList,
    required this.homeDiaryList,
    required this.homeMedicalList,
  });

  factory HomeState.init() {
    return const HomeState(
      homeStatus: HomeStatus.init,
      homePetList: [],
      homeWalkList: [],
      homeDiaryList: [],
      homeMedicalList: [],
    );
  }

  HomeState copyWith({
    HomeStatus? homeStatus,
    List<PetModel>? homePetList,
    List<WalkModel>? homeWalkList,
    List<DiaryModel>? homeDiaryList,
    List<MedicalModel>? homeMedicalList,
  }) {
    return HomeState(
      homeStatus: homeStatus ?? this.homeStatus,
      homePetList: homePetList ?? this.homePetList,
      homeWalkList: homeWalkList ?? this.homeWalkList,
      homeDiaryList: homeDiaryList ?? this.homeDiaryList,
      homeMedicalList: homeMedicalList ?? this.homeMedicalList,
    );
  }
}
