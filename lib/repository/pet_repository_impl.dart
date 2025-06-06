import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../exceptions/custom_exception.dart';
import '../models/pet_model.dart';
import 'pet_repository.dart';

class PetRepositoryImpl implements PetRepository {
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;

  const PetRepositoryImpl({
    required FirebaseStorage firebaseStorage,
    required FirebaseFirestore firebaseFirestore,
  })  : _firebaseStorage = firebaseStorage,
        _firebaseFirestore = firebaseFirestore;

  @override
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
      String petId = const Uuid().v1();

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> petDocRef =
          _firebaseFirestore.collection("pets").doc(petId);

      // firestorage
      Reference ref = _firebaseStorage.ref().child("pets").child(petId);
      TaskSnapshot snapshot = await ref.putData(file!);
      downloadURL = await snapshot.ref.getDownloadURL();

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
        "isDeleted": false,
        "createdAt": Timestamp.now(),
      });

      await petDocRef.set(petModel.toMap());

      return petModel;
    } on FirebaseException {
      await _deleteImage(downloadURL);
      throw const CustomException(
        title: '반려동물',
        message: '반려동물 추가하기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      await _deleteImage(downloadURL);
      throw const CustomException(
        title: "반려동물",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<PetModel> updatePet({
    required String petId,
    required String uid,
    required Uint8List? file,
    required String name,
    required String breed,
    required String birthDay,
    required String firstMeetingDate,
    required String gender,
    required bool isNeutering,
    required String currentImageUrl,
    required Timestamp createdAt,
  }) async {
    String downloadURL = currentImageUrl;

    try {
      WriteBatch batch = _firebaseFirestore.batch();

      DocumentReference<Map<String, dynamic>> petDocRef =
          _firebaseFirestore.collection("pets").doc(petId);

      if (file != null) {
        if (currentImageUrl.isNotEmpty) {
          await _firebaseStorage.refFromURL(currentImageUrl).delete();
        }

        Reference ref = _firebaseStorage.ref().child("pets").child(petId);
        TaskSnapshot snapshot = await ref.putData(file);
        downloadURL = await snapshot.ref.getDownloadURL();
      }

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
        "isDeleted": false,
        "createdAt": createdAt,
      });

      batch.update(petDocRef, petModel.toMap());

      await batch.commit();
      return petModel;
    } on FirebaseException {
      if (downloadURL != currentImageUrl) {
        await _deleteImage(downloadURL);
      }

      throw const CustomException(
        title: '반려동물',
        message: '반려동물 삭제에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      if (downloadURL != currentImageUrl) {
        await _deleteImage(downloadURL);
      }

      throw const CustomException(
        title: "반려동물",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> deletePet({
    required String petId,
  }) async {
    try {
      await _firebaseFirestore.collection('pets').doc(petId).update({
        'isDeleted': true,
      });
    } on FirebaseException {
      throw const CustomException(
        title: '반려동물',
        message: '반려동물 삭제에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "반려동물",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<List<PetModel>> getDiaryList({
    required String uid,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection('pets')
          .where('uid', isEqualTo: uid)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: false)
          .get();

      return await Future.wait(snapshot.docs.map(
        (e) async {
          Map<String, dynamic> data = e.data();
          return PetModel.fromMap(data);
        },
      ).toList());
    } on FirebaseException {
      throw const CustomException(
        title: '반려동물',
        message: '반려동물 가져오기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "반려동물",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  /// 이미지 삭제 함수
  Future<void> _deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        await _firebaseStorage.refFromURL(imageUrl).delete();
      }
    } catch (e) {
      print('Failed to delete image: $imageUrl, error: $e');
    }
  }
}
