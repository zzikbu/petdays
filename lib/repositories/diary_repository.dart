import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/diary_model.dart';
import 'package:petdays/models/user_model.dart';
import 'package:uuid/uuid.dart';

class DiaryRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const DiaryRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  // 성장일기 수정
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
        await firebaseStorage.refFromURL(imageUrl).delete();
      }

      // 2. 새로운 이미지들 storage에 업로드
      if (files.isNotEmpty) {
        Reference ref = firebaseStorage.ref().child("diaries").child(diaryId);

        newImageUrls = await Future.wait(files.map((e) async {
          String imageId = Uuid().v1();
          TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e));
          return await taskSnapshot.ref.getDownloadURL();
        }).toList());
      }

      // 3. 모든 이미지 URL 합치기
      List<String> allImageUrls = [...remainImageUrls, ...newImageUrls];

      // 4. 트랜잭션으로 데이터 업데이트
      return await firebaseFirestore
          .runTransaction<DiaryModel>((transaction) async {
        // firestore 문서 참조
        DocumentReference<Map<String, dynamic>> diaryDocRef =
            firebaseFirestore.collection("diaries").doc(diaryId);
        DocumentReference<Map<String, dynamic>> userDocRef =
            firebaseFirestore.collection("users").doc(uid);

        // 현재 문서 상태 가져오기
        DocumentSnapshot<Map<String, dynamic>> diarySnapshot =
            await transaction.get(diaryDocRef);
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await transaction.get(userDocRef);

        if (!diarySnapshot.exists) {
          throw CustomException(
            title: "not-found",
            message: "Diary does not exist",
          );
        }

        // 현재 데이터 가져오기
        Map<String, dynamic> currentData = diarySnapshot.data()!;
        UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

        // 새로운 DiaryModel 생성 (likes와 관련된 필드는 현재 값 유지)
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
          "createAt": currentData['createAt'],
          "writer": userModel,
        });

        // 트랜잭션 내에서 문서 업데이트
        transaction.update(
          diaryDocRef,
          diaryModel.toMap(userDocRef: userDocRef),
        );

        return diaryModel;
      });
    } on FirebaseException catch (e) {
      _deleteImage(newImageUrls); // 에러 발생시 새로 업로드된 이미지 삭제

      throw CustomException(
        title: '성장일기',
        message: '성장일기 수정에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (e) {
      _deleteImage(newImageUrls); // 에러 발생시 새로 업로드된 이미지 삭제
      throw CustomException(
        title: "성장일기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 성장일기 삭제
  Future<void> deleteDiary({
    required DiaryModel diaryModel,
  }) async {
    try {
      WriteBatch batch = firebaseFirestore.batch();

      DocumentReference<Map<String, dynamic>> diaryDocRef =
          firebaseFirestore.collection('diaries').doc(diaryModel.diaryId);
      DocumentReference<Map<String, dynamic>> writerDocRef =
          firebaseFirestore.collection('users').doc(diaryModel.uid);

      List<String> likes = await diaryDocRef
          .get()
          .then((value) => List<String>.from(value.data()!['likes']));

      // 해당 성장일기에 좋아요를 누른 users 문서의 likes 필드에서 diaryId 삭제
      likes.forEach((uid) {
        batch.update(firebaseFirestore.collection('users').doc(uid), {
          'likes': FieldValue.arrayRemove([diaryModel.diaryId]),
        });
      });

      // diaries 컬렉션에서 문서 삭제
      batch.delete(diaryDocRef);

      // 성장일기 작성자의 users 문서에서 diaryCount 1 감소
      batch.update(writerDocRef, {
        'diaryCount': FieldValue.increment(-1),
      });

      // storage 이미지 삭제
      diaryModel.imageUrls.forEach((element) async {
        await firebaseStorage.refFromURL(element).delete();
      });

      batch.commit();
    } on FirebaseException catch (e) {
      throw CustomException(
        title: '성장일기',
        message: '성장일기 삭제에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (e) {
      throw CustomException(
        title: "성장일기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 성장일기 가져오기
  Future<List<DiaryModel>> getDiaryList({
    required String uid,
  }) async {
    try {
      // snapshot 을 생성하기 위한 query 생성
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('diaries')
          .where('uid', isEqualTo: uid)
          .orderBy('createAt', descending: true)
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
      throw CustomException(
        title: '성장일기',
        message: '성장일기 가져오기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (e) {
      throw CustomException(
        title: "성장일기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 성장일기 업로드
  Future<DiaryModel> uploadDiary({
    required String uid, // 작성자
    required List<String> files, // 이미지들
    required String title, // 제목
    required String desc, // 내용
    required bool isLock, // 공개여부
  }) async {
    List<String> imageUrls = [];

    try {
      // 이 배치에 추가된 Firestore 작업들은 commit()을 호출하기 전까지
      // 실행되지 않고, 큐에 대기 상태로 존재
      WriteBatch batch = firebaseFirestore.batch();

      String diaryId = Uuid().v1(); // Generate a v1 (time-based) id

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> diaryDocRef =
          firebaseFirestore.collection("diaries").doc(diaryId);

      DocumentReference<Map<String, dynamic>> userDocRef =
          firebaseFirestore.collection("users").doc(uid);

      // firestorage 참조
      Reference ref = firebaseStorage.ref().child("diaries").child(diaryId);

      imageUrls = await Future.wait(files.map((e) async {
        String imageId = Uuid().v1();
        TaskSnapshot taskSnapshot =
            await ref.child(imageId).putFile(File(e)); // stoage에 저장
        return await taskSnapshot.ref
            .getDownloadURL(); // 이미지에 접근할 수 있는 경로를 문자열로 반환
      }).toList());

      // 유저 모델 생성
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await userDocRef.get();
      UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

      // 피드 모델 생성
      DiaryModel diaryModel = DiaryModel.fromMap({
        "uid": uid,
        "diaryId": diaryId,
        "title": title,
        "desc": desc,
        "imageUrls": imageUrls,
        "likes": [], // 좋아요 누른 유저들의 uid
        "likeCount": 0,
        "reports": [], // 신고하기 한 유저들의 uid
        "adReportCount": 0,
        "abuseReportCount": 0,
        "adultReportCount": 0,
        "otherReportCount": 0,
        "isLock": isLock,
        "createAt": Timestamp.now(), // 현재 시간
        "writer": userModel, // 생성한 유저 모델
      });

      batch.set(diaryDocRef, diaryModel.toMap(userDocRef: userDocRef));

      batch.update(userDocRef, {
        "diaryCount": FieldValue.increment(1), // 기존값에서 1 증가
      });

      // 모든 작업이 큐에 추가된 후, commit()을 호출하면 Firestore에 모든 작업이 한 번에 적용
      // 만약 작업 중 하나라도 실패하면 전체 작업이 취소되며, 이로 인해 데이터의 일관성이 유지
      batch.commit();
      return diaryModel; // 등록한 성장일기를 리스트에 추가하기 위해 반환
    } on FirebaseException catch (e) {
      _deleteImage(imageUrls); // 에러 발생시 Storage에 등록된 이미지 삭제

      throw CustomException(
        title: '성장일기',
        message: '성장일기 업로드에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (e) {
      _deleteImage(imageUrls); // 에러 발생시 Storage에 등록된 이미지 삭제

      throw CustomException(
        title: "성장일기",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 이미지 삭제 함수
  void _deleteImage(List<String> imageUrls) {
    imageUrls.forEach(
      (element) async {
        await firebaseStorage.refFromURL(element).delete();
      },
    );
  }
}
