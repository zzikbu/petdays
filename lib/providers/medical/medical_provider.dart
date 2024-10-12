import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/medical_model.dart';
import 'package:pet_log/providers/medical/medical_state.dart';
import 'package:pet_log/repositories/medical_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class MedicalProvider extends StateNotifier<MedicalState> with LocatorMixin {
  // MedicalProvider 만들어질 때 DiaryState도 같이 만들기
  MedicalProvider() : super(MedicalState.init());

  // 진료기록 가져오기
  Future<void> getMedicalList({
    required String uid,
  }) async {
    try {
      state = state.copyWith(medicalStatus: MedicalStatus.fetching); // 상태 변경

      List<MedicalModel> medicalList =
          await read<MedicalRepository>().getMedicalList(uid: uid);

      state = state.copyWith(
        medicalList: medicalList,
        medicalStatus: MedicalStatus.success, // 상태 변경
      );
    } on CustomException catch (_) {
      state = state.copyWith(
          medicalStatus: MedicalStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 진료기록 업로드
  Future<void> uploadMedical({
    required List<String> files, // 이미지들
    required String visitDate,
    required String reason,
    required String hospital,
    required String doctor,
    required String note,
    required String petId,
  }) async {
    try {
      state = state.copyWith(
          medicalStatus: MedicalStatus.submitting); // 게시글을 등록하는 중인 상태로 변경

      String uid = read<User>().uid; // 작성자

      await read<MedicalRepository>().uploadMedical(
        uid: uid,
        files: files,
        visitDate: visitDate,
        reason: reason,
        hospital: hospital,
        doctor: doctor,
        note: note,
        petId: petId,
      );

      state =
          state.copyWith(medicalStatus: MedicalStatus.success); // 등록 완료 상태로 변경
    } on CustomException catch (_) {
      state = state.copyWith(
          medicalStatus: MedicalStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
