import '../model/diary_model.dart';

abstract interface class FeedRepository {
  /// 피드 리스트 가져오기
  Future<List<DiaryModel>> getFeedList({
    required String currentUserUid,
  });

  /// 성장일기 좋아요/좋아요 취소
  Future<DiaryModel> likeDiary({
    required String diaryId,
    required List<String> diaryLikes,
    required String uid,
  });

  /// 성장일기 신고
  Future<DiaryModel> reportDiary({
    required String uid,
    required DiaryModel diaryModel,
    required String countField,
  });

  /// 성장일기 작성자 차단
  Future<void> blockUser({
    required String currentUserUid,
    required String targetUserUid,
  });
}
