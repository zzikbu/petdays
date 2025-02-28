import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String uid;
  final String petId;
  final String image;
  final String name;
  final String breed;
  final String birthDay;
  final String firstMeetingDate;
  final String gender;
  final bool isNeutering; // 중성화
  final bool isDeleted; // 삭제 여부
  final Timestamp createdAt;

  const PetModel({
    required this.uid,
    required this.petId,
    required this.image,
    required this.name,
    required this.breed,
    required this.birthDay,
    required this.firstMeetingDate,
    required this.gender,
    required this.isNeutering,
    required this.isDeleted,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'petId': petId,
      'image': image,
      'name': name,
      'breed': breed,
      'birthDay': birthDay,
      'firstMeetingDate': firstMeetingDate,
      'gender': gender,
      'isNeutering': isNeutering,
      'isDeleted': isDeleted,
      'createdAt': createdAt,
    };
  }

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      uid: map['uid'],
      petId: map['petId'],
      image: map['image'],
      name: map['name'],
      breed: map['breed'],
      birthDay: map['birthDay'],
      firstMeetingDate: map['firstMeetingDate'],
      gender: map['gender'],
      isNeutering: map['isNeutering'],
      isDeleted: map['isDeleted'],
      createdAt: map['createdAt'],
    );
  }

  @override
  String toString() {
    return 'PetModel{uid: $uid, petId: $petId, image: $image, name: $name, breed: $breed, birthDay: $birthDay, firstMeetingDate: $firstMeetingDate, gender: $gender, isNeutering: $isNeutering, isDeleted: $isDeleted, createdAt: $createdAt}';
  }
}
