import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_log/models/user_model.dart';

class DiaryModel {
  final String uid;
  final String diaryId;
  final String title;
  final String desc;
  final List<String> imageUrls;
  final List<String> likes; // 좋아요한 유저
  final int likeCount;
  final int reportCount; // 신고당한 횟수
  final bool isLock; // 공개여부
  final Timestamp createAt;
  final UserModel writer;

  const DiaryModel({
    required this.uid,
    required this.diaryId,
    required this.title,
    required this.desc,
    required this.imageUrls,
    required this.likes,
    required this.likeCount,
    required this.reportCount,
    required this.isLock,
    required this.createAt,
    required this.writer,
  });

  Map<String, dynamic> toMap({
    required DocumentReference<Map<String, dynamic>> userDocRef,
  }) {
    return {
      'uid': this.uid,
      'diaryId': this.diaryId,
      'title': this.title,
      'desc': this.desc,
      'imageUrls': this.imageUrls,
      'likes': this.likes,
      'likeCount': this.likeCount,
      'reportCount': this.reportCount,
      'isLock': this.isLock,
      'createAt': this.createAt,
      'writer': userDocRef,
    };
  }

  factory DiaryModel.fromMap(Map<String, dynamic> map) {
    return DiaryModel(
      uid: map['uid'],
      diaryId: map['diaryId'],
      title: map['title'],
      desc: map['desc'],
      // List<dynamic>으로 만들어지기 때문에
      // List<String>.from()을 통해 List<String>으로 변환
      imageUrls: List<String>.from(map['imageUrls']),
      likes: List<String>.from(map['likes']),
      likeCount: map['likeCount'],
      reportCount: map['reportCount'],
      isLock: map['isLock'],
      createAt: map['createAt'],
      writer: map['writer'],
    );
  }
}
