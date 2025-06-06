import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../exceptions/custom_exception.dart';
import '../models/diary_model.dart';
import '../models/user_model.dart';
import 'feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FirebaseFirestore _firebaseFirestore;

  const FeedRepositoryImpl({
    required FirebaseFirestore firebaseFirestore,
  }) : _firebaseFirestore = firebaseFirestore;

  @override
  Future<List<DiaryModel>> getFeedList({
    required String currentUserUid,
  }) async {
    try {
      // 1. 현재 유저의 차단 목록 가져오기
      final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await _firebaseFirestore.collection('users').doc(currentUserUid).get();

      final List<String> blockedUsers = List<String>.from(userSnapshot.data()?['blocks'] ?? []);

      // 2. 공개된 피드 가져오기
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection('diaries')
          .where('isLock', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();

      // 3. 차단한 사용자의 게시물 필터링하고 변환
      final List<DiaryModel?> diaryModels = await Future.wait(
        snapshot.docs.map((doc) => _processDiaryDocument(doc, blockedUsers)),
      );

      // null 값 제거하고 반환
      return diaryModels.whereType<DiaryModel>().toList();
    } on FirebaseException {
      throw const CustomException(
        title: '피드',
        message: '피드 가져오기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "피드",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<DiaryModel> likeDiary({
    required String diaryId,
    required List<String> diaryLikes,
    required String uid,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> userDocRef =
          _firebaseFirestore.collection('users').doc(uid);
      final DocumentReference<Map<String, dynamic>> diaryDocRef =
          _firebaseFirestore.collection('diaries').doc(diaryId);

      // 트랜잭션으로 좋아요 상태 업데이트
      await _firebaseFirestore.runTransaction((transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await transaction.get(userDocRef);

        final List<String> userLikes = List<String>.from(userSnapshot.data()?['likes'] ?? []);
        final bool isDiaryContains = diaryLikes.contains(uid);

        // 성장일기의 좋아요 정보 업데이트
        transaction.update(diaryDocRef, {
          'likes': isDiaryContains ? FieldValue.arrayRemove([uid]) : FieldValue.arrayUnion([uid]),
          'likeCount': isDiaryContains ? FieldValue.increment(-1) : FieldValue.increment(1),
        });

        // 사용자의 좋아요 목록 업데이트
        transaction.update(userDocRef, {
          'likes': userLikes.contains(diaryId)
              ? FieldValue.arrayRemove([diaryId])
              : FieldValue.arrayUnion([diaryId]),
        });
      });

      // 업데이트된 성장일기 정보 반환
      return await _getDiaryWithWriter(diaryDocRef);
    } on FirebaseException {
      throw const CustomException(
        title: '피드',
        message: '해당 게시물 좋아요에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "피드",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<DiaryModel> reportDiary({
    required String uid,
    required DiaryModel diaryModel,
    required String countField,
  }) async {
    try {
      // 이미 신고한 경우 체크
      if (diaryModel.reports.contains(uid)) {
        throw const CustomException(
          title: "신고하기",
          message: "이미 신고한 성장일기입니다.",
        );
      }

      final WriteBatch batch = _firebaseFirestore.batch();
      final DocumentReference<Map<String, dynamic>> diaryDocRef =
          _firebaseFirestore.collection('diaries').doc(diaryModel.diaryId);

      // 신고 정보 업데이트
      batch.update(diaryDocRef, {
        countField: FieldValue.increment(1),
        'reports': FieldValue.arrayUnion([uid]),
      });

      await batch.commit();

      // 업데이트된 성장일기 정보 반환
      return await _getDiaryWithWriter(diaryDocRef);
    } on CustomException {
      rethrow;
    } on FirebaseException {
      throw const CustomException(
        title: '신고하기',
        message: '해당 게시물 신고하기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "신고하기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> blockUser({
    required String currentUserUid,
    required String targetUserUid,
  }) async {
    try {
      final DocumentReference<Map<String, dynamic>> userDocRef =
          _firebaseFirestore.collection('users').doc(currentUserUid);

      await _firebaseFirestore.runTransaction((transaction) async {
        transaction.update(userDocRef, {
          'blocks': FieldValue.arrayUnion([targetUserUid])
        });
      });
    } on FirebaseException {
      throw const CustomException(
        title: '차단하기',
        message: '작성자 차단에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "차단하기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // Private helper methods

  /// 다이어리 문서를 처리하고 차단된 사용자의 글인 경우 null 반환
  Future<DiaryModel?> _processDiaryDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    List<String> blockedUsers,
  ) async {
    try {
      final Map<String, dynamic> data = doc.data();
      final DocumentReference<Map<String, dynamic>> writerDocRef = data["writer"];

      // 작성자 정보 가져오기
      final DocumentSnapshot<Map<String, dynamic>> writerSnapshot = await writerDocRef.get();

      // 차단한 사용자의 글이면 null 반환
      if (blockedUsers.contains(writerSnapshot.id)) {
        return null;
      }

      final UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
      data["writer"] = userModel;
      return DiaryModel.fromMap(data);
    } catch (_) {
      // 문서 처리 중 오류가 발생하면 null 반환 (전체 로직에는 영향 없음)
      return null;
    }
  }

  /// 다이어리 문서 참조로부터 작성자 정보를 포함한 DiaryModel 반환
  Future<DiaryModel> _getDiaryWithWriter(
    DocumentReference<Map<String, dynamic>> diaryDocRef,
  ) async {
    final DocumentSnapshot<Map<String, dynamic>> diarySnapshot = await diaryDocRef.get();

    if (!diarySnapshot.exists) {
      throw const CustomException(
        title: "오류",
        message: "성장일기를 찾을 수 없습니다.",
      );
    }

    final Map<String, dynamic> diaryData = diarySnapshot.data()!;
    final DocumentReference<Map<String, dynamic>> writerDocRef = diaryData['writer'];

    final DocumentSnapshot<Map<String, dynamic>> writerSnapshot = await writerDocRef.get();

    final UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
    diaryData['writer'] = userModel;

    return DiaryModel.fromMap(diaryData);
  }
}
