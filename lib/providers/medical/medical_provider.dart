import 'package:firebase_auth/firebase_auth.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/medical_model.dart';
import 'package:petdays/providers/medical/medical_state.dart';
import 'package:petdays/repository/medical_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class MedicalProvider extends StateNotifier<MedicalState> with LocatorMixin {
  // MedicalProvider 만들어질 때 DiaryState도 같이 만들기
  MedicalProvider() : super(MedicalState.init());

  // 진료기록 수정
  Future<void> updateMedical({
    required String medicalId,
    required String uid,
    required String petId,
    required List<String> files,
    required List<String> remainImageUrls,
    required List<String> deleteImageUrls,
    required String visitedDate,
    required String reason,
    required String hospital,
    required String doctor,
    required String note,
  }) async {
    try {
      state = state.copyWith(
        medicalStatus: MedicalStatus.submitting,
      );

      // 수정된 진료기록 가져오기
      MedicalModel updatedMedical =
          await read<MedicalRepository>().updateMedical(
        medicalId: medicalId,
        uid: uid,
        petId: petId,
        files: files,
        remainImageUrls: remainImageUrls,
        deleteImageUrls: deleteImageUrls,
        visitedDate: visitedDate,
        reason: reason,
        hospital: hospital,
        doctor: doctor,
        note: note,
      );

      // 기존 리스트에서 수정된 진료기록만 교체
      List<MedicalModel> updatedList = state.medicalList.map((medical) {
        if (medical.medicalId == medicalId) {
          return updatedMedical;
        }
        return medical;
      }).toList()
        ..sort((a, b) =>
            b.visitedDate.compareTo(a.visitedDate)); // visitDate 기준으로 내림차순 정렬

      state = state.copyWith(
        medicalStatus: MedicalStatus.success,
        medicalList: updatedList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(
        medicalStatus: MedicalStatus.error,
      );
      rethrow;
    }
  }

  // 진료기록 삭제
  Future<void> deleteMedical({
    required MedicalModel medicalModel,
  }) async {
    state = state.copyWith(medicalStatus: MedicalStatus.submitting);

    try {
      await read<MedicalRepository>().deleteDiary(medicalModel: medicalModel);

      List<MedicalModel> newMedicalList = state.medicalList
          .where((element) => element.medicalId != medicalModel.medicalId)
          .toList(); // 삭제하지 않은 모델만 뽑아 새로운 리스트 생성

      state = state.copyWith(
        medicalStatus: MedicalStatus.success,
        medicalList: newMedicalList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(
          medicalStatus: MedicalStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

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
    required String visitedDate,
    required String reason,
    required String hospital,
    required String doctor,
    required String petId,
    required String note,
  }) async {
    try {
      state = state.copyWith(
          medicalStatus: MedicalStatus.submitting); // 게시글을 등록하는 중인 상태로 변경

      String uid = read<User>().uid; // 작성자

      // 새로 등록한 진료기록을 리스트 맨앞에 추가 해주기 위해 변수에 저장
      MedicalModel medicalModel = await read<MedicalRepository>().uploadMedical(
        uid: uid,
        files: files,
        visitedDate: visitedDate,
        reason: reason,
        hospital: hospital,
        doctor: doctor,
        petId: petId,
        note: note,
      );

      state = state.copyWith(
        medicalStatus: MedicalStatus.success, // 등록 완료 상태로 변경
        medicalList: [
          medicalModel,
          ...state.medicalList, // 새로 등록한 진료기록을 리스트 맨앞에 추가
        ]..sort((a, b) =>
            b.visitedDate.compareTo(a.visitedDate)), // visitDate 기준으로 내림차순 정렬
      );
    } on CustomException catch (_) {
      state = state.copyWith(
          medicalStatus: MedicalStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
