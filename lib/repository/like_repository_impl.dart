import 'package:cloud_firestore/cloud_firestore.dart';

import '../exceptions/custom_exception.dart';
import '../models/diary_model.dart';
import '../models/user_model.dart';
import 'like_repository.dart';

class LikeRepositoryImpl implements LikeRepository {
  final FirebaseFirestore _firebaseFirestore;

  const LikeRepositoryImpl({
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore;

  /// 좋아요한 성장일기 가져오기
  @override
  Future<List<DiaryModel>> getLikeList({
    required String uid,
  }) async {
    try {
      // 1. 현재 유저 데이터 가져오기 (차단 목록과 좋아요 목록)
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await _firebaseFirestore.collection('users').doc(uid).get();
      final userData = userSnapshot.data()!;

      final blockedUsers = List<String>.from(userData['blocks'] ?? []);
      final likes = List<String>.from(userData['likes'] ?? []);

      // 2. 좋아요한 글들 가져오기
      List<DiaryModel> diaryList = await Future.wait(
        likes.map((diaryId) async {
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
              await _firebaseFirestore.collection('diaries').doc(diaryId).get();

          // 삭제된 게시물 처리
          if (!documentSnapshot.exists) return null;

          Map<String, dynamic> diaryMapData = documentSnapshot.data()!;
          DocumentReference<Map<String, dynamic>> writerDocRef = diaryMapData['writer'];

          // 작성자 정보 가져오기
          DocumentSnapshot<Map<String, dynamic>> writerSnapshot = await writerDocRef.get();

          // 차단한 사용자의 글이면 null 반환
          if (blockedUsers.contains(writerSnapshot.id)) {
            return null;
          }

          // 작성자 정보 매핑
          diaryMapData['writer'] = UserModel.fromMap(writerSnapshot.data()!);
          return DiaryModel.fromMap(diaryMapData);
        }).toList(),
      ).then((list) => list.whereType<DiaryModel>().toList()); // null 값 제거

      return diaryList;
    } on FirebaseException {
      throw const CustomException(
        title: '좋아요한 성장일기',
        message: '좋아요한 성장일기 가져오기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "좋아요한 성장일기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }
}
