enum PetStatus {
  init, // PetState를 최초로 객체 생성한 상태
  submitting, // 펫을 등록하는 중인 상태
  success, // 작업이 성공한 상태
  error, // 작업이 실패한 상태
}

class PetState {
  final PetStatus petStatus;

  const PetState({
    required this.petStatus,
  });

  factory PetState.init() {
    return PetState(petStatus: PetStatus.init);
  }

  PetState copyWith({
    PetStatus? petStatus,
  }) {
    return PetState(
      petStatus: petStatus ?? this.petStatus,
    );
  }
}
