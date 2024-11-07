import 'package:petdays/models/pet_model.dart';

enum PetStatus {
  init, // PetState를 최초로 객체 생성한 상태
  submitting, // 펫을 등록하는 중인 상태
  fetching, // 가져오는 중인 상태
  success, // 작업이 성공한 상태
  error, // 작업이 실패한 상태
}

class PetState {
  final PetStatus petStatus;
  final List<PetModel> petList;

  const PetState({
    required this.petStatus,
    required this.petList,
  });

  factory PetState.init() {
    return PetState(
      petStatus: PetStatus.init,
      petList: [],
    );
  }

  PetState copyWith({
    PetStatus? petStatus,
    List<PetModel>? petList,
  }) {
    return PetState(
      petStatus: petStatus ?? this.petStatus,
      petList: petList ?? this.petList,
    );
  }
}
