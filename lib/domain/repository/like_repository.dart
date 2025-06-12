import '../model/diary_model.dart';

abstract interface class LikeRepository {
  /// 좋아요한 성장일기 리스트 가져오기
  Future<List<DiaryModel>> getLikeList({
    required String uid,
  });
}
