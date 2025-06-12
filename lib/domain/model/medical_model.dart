import 'package:cloud_firestore/cloud_firestore.dart';

import 'pet_model.dart';
import 'user_model.dart';

class MedicalModel {
  final String uid;
  final String medicalId;
  final String visitedDate;
  final String reason;
  final String hospital;
  final String doctor;
  final String note;
  final List<String> imageUrls;
  final UserModel writer;
  final PetModel pet;
  final Timestamp createdAt;

  const MedicalModel({
    required this.uid,
    required this.medicalId,
    required this.visitedDate,
    required this.reason,
    required this.hospital,
    required this.doctor,
    required this.note,
    required this.imageUrls,
    required this.writer,
    required this.pet,
    required this.createdAt,
  });

  Map<String, dynamic> toMap({
    required DocumentReference<Map<String, dynamic>> userDocRef,
    required DocumentReference<Map<String, dynamic>> petDocRef,
  }) {
    return {
      'uid': uid,
      'medicalId': medicalId,
      'visitedDate': visitedDate,
      'reason': reason,
      'hospital': hospital,
      'doctor': doctor,
      'note': note,
      'imageUrls': imageUrls,
      'writer': userDocRef,
      'pet': petDocRef,
      'createdAt': createdAt,
    };
  }

  factory MedicalModel.fromMap(Map<String, dynamic> map) {
    return MedicalModel(
      uid: map['uid'],
      medicalId: map['medicalId'],
      visitedDate: map['visitedDate'],
      reason: map['reason'],
      hospital: map['hospital'],
      doctor: map['doctor'],
      note: map['note'],
      // List<dynamic>으로 만들어지기 때문에
      // List<String>.from()을 통해 List<String>으로 변환
      imageUrls: List<String>.from(map['imageUrls']),
      writer: map['writer'],
      pet: map['pet'],
      createdAt: map['createdAt'],
    );
  }
}
