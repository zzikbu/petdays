import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/models/user_model.dart';
import 'package:pet_log/screens/diary/diary_detail_screen.dart';

class FeedRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const FeedRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  // 성장일기 신고
  Future<void> reportDiary({
    required String uid,
    required String diaryId,
    required String countField,
  }) async {
    final batch = firebaseFirestore.batch();

    DocumentReference<Map<String, dynamic>> diaryDocRef =
        firebaseFirestore.collection('diaries').doc(diaryId);

    batch.update(diaryDocRef, {
      countField: FieldValue.increment(1),
      'reports': FieldValue.arrayUnion([uid]),
    });

    await batch.commit();
  }

  // 성장일기 좋아요
  Future<DiaryModel> likeDiary({
    required String diaryId,
    required List<String> diaryLikes, // diaryId에 좋아요한 유저들의 목록
    required String uid, // 성장일기 좋아요 누른 유저
    required List<String> userLikes, // 성장일기 좋아요 누른 유저의 좋아요한 성장일기 목록
  }) async {
    try {
      DocumentReference<Map<String, dynamic>> userDocRef =
          firebaseFirestore.collection('users').doc(uid);
      DocumentReference<Map<String, dynamic>> diaryDocRef =
          firebaseFirestore.collection('diaries').doc(diaryId);

      // diaryId에 좋아요한 유저들의 목록에 uid가 포함되어 있는지
      // 포함되어 있다면 좋아요 취소
      // 성장일기의 likes 필드에서 uid 삭제
      // 성장일기의 likeCount -1

      // 성장일기 좋아요 누른 유저의 좋아요한 성장일기 목록에 feedId가 포함되어 있는지
      // 포함되어 있다면 좋아요 취소
      // 유저의 likes 필드에서 feedId 삭제
      // 성장일기의 likeCount -1

      // 트랜잭션
      // batch 처럼 commit을 사용할 필요가 없음
      await firebaseFirestore.runTransaction(
        (transaction) async {
          bool isDiaryContains = diaryLikes.contains(uid);

          transaction.update(diaryDocRef, {
            'likes': isDiaryContains
                ? FieldValue.arrayRemove([uid])
                : FieldValue.arrayUnion([uid]),
            'likeCount': isDiaryContains
                ? FieldValue.increment(-1)
                : FieldValue.increment(1),
          });

          transaction.update(userDocRef, {
            'likes': userLikes.contains(diaryId)
                ? FieldValue.arrayRemove([diaryId])
                : FieldValue.arrayUnion([diaryId]),
          });
        },
      );

      Map<String, dynamic> diaryMapData =
          await diaryDocRef.get().then((value) => value.data()!);

      DocumentReference<Map<String, dynamic>> writerDocRef =
          diaryMapData['writer'];
      Map<String, dynamic> userMapData =
          await writerDocRef.get().then((value) => value.data()!);
      UserModel userModel = UserModel.fromMap(userMapData);
      diaryMapData['writer'] = userModel;
      return DiaryModel.fromMap(diaryMapData);
    } on FirebaseException catch (e) {
      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }

  // 피드 가져오기
  Future<List<DiaryModel>> getFeedList() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('diaries')
          .where('isLock', isEqualTo: false)
          .orderBy('createAt', descending: true) // 최신순 정렬
          .get();

      return await Future.wait(snapshot.docs.map(
        (e) async {
          Map<String, dynamic> data = e.data();
          DocumentReference<Map<String, dynamic>> writerDocRef = data["writer"];
          DocumentSnapshot<Map<String, dynamic>> writerSnapshot =
              await writerDocRef.get();
          UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
          data["writer"] = userModel;
          return DiaryModel.fromMap(data);
        },
      ).toList());
    } on FirebaseException catch (e) {
      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }
}
