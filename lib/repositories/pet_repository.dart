import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/pet_model.dart';
import 'package:uuid/uuid.dart';

class PetRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const PetRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  // 펫 가져오기
  Future<List<PetModel>> getDiaryList({
    required String uid,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('pets')
          .where('uid', isEqualTo: uid)
          .orderBy('createAt', descending: false) // 오랜된 순 정렬
          .get();

      return await Future.wait(snapshot.docs.map(
        (e) async {
          Map<String, dynamic> data = e.data();
          return PetModel.fromMap(data);
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

  // 펫 추가
  Future<PetModel> uploadPet({
    required String uid,
    required Uint8List? file,
    required String name,
    required String breed,
    required String birthDay,
    required String firstMeetingDate,
    required String gender,
    required bool isNeutering,
  }) async {
    String downloadURL = "";

    try {
      String petId = Uuid().v1(); // Generate a v1 (time-based) id

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> petDocRef =
          firebaseFirestore.collection("pets").doc(petId);

      // firestorage
      Reference ref =
          firebaseStorage.ref().child("pets").child(petId); // 아직 업로드 X
      TaskSnapshot snapshot = await ref.putData(file!); // 업로드
      downloadURL = await snapshot.ref.getDownloadURL(); // 사진 경로 받기

      PetModel petModel = PetModel.fromMap({
        "uid": uid,
        "petId": petId,
        "image": downloadURL,
        "name": name,
        "breed": breed,
        "birthDay": birthDay,
        "firstMeetingDate": firstMeetingDate,
        "gender": gender,
        "isNeutering": isNeutering,
        "createAt": Timestamp.now(), // 현재 시간
      });

      // Firestore에 문서 저장
      await petDocRef.set(petModel.toMap());

      return petModel; // 등록한 펫을 리스트에 추가하기 위해 반환
    } on FirebaseException catch (e) {
      // 에러 발생시 storage에 등록된 이미지 삭제
      await firebaseStorage.refFromURL(downloadURL).delete();

      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      // 에러 발생시 storage에 등록된 이미지 삭제
      await firebaseStorage.refFromURL(downloadURL).delete();

      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }
}
