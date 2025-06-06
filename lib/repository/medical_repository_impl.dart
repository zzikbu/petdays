import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../exceptions/custom_exception.dart';
import '../models/medical_model.dart';
import '../models/pet_model.dart';
import '../models/user_model.dart';
import 'medical_repository.dart';

class MedicalRepositoryImpl implements MedicalRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const MedicalRepositoryImpl({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  // 진료기록 수정
  @override
  Future<MedicalModel> updateMedical({
    required String medicalId,
    required String uid,
    required String petId,
    required List<String> files, // 새로 추가된 이미지들
    required List<String> remainImageUrls, // 유지할 기존 이미지 URL들
    required List<String> deleteImageUrls, // 삭제할 기존 이미지 URL들
    required String visitedDate,
    required String reason,
    required String hospital,
    required String doctor,
    required String note,
  }) async {
    List<String> newImageUrls = [];

    try {
      WriteBatch batch = firebaseFirestore.batch();

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> medicalDocRef =
          firebaseFirestore.collection("medicals").doc(medicalId);
      DocumentReference<Map<String, dynamic>> userDocRef =
          firebaseFirestore.collection("users").doc(uid);
      DocumentReference<Map<String, dynamic>> petDocRef =
          firebaseFirestore.collection("pets").doc(petId);

      // 1. 삭제할 이미지들 storage에서 제거
      for (String imageUrl in deleteImageUrls) {
        await firebaseStorage.refFromURL(imageUrl).delete();
      }

      // 2. 새로운 이미지들 storage에 업로드
      if (files.isNotEmpty) {
        Reference ref = firebaseStorage.ref().child("medicals").child(medicalId);

        newImageUrls = await Future.wait(files.map((e) async {
          String imageId = const Uuid().v1();
          TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e));
          return await taskSnapshot.ref.getDownloadURL();
        }).toList());
      }

      // 3. 모든 이미지 URL 합치기 (유지할 이미지들 + 새로운 이미지들)
      List<String> allImageUrls = [...remainImageUrls, ...newImageUrls];

      // 4. 유저와 펫 모델 가져오기
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDocRef.get();
      UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

      DocumentSnapshot<Map<String, dynamic>> petSnapshot = await petDocRef.get();
      PetModel petModel = PetModel.fromMap(petSnapshot.data()!);

      // 5. 수정된 MedicalModel 생성
      MedicalModel medicalModel = MedicalModel.fromMap({
        "uid": uid,
        "pet": petModel,
        "medicalId": medicalId,
        "imageUrls": allImageUrls,
        "visitedDate": visitedDate,
        "reason": reason,
        "hospital": hospital,
        "doctor": doctor,
        "note": note,
        "writer": userModel,
        "createdAt": Timestamp.now(),
      });

      // 6. Firestore 문서 업데이트
      batch.update(
        medicalDocRef,
        medicalModel.toMap(
          userDocRef: userDocRef,
          petDocRef: petDocRef,
        ),
      );

      await batch.commit();
      return medicalModel;
    } on FirebaseException {
      _deleteImage(newImageUrls); // 에러 발생시 새로 업로드된 이미지 삭제

      throw const CustomException(
        title: '진료기록',
        message: '진료기록 수정에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      _deleteImage(newImageUrls); // 에러 발생시 새로 업로드된 이미지 삭제

      throw const CustomException(
        title: "진료기록",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 진료기록 삭제
  @override
  Future<void> deleteDiary({
    required MedicalModel medicalModel,
  }) async {
    try {
      WriteBatch batch = firebaseFirestore.batch();

      DocumentReference<Map<String, dynamic>> medicalDocRef =
          firebaseFirestore.collection('medicals').doc(medicalModel.medicalId);
      DocumentReference<Map<String, dynamic>> writerDocRef =
          firebaseFirestore.collection('users').doc(medicalModel.uid);

      // diaries 컬렉션에서 문서 삭제
      batch.delete(medicalDocRef);

      // 작성자의 users 문서에서 medicalCount 1 감소
      batch.update(writerDocRef, {
        'medicalCount': FieldValue.increment(-1),
      });

      // storage 이미지 삭제
      medicalModel.imageUrls.forEach((element) async {
        await firebaseStorage.refFromURL(element).delete();
      });

      batch.commit();
    } on FirebaseException {
      throw const CustomException(
        title: '진료기록',
        message: '진료기록 삭제에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "진료기록",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 진료기록 가져오기
  @override
  Future<List<MedicalModel>> getMedicalList({
    required String uid,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('medicals')
          .where('uid', isEqualTo: uid)
          .orderBy('visitedDate', descending: true) // 최신순 정렬
          .get();

      return await Future.wait(snapshot.docs.map(
        (e) async {
          Map<String, dynamic> data = e.data();

          // pet 필드 처리
          DocumentReference<Map<String, dynamic>> petDocRef = data["pet"];
          DocumentSnapshot<Map<String, dynamic>> petSnapshot = await petDocRef.get();
          PetModel petModel = PetModel.fromMap(petSnapshot.data()!);
          data["pet"] = petModel;

          // writer 필드 처리
          DocumentReference<Map<String, dynamic>> writerDocRef = data["writer"];
          DocumentSnapshot<Map<String, dynamic>> writerSnapshot = await writerDocRef.get();
          UserModel userModel = UserModel.fromMap(writerSnapshot.data()!);
          data["writer"] = userModel;
          return MedicalModel.fromMap(data);
        },
      ).toList());
    } on FirebaseException {
      throw const CustomException(
        title: '진료기록',
        message: '진료기록 가져오기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "진료기록",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // 진료기록 업로드
  @override
  Future<MedicalModel> uploadMedical({
    required String uid, // 작성자
    required String petId,
    required List<String> files, // 이미지들
    required String visitedDate,
    required String reason,
    required String hospital,
    required String doctor,
    required String note,
  }) async {
    List<String> imageUrls = [];

    try {
      // 이 배치에 추가된 Firestore 작업들은 commit()을 호출하기 전까지
      // 실행되지 않고, 큐에 대기 상태로 존재
      WriteBatch batch = firebaseFirestore.batch();

      String medicalId = const Uuid().v1(); // Generate a v1 (time-based) id

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> medicalDocRef =
          firebaseFirestore.collection("medicals").doc(medicalId);

      DocumentReference<Map<String, dynamic>> userDocRef =
          firebaseFirestore.collection("users").doc(uid);

      DocumentReference<Map<String, dynamic>> petDocRef =
          firebaseFirestore.collection("pets").doc(petId);

      // firestorage 참조
      Reference ref = firebaseStorage.ref().child("medicals").child(medicalId);

      imageUrls = await Future.wait(files.map((e) async {
        String imageId = const Uuid().v1();
        TaskSnapshot taskSnapshot = await ref.child(imageId).putFile(File(e)); // stoage에 저장
        return await taskSnapshot.ref.getDownloadURL(); // 이미지에 접근할 수 있는 경로를 문자열로 반환
      }).toList());

      // 유저 모델 생성
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDocRef.get();
      UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

      // 펫 모델 생성
      DocumentSnapshot<Map<String, dynamic>> petSnapshot = await petDocRef.get();
      PetModel petModel = PetModel.fromMap(petSnapshot.data()!);

      MedicalModel medicalModel = MedicalModel.fromMap({
        "uid": uid,
        "pet": petModel,
        "medicalId": medicalId,
        "imageUrls": imageUrls,
        "visitedDate": visitedDate,
        "reason": reason,
        "hospital": hospital,
        "doctor": doctor,
        "note": note,
        "writer": userModel,
        "createdAt": Timestamp.now(), // 현재 시간
      });

      batch.set(
        medicalDocRef,
        medicalModel.toMap(
          userDocRef: userDocRef,
          petDocRef: petDocRef,
        ),
      );

      batch.update(userDocRef, {
        "medicalCount": FieldValue.increment(1), // 기존값에서 1 증가
      });

      // 모든 작업이 큐에 추가된 후, commit()을 호출하면 Firestore에 모든 작업이 한 번에 적용
      // 만약 작업 중 하나라도 실패하면 전체 작업이 취소되며, 이로 인해 데이터의 일관성이 유지
      batch.commit();
      return medicalModel;
    } on FirebaseException {
      _deleteImage(imageUrls); // 에러 발생시 Storage에 등록된 이미지 삭제

      throw const CustomException(
        title: '진료기록',
        message: '진료기록 업로드에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      _deleteImage(imageUrls); // 에러 발생시 Storage에 등록된 이미지 삭제

      throw const CustomException(
        title: "진료기록",
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
