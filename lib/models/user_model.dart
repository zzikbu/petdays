class UserModel {
  final String uid;
  final String nickname;
  final String? email;
  final String? profileImage;
  final String providerId;
  final int walkCount;
  final int diaryCount;
  final int medicalCount;
  final List<String> blocks; // 차단한 유저
  final List<String> likes; // 좋아요한 글

  const UserModel({
    required this.uid,
    required this.nickname,
    required this.email,
    required this.profileImage,
    required this.providerId,
    required this.walkCount,
    required this.diaryCount,
    required this.medicalCount,
    required this.blocks,
    required this.likes,
  });

  factory UserModel.init() {
    return UserModel(
      uid: "",
      nickname: "",
      email: null,
      profileImage: null,
      providerId: "",
      walkCount: 0,
      diaryCount: 0,
      medicalCount: 0,
      blocks: [],
      likes: [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': this.uid,
      'nickname': this.nickname,
      'email': this.email,
      'profileImage': this.profileImage,
      'providerId': this.providerId,
      'walkCount': this.walkCount,
      'diaryCount': this.diaryCount,
      'medicalCount': this.medicalCount,
      'blocks': this.blocks,
      'likes': this.likes,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      nickname: map['nickname'],
      email: map['email'],
      profileImage: map['profileImage'],
      providerId: map['providerId'],
      walkCount: map['walkCount'],
      diaryCount: map['diaryCount'],
      medicalCount: map['medicalCount'],
      // List<dynamic>으로 만들어지기 때문에
      // List<String>.from()을 통해 List<String>으로 변환
      blocks: List<String>.from(map['blocks']),
      likes: List<String>.from(map['likes']),
    );
  }

  @override
  String toString() {
    return 'UserModel{uid: $uid, nickname: $nickname, email: $email, profileImage: $profileImage, providerId: $providerId, walkCount: $walkCount, diaryCount: $diaryCount, medicalCount: $medicalCount, blocks: $blocks, likes: $likes}';
  }
}
