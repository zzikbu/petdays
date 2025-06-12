import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../exceptions/custom_exception.dart';
import '../../domain/repository/diary_repository.dart';
import '../../domain/model/diary_model.dart';
import '../../domain/model/user_model.dart';

class DiaryRepositoryImpl implements DiaryRepository {
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;

  const DiaryRepositoryImpl({
    required FirebaseStorage firebaseStorage,
    required FirebaseFirestore firebaseFirestore,
  })  : _firebaseStorage = firebaseStorage,
        _firebaseFirestore = firebaseFirestore;

  @override
  Future<DiaryModel> uploadDiary({
    required String uid,
    required List<String> files,
    required String title,
    required String desc,
    required bool isLock,
  }) async {
    List<String> imageUrls = [];

    try {
      WriteBatch batch = _firebaseFirestore.batch();
      String diaryId = const Uuid().v1();

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> diaryDocRef =
          _firebaseFirestore.collection("diaries").doc(diaryId);
      DocumentReference<Map<String, dynamic>> userDocRef =
          _firebaseFirestore.collection("users").doc(uid);

      // firestorage 참조
      Reference ref = _firebaseStorage.ref().child("diaries").child(diaryId);

      // 이미지들 업로드
      imageUrls = await Future.wait(files.map((e) async {
        String imageId = const Uuid().v1();
        TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e));
        return await taskSnapshot.ref.getDownloadURL();
      }).toList());

      // 유저 모델 생성
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDocRef.get();
      UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

      // 다이어리 모델 생성
      DiaryModel diaryModel = DiaryModel.fromMap({
        "uid": uid,
        "diaryId": diaryId,
        "title": title,
        "desc": desc,
        "imageUrls": imageUrls,
        "likes": [],
        "likeCount": 0,
        "reports": [],
        "adReportCount": 0,
        "abuseReportCount": 0,
        "adultReportCount": 0,
        "otherReportCount": 0,
        "isLock": isLock,
        "createdAt": Timestamp.now(),
        "writer": userModel,
      });

      batch.set(diaryDocRef, diaryModel.toMap(userDocRef: userDocRef));
      batch.update(userDocRef, {
        "diaryCount": FieldValue.increment(1),
      });

      await batch.commit();
      return diaryModel;
    } on FirebaseException {
      await _deleteImages(imageUrls);
      throw const CustomException(
        title: '성장일기',
        message: '성장일기 업로드에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      await _deleteImages(imageUrls);
      throw const CustomException(
        title: "성장일기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<DiaryModel> updateDiary({
    required String diaryId,
    required String uid,
    required List<String> files,
    required List<String> remainImageUrls,
    required List<String> deleteImageUrls,
    required String title,
    required String desc,
  }) async {
    List<String> newImageUrls = [];

    try {
      // 1. 삭제할 이미지들 storage에서 제거
      for (String imageUrl in deleteImageUrls) {
        await _firebaseStorage.refFromURL(imageUrl).delete();
      }

      // 2. 새로운 이미지들 storage에 업로드
      if (files.isNotEmpty) {
        Reference ref = _firebaseStorage.ref().child("diaries").child(diaryId);

        newImageUrls = await Future.wait(files.map((e) async {
          String imageId = const Uuid().v1();
          TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e));
          return await taskSnapshot.ref.getDownloadURL();
        }).toList());
      }

      // 3. 모든 이미지 URL 합치기
      List<String> allImageUrls = [...remainImageUrls, ...newImageUrls];

      // 4. 트랜잭션으로 데이터 업데이트
      return await _firebaseFirestore.runTransaction<DiaryModel>((transaction) async {
        DocumentReference<Map<String, dynamic>> diaryDocRef =
            _firebaseFirestore.collection("diaries").doc(diaryId);
        DocumentReference<Map<String, dynamic>> userDocRef =
            _firebaseFirestore.collection("users").doc(uid);

        DocumentSnapshot<Map<String, dynamic>> diarySnapshot = await transaction.get(diaryDocRef);
        DocumentSnapshot<Map<String, dynamic>> userSnapshot = await transaction.get(userDocRef);

        if (!diarySnapshot.exists) {
          throw const CustomException(
            title: "not-found",
            message: "Diary does not exist",
          );
        }

        Map<String, dynamic> currentData = diarySnapshot.data()!;
        UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

        DiaryModel diaryModel = DiaryModel.fromMap({
          "uid": uid,
          "diaryId": diaryId,
          "title": title,
          "desc": desc,
          "imageUrls": allImageUrls,
          "likes": currentData['likes'],
          "likeCount": currentData['likeCount'],
          "adReportCount": currentData['adReportCount'],
          "abuseReportCount": currentData['abuseReportCount'],
          "adultReportCount": currentData['adultReportCount'],
          "otherReportCount": currentData['otherReportCount'],
          "reports": currentData['reports'],
          "isLock": currentData['isLock'],
          "createdAt": currentData['createdAt'],
          "writer": userModel,
        });

        transaction.update(
          diaryDocRef,
          diaryModel.toMap(userDocRef: userDocRef),
        );

        return diaryModel;
      });
    } on FirebaseException {
      await _deleteImages(newImageUrls);
      throw const CustomException(
        title: '성장일기',
        message: '성장일기 수정에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      await _deleteImages(newImageUrls);
      throw const CustomException(
        title: "성장일기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> deleteDiary({
    required DiaryModel diaryModel,
  }) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();

      DocumentReference<Map<String, dynamic>> diaryDocRef =
          _firebaseFirestore.collection('diaries').doc(diaryModel.diaryId);
      DocumentReference<Map<String, dynamic>> writerDocRef =
          _firebaseFirestore.collection('users').doc(diaryModel.uid);

      List<String> likes =
          await diaryDocRef.get().then((value) => List<String>.from(value.data()!['likes']));

      // 해당 성장일기에 좋아요를 누른 users 문서의 likes 필드에서 diaryId 삭제
      for (var uid in likes) {
        batch.update(_firebaseFirestore.collection('users').doc(uid), {
          'likes': FieldValue.arrayRemove([diaryModel.diaryId]),
        });
      }

      // diaries 컬렉션에서 문서 삭제
      batch.delete(diaryDocRef);

      // 성장일기 작성자의 users 문서에서 diaryCount 1 감소
      batch.update(writerDocRef, {
        'diaryCount': FieldValue.increment(-1),
      });

      await batch.commit();

      // storage 이미지 삭제
      await _deleteImages(diaryModel.imageUrls);
    } on FirebaseException {
      throw const CustomException(
        title: '성장일기',
        message: '성장일기 삭제에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "성장일기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<List<DiaryModel>> getDiaryList({
    required String uid,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection('diaries')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return await Future.wait(snapshot.docs.map(
        (e) async {
          Map<String, dynamic> data = e.data();
          DocumentReference<Map<String, dynamic>> writerDocRef = data["writer"];
          DocumentSnapshot<Map<String, dynamic>> writerSnapshot = await writerDocRef.get();
          UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
          data["writer"] = userModel;
          return DiaryModel.fromMap(data);
        },
      ).toList());
    } on FirebaseException {
      throw const CustomException(
        title: '성장일기',
        message: '성장일기 가져오기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "성장일기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  /// 이미지 삭제 함수
  Future<void> _deleteImages(List<String> imageUrls) async {
    await Future.wait(
      imageUrls.map((imageUrl) async {
        try {
          await _firebaseStorage.refFromURL(imageUrl).delete();
        } catch (e) {
          // 이미지 삭제 실패해도 전체 로직에는 영향 없도록
          print('Failed to delete image: $imageUrl, error: $e');
        }
      }),
    );
  }
}
