import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/models/user_model.dart';
import 'package:uuid/uuid.dart';

class DiaryRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const DiaryRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

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
        "reportCount": 0,
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
      // 에러 발생시 store에 등록된 이미지 삭제
      _deleteImage(imageUrls);

      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      // 에러 발생시 store에 등록된 이미지 삭제
      _deleteImage(imageUrls);

      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: "Exception",
        message: e.toString(),
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
