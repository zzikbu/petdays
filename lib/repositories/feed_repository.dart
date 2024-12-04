import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/diary_model.dart';
import 'package:petdays/models/user_model.dart';

class FeedRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const FeedRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  // 성장일기 작성자 차단
  Future<void> blockUser({
    required String currentUserUid, // 현재 접속한 유저
    required String targetUserUid, // 차단할 유저
  }) async {
    try {
      DocumentReference<Map<String, dynamic>> userDocRef =
          firebaseFirestore.collection('users').doc(currentUserUid);

      await firebaseFirestore.runTransaction(
        (transaction) async {
          transaction.update(userDocRef, {
            'blocks': FieldValue.arrayUnion([targetUserUid])
          });
        },
      );
    } on FirebaseException {
      throw CustomException(
        title: '차단하기',
        message: '작성자 차단에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw CustomException(
        title: "차단하기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 성장일기 신고
  Future<DiaryModel> reportDiary({
    required String uid,
    required DiaryModel diaryModel,
    required String countField,
  }) async {
    try {
      if (diaryModel.reports.contains(uid)) {
        throw CustomException(
          title: "신고하기",
          message: "이미 신고한 성장일기입니다.",
        );
      }

      final batch = firebaseFirestore.batch();

      DocumentReference<Map<String, dynamic>> diaryDocRef =
          firebaseFirestore.collection('diaries').doc(diaryModel.diaryId);

      batch.update(diaryDocRef, {
        countField: FieldValue.increment(1),
        'reports': FieldValue.arrayUnion([uid]),
      });

      await batch.commit();

      // 신고된 성장일기 반환
      Map<String, dynamic> diaryMapData =
          await diaryDocRef.get().then((value) => value.data()!);

      DocumentReference<Map<String, dynamic>> writerDocRef =
          diaryMapData['writer'];
      Map<String, dynamic> userMapData =
          await writerDocRef.get().then((value) => value.data()!);
      UserModel userModel = UserModel.fromMap(userMapData);
      diaryMapData['writer'] = userModel;
      return DiaryModel.fromMap(diaryMapData);
    } on CustomException {
      rethrow;
    } on FirebaseException {
      throw CustomException(
        title: '신고하기',
        message: '해당 게시물 신고하기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw CustomException(
        title: "신고하기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 성장일기 좋아요
  Future<DiaryModel> likeDiary({
    required String diaryId,
    required List<String> diaryLikes, // diaryId에 좋아요한 유저들의 목록
    required String uid, // 성장일기 좋아요 누른 유저
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
          DocumentSnapshot<Map<String, dynamic>> userSnapshot =
              await transaction.get(userDocRef);
          List<String> userLikes =
              List<String>.from(userSnapshot.data()?['likes'] ?? []);

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
    } on FirebaseException {
      throw CustomException(
        title: '피드',
        message: '해당 게시물 좋아요에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw CustomException(
        title: "피드",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 피드 가져오기
  Future<List<DiaryModel>> getFeedList({
    required String currentUserUid,
  }) async {
    try {
      // 1. 현재 유저의 차단 목록 가져오기
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await firebaseFirestore.collection('users').doc(currentUserUid).get();

      final blockedUsers =
          List<String>.from(userSnapshot.data()?['blocks'] ?? []);

      // 2. 피드 가져오기
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('diaries')
          .where('isLock', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      // 3. 차단한 사용자의 게시물 필터링하고 변환
      return await Future.wait(
        snapshot.docs.map((e) async {
          Map<String, dynamic> data = e.data();
          DocumentReference<Map<String, dynamic>> writerDocRef = data["writer"];

          // 작성자 정보 가져오기
          DocumentSnapshot<Map<String, dynamic>> writerSnapshot =
              await writerDocRef.get();

          // 차단한 사용자의 글이면 null 반환
          if (blockedUsers.contains(writerSnapshot.id)) {
            return null;
          }

          UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
          data["writer"] = userModel;
          return DiaryModel.fromMap(data);
        }).toList(),
      ).then((list) => list.whereType<DiaryModel>().toList()); // null 값 제거
    } on FirebaseException {
      throw CustomException(
        title: '피드',
        message: '피드 가져오기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw CustomException(
        title: "피드",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }
}
