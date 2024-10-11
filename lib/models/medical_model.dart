import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_log/models/pet_model.dart';
import 'package:pet_log/models/user_model.dart';

class MedicalModel {
  final String uid;
  final String medicalId;
  final String visitDate;
  final String reason;
  final String hospital;
  final String doctor;
  final String note;
  final List<String> imageUrls;
  final UserModel writer;
  final PetModel pet;

  const MedicalModel({
    required this.uid,
    required this.medicalId,
    required this.visitDate,
    required this.reason,
    required this.hospital,
    required this.doctor,
    required this.note,
    required this.imageUrls,
    required this.writer,
    required this.pet,
  });

  Map<String, dynamic> toMap({
    required DocumentReference<Map<String, dynamic>> userDocRef,
    required DocumentReference<Map<String, dynamic>> petDocRef,
  }) {
    return {
      'uid': this.uid,
      'medicalId': this.medicalId,
      'visitDate': this.visitDate,
      'reason': this.reason,
      'hospital': this.hospital,
      'doctor': this.doctor,
      'note': this.note,
      'imageUrls': this.imageUrls,
      'writer': userDocRef,
      'pet': petDocRef,
    };
  }

  factory MedicalModel.fromMap(Map<String, dynamic> map) {
    return MedicalModel(
      uid: map['uid'],
      medicalId: map['medicalId'],
      visitDate: map['visitDate'],
      reason: map['reason'],
      hospital: map['hospital'],
      doctor: map['doctor'],
      note: map['note'],
      // List<dynamic>으로 만들어지기 때문에
      // List<String>.from()을 통해 List<String>으로 변환
      imageUrls: List<String>.from(map['imageUrls']),
      writer: map['writer'],
      pet: map['pet'],
    );
  }
}
