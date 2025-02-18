import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'pet_model.dart';
import 'user_model.dart';

@immutable
class WalkModel {
  final String uid;
  final String walkId;
  final String distance;
  final String duration;
  final String mapImageUrl;
  final List<PetModel> pets;
  final Timestamp createdAt;
  final UserModel writer;

  const WalkModel({
    required this.uid,
    required this.walkId,
    required this.distance,
    required this.duration,
    required this.mapImageUrl,
    required this.pets,
    required this.createdAt,
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
      'createdAt': createdAt,
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
      createdAt: map['createdAt'],
      writer: map['writer'], // UserModel이 이미 변환된 상태로 전달됨
    );
  }

  @override
  String toString() {
    return 'WalkModel{uid: $uid, walkId: $walkId, distance: $distance, duration: $duration, mapImageUrl: $mapImageUrl, pets: $pets, createdAt: $createdAt, writer: $writer}';
  }
}
