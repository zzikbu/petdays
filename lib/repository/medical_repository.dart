import '../models/medical_model.dart';

abstract interface class MedicalRepository {
  // 진료기록 수정
  Future<MedicalModel> updateMedical({
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
  });

  // 진료기록 삭제
  Future<void> deleteDiary({
    required MedicalModel medicalModel,
  });

  // 진료기록 가져오기
  Future<List<MedicalModel>> getMedicalList({
    required String uid,
  });

  // 진료기록 업로드
  Future<MedicalModel> uploadMedical({
    required String uid,
    required String petId,
    required List<String> files,
    required String visitedDate,
    required String reason,
    required String hospital,
    required String doctor,
    required String note,
  });
}
