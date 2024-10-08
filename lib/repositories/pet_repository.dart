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

  Future<void> uploadPet({
    required String uid,
    required Uint8List? file,
    required String type,
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
        "image": downloadURL,
        "type": type,
        "name": name,
        "breed": breed,
        "birthDay": birthDay,
        "firstMeetingDate": firstMeetingDate,
        "gender": gender,
        "isNeutering": isNeutering
      });

      // Firestore에 문서 저장
      await petDocRef.set(petModel.toMap());
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
