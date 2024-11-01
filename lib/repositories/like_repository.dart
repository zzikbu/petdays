import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/models/user_model.dart';

class LikeRepository {
  final FirebaseFirestore firebaseFirestore;

  const LikeRepository({
    required this.firebaseFirestore,
  });

  Future<List<DiaryModel>> getLikeList({
    required String uid,
  }) async {
    try {
      // 1. 현재 유저 데이터 가져오기 (차단 목록과 좋아요 목록)
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await firebaseFirestore.collection('users').doc(uid).get();
      final userData = userSnapshot.data()!;

      final blockedUsers = List<String>.from(userData['blocks'] ?? []);
      final likes = List<String>.from(userData['likes'] ?? []);

      // 2. 좋아요한 글들 가져오기
      List<DiaryModel> diaryList = await Future.wait(
        likes.map((diaryId) async {
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
              await firebaseFirestore.collection('diaries').doc(diaryId).get();

          // 삭제된 게시물 처리
          if (!documentSnapshot.exists) return null;

          Map<String, dynamic> diaryMapData = documentSnapshot.data()!;
          DocumentReference<Map<String, dynamic>> writerDocRef =
              diaryMapData['writer'];

          // 작성자 정보 가져오기
          DocumentSnapshot<Map<String, dynamic>> writerSnapshot =
              await writerDocRef.get();

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
    } on FirebaseException catch (e) {
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }
}
