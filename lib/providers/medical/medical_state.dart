import 'package:pet_log/models/medical_model.dart';

enum MedicalStatus {
  init, // DiaryState를 최초로 객체 생성한 상태
  submitting, // 게시글을 등록하는 중인 상태
  fetching, // 가져오는 중인 상태
  success, // 작업이 성공한 상태
  error, // 작업이 실패한 상태
}

class MedicalState {
  final MedicalStatus medicalStatus;
  final List<MedicalModel> medicalList;

  const MedicalState({
    required this.medicalStatus,
    required this.medicalList,
  });

  factory MedicalState.init() {
    return MedicalState(
      medicalStatus: MedicalStatus.init,
      medicalList: [],
    );
  }

  MedicalState copyWith({
    MedicalStatus? medicalStatus,
    List<MedicalModel>? medicalList,
  }) {
    return MedicalState(
      medicalStatus: medicalStatus ?? this.medicalStatus,
      medicalList: medicalList ?? this.medicalList,
    );
  }
}
