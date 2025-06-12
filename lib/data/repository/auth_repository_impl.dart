import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../exceptions/custom_exception.dart';
import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firebaseFirestore;
  final FirebaseStorage _firebaseStorage;

  const AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firebaseFirestore,
    required FirebaseStorage firebaseStorage,
  })  : _firebaseAuth = firebaseAuth,
        _firebaseFirestore = firebaseFirestore,
        _firebaseStorage = firebaseStorage;

  @override
  Future<String> generateRandomNickname() async {
    // 감정 리스트
    const List<String> emotions = [
      "상냥한",
      "착한",
      "행복한",
      "슬픈",
      "용감한",
      "사랑스러운",
      "활발한",
      "차분한",
      "겸손한",
      "신나는",
      "지혜로운",
      "재밌는",
      "똑똑한",
      "충성스러운",
      "조용한",
      "적극적인",
      "기운찬",
      "자상한",
      "귀여운",
      "명랑한"
    ];

    // 동물 리스트
    const List<String> animals = [
      "악어",
      "토끼",
      "호랑이",
      "코끼리",
      "사자",
      "늑대",
      "여우",
      "고양이",
      "강아지",
      "곰",
      "다람쥐",
      "사슴",
      "기린",
      "표범",
      "수달",
      "너구리",
      "펭귄",
      "코알라",
      "돌고래",
      "하마"
    ];

    final CollectionReference<Map<String, dynamic>> userCollection =
        _firebaseFirestore.collection("users");
    final Random random = Random();

    // 중복되지 않는 닉네임이 생성될 때까지 반복
    while (true) {
      final String randomEmotion = emotions[random.nextInt(emotions.length)];
      final String randomAnimal = animals[random.nextInt(animals.length)];
      final int randomNumber = random.nextInt(1000);

      final String generatedNickname = '$randomEmotion$randomAnimal$randomNumber';

      // 닉네임 중복 확인
      final QuerySnapshot querySnapshot =
          await userCollection.where('nickname', isEqualTo: generatedNickname).get();

      if (querySnapshot.docs.isEmpty) {
        return generatedNickname;
      }
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseException {
      throw const CustomException(
        title: '메일 전송 실패',
        message: '비밀번호 재설정 메일 전송에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "메일 전송 실패",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    try {
      final User user = _firebaseAuth.currentUser!;
      final String uid = user.uid;
      final String provider = user.providerData[0].providerId;

      // 재인증
      await _reauthenticateUser(user, provider, password);

      // 사용자 데이터 조회
      final List<QuerySnapshot<Map<String, dynamic>>> snapshots = await Future.wait([
        _firebaseFirestore.collection('pets').where('uid', isEqualTo: uid).get(),
        _firebaseFirestore.collection('diaries').where('uid', isEqualTo: uid).get(),
        _firebaseFirestore.collection('medicals').where('uid', isEqualTo: uid).get(),
        _firebaseFirestore.collection('walks').where('uid', isEqualTo: uid).get(),
      ]);

      final WriteBatch batch = _firebaseFirestore.batch();

      // users 문서 삭제
      batch.delete(_firebaseFirestore.collection('users').doc(uid));

      // 프로필 이미지 삭제
      await _deleteProfileImage(uid);

      // 각 데이터 삭제
      await Future.wait([
        _deletePets(snapshots[0], batch),
        _deleteDiaries(snapshots[1], batch),
        _deleteMedicals(snapshots[2], batch),
        _deleteWalks(snapshots[3], batch),
      ]);

      await batch.commit();

      // 계정 삭제
      await user.delete();
    } on CustomException {
      rethrow;
    } on FirebaseException {
      throw const CustomException(
        title: '회원탈퇴',
        message: '회원탈퇴에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "회원탈퇴",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      await _firebaseAuth.signOut();
    } on FirebaseException {
      throw const CustomException(
        title: '로그아웃',
        message: '로그아웃이 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "로그아웃",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      final bool isVerified = userCredential.user!.emailVerified;

      if (!isVerified) {
        await userCredential.user!.sendEmailVerification();
        await _firebaseAuth.signOut();

        throw const CustomException(
          title: "로그인",
          message: "인증되지 않은 이메일입니다. 메일함을 확인해주세요.",
        );
      }
    } on CustomException {
      rethrow;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'invalid-credential':
          throw const CustomException(
            title: '로그인',
            message: '이메일과 비밀번호를 다시 확인해주세요.',
          );
        case 'user-disabled':
          throw const CustomException(
            title: '로그인',
            message: '비활성화된 계정입니다.\n문의: devmoichi@gmail.com',
          );
        default:
          throw const CustomException(
            title: '로그인',
            message: '로그인에 실패했습니다.\n다시 시도해주세요.',
          );
      }
    } catch (_) {
      throw const CustomException(
        title: "로그인",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;
      final String providerId = userCredential.user!.providerData[0].providerId;

      await userCredential.user!.sendEmailVerification();

      final String nickname = await generateRandomNickname();

      await _createUserDocument(
        uid: uid,
        email: email,
        providerId: providerId,
        nickname: nickname,
      );

      await _firebaseAuth.signOut();
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw const CustomException(
            title: '회원가입',
            message: '이미 사용 중인 이메일입니다.\n다른 이메일을 입력해주세요.',
          );
        case 'network-request-failed':
          throw const CustomException(
            title: '네트워크 오류',
            message: '네트워크 연결상태를 확인해주세요.',
          );
        default:
          throw const CustomException(
            title: "회원가입",
            message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
          );
      }
    } catch (_) {
      throw const CustomException(
        title: "회원가입",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw const CustomException(
          title: "구글 로그인",
          message: "구글 로그인에 실패했습니다.\n다시 시도해주세요.",
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User user = userCredential.user!;

      await _createUserDocumentIfNotExists(user);
    } on CustomException {
      rethrow;
    } on FirebaseException {
      throw const CustomException(
        title: '구글 로그인',
        message: '구글 로그인에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "구글 로그인",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> signInWithApple() async {
    try {
      final AppleAuthProvider appleProvider = AppleAuthProvider();
      final UserCredential userCredential = await _firebaseAuth.signInWithProvider(appleProvider);
      final User user = userCredential.user!;

      await _createUserDocumentIfNotExists(user);
    } on FirebaseException {
      throw const CustomException(
        title: '애플 로그인',
        message: '애플 로그인에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "애플 로그인",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  // Private helper methods

  Future<void> _reauthenticateUser(User user, String provider, String? password) async {
    switch (provider) {
      case 'password':
        if (password == null) {
          throw const CustomException(
            title: '회원탈퇴',
            message: '비밀번호가 필요합니다.',
          );
        }

        try {
          final AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
        } on FirebaseException catch (e) {
          if (e.code == 'invalid-credential') {
            throw const CustomException(
              title: '회원탈퇴',
              message: '잘못된 비밀번호입니다. 다시 입력해주세요.',
            );
          }
          throw const CustomException(
            title: '회원탈퇴',
            message: '회원탈퇴에 실패했습니다.\n다시 시도해주세요.',
          );
        }
        break;

      case 'google.com':
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          throw const CustomException(
            title: '회원탈퇴',
            message: '구글 로그인에 실패했습니다.\n다시 시도해주세요.',
          );
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
        break;

      case 'apple.com':
        final AppleAuthProvider appleProvider = AppleAuthProvider();
        await user.reauthenticateWithProvider(appleProvider);
        break;
    }
  }

  Future<void> _deleteProfileImage(String uid) async {
    try {
      await _firebaseStorage.ref().child('profile/$uid').delete();
    } catch (_) {
      // 프로필 이미지가 없어도 무시
    }
  }

  Future<void> _deletePets(QuerySnapshot<Map<String, dynamic>> snapshot, WriteBatch batch) async {
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);

      try {
        final String petImageUrl = doc.data()['image'];
        if (petImageUrl.isNotEmpty) {
          await _firebaseStorage.refFromURL(petImageUrl).delete();
        }
      } catch (_) {
        // 이미지 삭제 실패해도 계속 진행
      }
    }
  }

  Future<void> _deleteDiaries(
      QuerySnapshot<Map<String, dynamic>> snapshot, WriteBatch batch) async {
    for (final doc in snapshot.docs) {
      final List<String> likes = List<String>.from(doc.data()['likes'] ?? []);

      // 좋아요 누른 사용자들의 likes 필드에서 해당 일기 ID 제거
      for (final likeUid in likes) {
        batch.update(_firebaseFirestore.collection('users').doc(likeUid), {
          'likes': FieldValue.arrayRemove([doc.id]),
        });
      }

      batch.delete(doc.reference);

      // 이미지들 삭제
      final List<String> imageUrls = List<String>.from(doc.data()['imageUrls'] ?? []);
      await _deleteStorageFiles(imageUrls);
    }
  }

  Future<void> _deleteMedicals(
      QuerySnapshot<Map<String, dynamic>> snapshot, WriteBatch batch) async {
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);

      final List<String> imageUrls = List<String>.from(doc.data()['imageUrls'] ?? []);
      await _deleteStorageFiles(imageUrls);
    }
  }

  Future<void> _deleteWalks(QuerySnapshot<Map<String, dynamic>> snapshot, WriteBatch batch) async {
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);

      try {
        final String walkImageUrl = doc.data()['mapImageUrl'];
        if (walkImageUrl.isNotEmpty) {
          await _firebaseStorage.refFromURL(walkImageUrl).delete();
        }
      } catch (_) {
        // 이미지 삭제 실패해도 계속 진행
      }
    }
  }

  Future<void> _deleteStorageFiles(List<String> imageUrls) async {
    await Future.wait(
      imageUrls.map((imageUrl) async {
        try {
          if (imageUrl.isNotEmpty) {
            await _firebaseStorage.refFromURL(imageUrl).delete();
          }
        } catch (_) {
          // 이미지 삭제 실패해도 계속 진행
        }
      }),
    );
  }

  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String providerId,
    required String nickname,
  }) async {
    await _firebaseFirestore.collection("users").doc(uid).set({
      "uid": uid,
      "email": email,
      "profileImage": null,
      "providerId": providerId,
      "nickname": nickname,
      "walkCount": 0,
      "diaryCount": 0,
      "medicalCount": 0,
      "likes": [],
      "blocks": [],
      "createdAt": Timestamp.now(),
    });
  }

  Future<void> _createUserDocumentIfNotExists(User user) async {
    final DocumentSnapshot userDoc =
        await _firebaseFirestore.collection("users").doc(user.uid).get();

    if (!userDoc.exists) {
      final String nickname = await generateRandomNickname();

      await _firebaseFirestore.collection("users").doc(user.uid).set({
        "uid": user.uid,
        "email": user.providerData[0].email,
        "profileImage": null,
        "providerId": user.providerData[0].providerId,
        "nickname": nickname,
        "walkCount": 0,
        "diaryCount": 0,
        "medicalCount": 0,
        "likes": [],
        "blocks": [],
        "createdAt": Timestamp.now(),
      });
    }
  }
}
