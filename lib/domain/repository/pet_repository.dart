import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/pet_model.dart';

abstract interface class PetRepository {
  /// 반려동물 추가
  Future<PetModel> uploadPet({
    required String uid,
    required Uint8List? file,
    required String name,
    required String breed,
    required String birthDay,
    required String firstMeetingDate,
    required String gender,
    required bool isNeutering,
  });

  /// 반려동물 수정
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
  });

  /// 반려동물 삭제
  Future<void> deletePet({
    required String petId,
  });

  /// 반려동물 리스트 가져오기
  Future<List<PetModel>> getDiaryList({
    required String uid,
  });
}
