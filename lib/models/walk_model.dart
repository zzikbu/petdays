import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_log/models/pet_model.dart';

class WalkModel {
  final String uid;
  final String walkId;
  final String distance;
  final String duration;
  final String mapImageUrl;
  final PetModel pet;
  final Timestamp createAt;

  const WalkModel({
    required this.uid,
    required this.walkId,
    required this.distance,
    required this.duration,
    required this.mapImageUrl,
    required this.pet,
    required this.createAt,
  });

  Map<String, dynamic> toMap({
    required DocumentReference<Map<String, dynamic>> petDocRef,
  }) {
    return {
      'uid': this.uid,
      'walkId': this.walkId,
      'distance': this.distance,
      'duration': this.duration,
      'mapImageUrl': this.mapImageUrl,
      'pets': petDocRef,
      'createAt': this.createAt,
    };
  }

  factory WalkModel.fromMap(Map<String, dynamic> map) {
    return WalkModel(
      uid: map['uid'],
      walkId: map['walkId'],
      distance: map['distance'],
      duration: map['duration'],
      mapImageUrl: map['mapImageUrl'],
      pet: map['pet'],
      createAt: map['createAt'],
    );
  }

  @override
  String toString() {
    return 'WorkModel{uid: $uid, walkId: $walkId, distance: $distance, duration: $duration, mapImageUrl: $mapImageUrl, pets: $pet, createAt: $createAt}';
  }
}
