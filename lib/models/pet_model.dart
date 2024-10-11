import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String uid;
  final String image;
  final String type;
  final String name;
  final String breed;
  final String birthDay;
  final String firstMeetingDate;
  final String gender;
  final bool isNeutering; // 중성화
  final Timestamp createAt;

  const PetModel({
    required this.uid,
    required this.image,
    required this.type,
    required this.name,
    required this.breed,
    required this.birthDay,
    required this.firstMeetingDate,
    required this.gender,
    required this.isNeutering,
    required this.createAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'image': this.image,
      'type': this.type,
      'name': this.name,
      'breed': this.breed,
      'birthDay': this.birthDay,
      'firstMeetingDate': this.firstMeetingDate,
      'gender': this.gender,
      'isNeutering': this.isNeutering,
      'createAt': this.createAt,
    };
  }

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      uid: map['uid'],
      image: map['image'],
      type: map['type'],
      name: map['name'],
      breed: map['breed'],
      birthDay: map['birthDay'],
      firstMeetingDate: map['firstMeetingDate'],
      gender: map['gender'],
      isNeutering: map['isNeutering'],
      createAt: map['createAt'],
    );
  }

  @override
  String toString() {
    return 'PetModel{uid: $uid, image: $image, type: $type, name: $name, breed: $breed, birthDay: $birthDay, firstMeetingDate: $firstMeetingDate, gender: $gender, isNeutering: $isNeutering, createAt: $createAt}';
  }
}
