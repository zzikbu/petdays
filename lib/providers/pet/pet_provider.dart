import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/providers/pet/pet_state.dart';
import 'package:pet_log/repositories/pet_repository.dart';

class PetProvider extends StateNotifier<PetState> with LocatorMixin {
  // PetProvider 만들어질 때 PetState 같이 만들기
  PetProvider() : super(PetState.init());

  Future<void> uploadPet({
    required Uint8List? file, // 이미지
    required String type,
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

      await read<PetRepository>().uploadPet(
        uid: uid,
        file: file,
        type: type,
        name: name,
        breed: breed,
        birthDay: birthDay,
        firstMeetingDate: firstMeetingDate,
        gender: gender,
        isNeutering: isNeutering,
      );

      state = state.copyWith(petStatus: PetStatus.success); // 등록 완료 상태로 변경
    } on CustomException catch (_) {
      state =
          state.copyWith(petStatus: PetStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
