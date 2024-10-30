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
  final List<String> reports; // 성장일기를 신고한 유저
  final int adReportCount; // 상업적 광고 및 판매
  final int abuseReportCount; // 욕설/비하
  final int adultReportCount; // 음란물
  final int otherReportCount; // 기타
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
    required this.reports,
    required this.adReportCount,
    required this.abuseReportCount,
    required this.adultReportCount,
    required this.otherReportCount,
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
      'reports': this.reports,
      'adReportCount': this.adReportCount,
      'abuseReportCount': this.abuseReportCount,
      'adultReportCount': this.adultReportCount,
      'otherReportCount': this.otherReportCount,
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
      reports: List<String>.from(map['reports']),
      adReportCount: map['adReportCount'],
      abuseReportCount: map['abuseReportCount'],
      adultReportCount: map['adultReportCount'],
      otherReportCount: map['otherReportCount'],
      isLock: map['isLock'],
      createAt: map['createAt'],
      writer: map['writer'],
    );
  }

  @override
  String toString() {
    return 'DiaryModel{uid: $uid, diaryId: $diaryId, title: $title, desc: $desc, imageUrls: $imageUrls, likes: $likes, likeCount: $likeCount, reports: $reports, adReportCount: $adReportCount, abuseReportCount: $abuseReportCount, adultReportCount: $adultReportCount, otherReportCount: $otherReportCount, isLock: $isLock, createAt: $createAt, writer: $writer}';
  }
}
