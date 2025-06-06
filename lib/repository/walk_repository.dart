import 'dart:typed_data';

import '../models/walk_model.dart';

abstract interface class WalkRepository {
  /// 산책 업로드
  Future<WalkModel> uploadWalk({
    required String uid,
    required Uint8List mapImage,
    required String distance,
    required String duration,
    required List<String> petIds,
  });

  /// 산책 기록 가져오기
  Future<List<WalkModel>> getWalkList({
    required String uid,
  });

  /// 산책 삭제
  Future<void> deleteWalk({
    required WalkModel walkModel,
  });
}
