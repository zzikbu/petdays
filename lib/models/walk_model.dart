import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:petdays/models/pet_model.dart';
import 'package:petdays/models/user_model.dart';

class WalkModel {
  final String uid;
  final String walkId;
  final String distance;
  final String duration;
  final String mapImageUrl;
  final List<PetModel> pets;
  final Timestamp createAt;
  final UserModel writer;

  const WalkModel({
    required this.uid,
    required this.walkId,
    required this.distance,
    required this.duration,
    required this.mapImageUrl,
    required this.pets,
    required this.createAt,
    required this.writer,
  });

  Map<String, dynamic> toMap({
    required List<DocumentReference<Map<String, dynamic>>> petDocRefs,
    required DocumentReference<Map<String, dynamic>> userDocRef,
  }) {
    return {
      'uid': uid,
      'walkId': walkId,
      'distance': distance,
      'duration': duration,
      'mapImageUrl': mapImageUrl,
      'pets': petDocRefs,
      'createAt': createAt,
      'writer': userDocRef,
    };
  }

  factory WalkModel.fromMap(Map<String, dynamic> map) {
    return WalkModel(
      uid: map['uid'],
      walkId: map['walkId'],
      distance: map['distance'],
      duration: map['duration'],
      mapImageUrl: map['mapImageUrl'],
      pets: map['pets'], // PetModel이 이미 변환된 상태로 전달됨
      createAt: map['createAt'],
      writer: map['writer'], // UserModel이 이미 변환된 상태로 전달됨
    );
  }

  @override
  String toString() {
    return 'WalkModel{uid: $uid, walkId: $walkId, distance: $distance, duration: $duration, mapImageUrl: $mapImageUrl, pets: $pets, createAt: $createAt, writer: $writer}';
  }
}
