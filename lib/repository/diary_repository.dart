import '../models/diary_model.dart';

abstract interface class DiaryRepository {
  /// 성장일기 업로드
  Future<DiaryModel> uploadDiary({
    required String uid,
    required List<String> files,
    required String title,
    required String desc,
    required bool isLock,
  });

  /// 성장일기 수정
  Future<DiaryModel> updateDiary({
    required String diaryId,
    required String uid,
    required List<String> files,
    required List<String> remainImageUrls,
    required List<String> deleteImageUrls,
    required String title,
    required String desc,
  });

  /// 성장일기 삭제
  Future<void> deleteDiary({
    required DiaryModel diaryModel,
  });

  /// 성장일기 리스트 가져오기
  Future<List<DiaryModel>> getDiaryList({
    required String uid,
  });
}
