import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/pet_model.dart';
import 'package:petdays/providers/pet/pet_state.dart';
import 'package:petdays/providers/user/user_state.dart';
import 'package:petdays/repositories/pet_repository.dart';

class PetProvider extends StateNotifier<PetState> with LocatorMixin {
  // PetProvider 만들어질 때 PetState 같이 만들기
  PetProvider() : super(PetState.init());

  // 펫 삭제
  Future<void> deletePet({
    required String petId,
  }) async {
    state = state.copyWith(petStatus: PetStatus.submitting);

    try {
      await read<PetRepository>().deletePet(petId: petId);

      // 삭제된 펫을 제외한 새로운 리스트 생성
      List<PetModel> newPetList =
          state.petList.where((pet) => pet.petId != petId).toList();

      state = state.copyWith(
        petStatus: PetStatus.success,
        petList: newPetList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(petStatus: PetStatus.error);
      rethrow;
    }
  }

  // 펫 수정
  Future<void> updatePet({
    required String petId,
    required Uint8List? file,
    required String name,
    required String breed,
    required String birthDay,
    required String firstMeetingDate,
    required String gender,
    required bool isNeutering,
    required String currentImageUrl, // 현재 이미지 URL
    required Timestamp createAt,
  }) async {
    try {
      state = state.copyWith(petStatus: PetStatus.submitting);

      String uid = read<UserState>().userModel.uid;

      // 수정된 펫 데이터 가져오기
      PetModel updatedPet = await read<PetRepository>().updatePet(
        petId: petId,
        uid: uid,
        file: file,
        name: name,
        breed: breed,
        birthDay: birthDay,
        firstMeetingDate: firstMeetingDate,
        gender: gender,
        isNeutering: isNeutering,
        currentImageUrl: currentImageUrl,
        createAt: createAt,
      );

      List<PetModel> newPetList = state.petList.map((pet) {
        if (pet.petId == petId) {
          return updatedPet;
        }
        return pet;
      }).toList();

      state = state.copyWith(
        petStatus: PetStatus.success,
        petList: newPetList,
      );
    } on CustomException catch (_) {
      state = state.copyWith(petStatus: PetStatus.error);
      rethrow;
    }
  }

  // 펫 가져오기
  Future<void> getPetList({
    required String uid,
  }) async {
    try {
      state = state.copyWith(petStatus: PetStatus.fetching); // 상태 변경

      List<PetModel> petList =
          await read<PetRepository>().getDiaryList(uid: uid);

      state = state.copyWith(
        petList: petList,
        petStatus: PetStatus.success,
      ); // 상태 변경
    } on CustomException catch (_) {
      state =
          state.copyWith(petStatus: PetStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }

  // 펫 추가
  Future<void> uploadPet({
    required Uint8List? file, // 이미지
    required String name,
    required String breed,
    required String birthDay,
    required String firstMeetingDate,
    required String gender,
    required bool isNeutering,
  }) async {
    try {
      state = state.copyWith(petStatus: PetStatus.submitting); // 등록 중으로 상태 변경

      String uid = read<User>().uid; // 작성자

      // 새로 등록한 펫을 리스트 맨뒤에 추가 해주기 위해 변수에 저장
      PetModel petModel = await read<PetRepository>().uploadPet(
        uid: uid,
        file: file,
        name: name,
        breed: breed,
        birthDay: birthDay,
        firstMeetingDate: firstMeetingDate,
        gender: gender,
        isNeutering: isNeutering,
      );

      state = state.copyWith(
        petStatus: PetStatus.success,
        petList: [...state.petList, petModel], // 새로 등록한 펫을 리스트 맨뒤에 추가
      ); // 등록 완료 상태로 변경
    } on CustomException catch (_) {
      state =
          state.copyWith(petStatus: PetStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
