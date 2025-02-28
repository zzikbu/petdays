import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petdays/exceptions/custom_exception.dart';

class AuthRepository {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final FirebaseStorage firebaseStorage;

  AuthRepository({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.firebaseStorage,
  });

  /// 랜덤 닉네임 생성
  Future<String> randomNickname() async {
    // 감정 리스트
    List<String> emotions = [
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
    List<String> animals = [
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

    String generatedNickname = "";
    bool isUnique = false;

    CollectionReference<Map<String, dynamic>> userCollection =
        firebaseFirestore.collection("users");

    // 중복되지 않는 닉네임이 생성될 때까지 반복
    while (!isUnique) {
      String randomEmotion = emotions[Random().nextInt(emotions.length)];
      String randomAnimal = animals[Random().nextInt(animals.length)];
      int randomNumber = Random().nextInt(1000); // 0부터 999까지의 랜덤 숫자

      generatedNickname = '$randomEmotion$randomAnimal$randomNumber';

      // 닉네임 중복 확인
      QuerySnapshot querySnapshot =
          await userCollection.where('nickname', isEqualTo: generatedNickname).get();

      if (querySnapshot.docs.isEmpty) {
        isUnique = true; // 중복되지 않는 닉네임이 발견되면 루프 탈출
      }
    }

    return generatedNickname;
  }

  /// 비밀번호 재설정 이메일 전송
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
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

  /// 회원 탈퇴
  Future<void> deleteAccount({
    String? password,
  }) async {
    try {
      final User user = firebaseAuth.currentUser!;
      final String uid = user.uid;
      final provider = user.providerData[0].providerId;

      switch (provider) {
        // 이메일 재인증
        case 'password':
          try {
            AuthCredential credential = EmailAuthProvider.credential(
              email: user.email!,
              password: password!,
            );
            await user.reauthenticateWithCredential(credential);
          } on FirebaseException catch (e) {
            switch (e.code) {
              case 'invalid-credential':
                throw const CustomException(
                  title: '회원탈퇴',
                  message: '잘못된 비밀번호입니다. 다시 입력해주세요.',
                );
              default:
                throw const CustomException(
                  title: '회원탈퇴',
                  message: '회원탈퇴에 실패했습니다.\n다시 시도해주세요.',
                );
            }
          } on CustomException {
            rethrow;
          } catch (e) {
            throw const CustomException(
              title: "회원탈퇴",
              message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
            );
          }
          break;

        // 구글 재인증
        case 'google.com':
          try {
            final googleUser = await GoogleSignIn().signIn();

            if (googleUser == null) {
              throw const CustomException(
                title: '회원탈퇴',
                message: '구글 로그인에 실패했습니다.\n다시 시도해주세요.',
              );
            }

            final googleAuth = await googleUser.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );

            await user.reauthenticateWithCredential(credential);
          } on CustomException {
            rethrow;
          } on FirebaseException {
            throw const CustomException(
              title: '회원탈퇴',
              message: '구글 로그인에 실패했습니다.\n다시 시도해주세요.',
            );
          } catch (_) {
            throw const CustomException(
              title: "회원탈퇴",
              message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
            );
          }
          break;

        // 애플 재인증
        case 'apple.com':
          try {
            final appleProvider = AppleAuthProvider();
            await user.reauthenticateWithProvider(appleProvider);
          } on FirebaseException {
            throw const CustomException(
              title: '회원탈퇴',
              message: '애플 로그인에 실패했습니다.\n다시 시도해주세요.',
            );
          } catch (_) {
            throw const CustomException(
              title: "회원탈퇴",
              message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
            );
          }
          break;
      }

      // 탈퇴
      await user.delete();

      QuerySnapshot<Map<String, dynamic>> petQuerySnapshot =
          await firebaseFirestore.collection('pets').where('uid', isEqualTo: uid).get();

      QuerySnapshot<Map<String, dynamic>> diaryQuerySnapshot =
          await firebaseFirestore.collection('diaries').where('uid', isEqualTo: uid).get();

      QuerySnapshot<Map<String, dynamic>> medicalQuerySnapshot =
          await firebaseFirestore.collection('medicals').where('uid', isEqualTo: uid).get();

      QuerySnapshot<Map<String, dynamic>> walkQuerySnapshot =
          await firebaseFirestore.collection('walks').where('uid', isEqualTo: uid).get();

      WriteBatch batch = firebaseFirestore.batch();

      // users 컬렉션에서 해당 uid 문서 삭제
      batch.delete(firebaseFirestore.collection('users').doc(uid));

      // 프로필 이미지 삭제
      if (await firebaseStorage
          .ref()
          .child('profile/$uid')
          .getDownloadURL()
          .then((_) => true)
          .catchError((_) => false)) {
        await firebaseStorage.ref().child('profile/$uid').delete();
      }

      // 펫 삭제
      petQuerySnapshot.docs.forEach((petDoc) async {
        batch.delete(petDoc.reference);

        String petImageUrl = petDoc.data()['image'];
        await firebaseStorage.refFromURL(petImageUrl).delete();
      });

      // 성장일기 삭제
      // 해당 성장일기에 좋아요 누른 users 문서의 likes 필드에서 diaryId 삭제
      diaryQuerySnapshot.docs.forEach((diaryDoc) async {
        List<String> likes = List<String>.from(diaryDoc.data()['likes']);

        for (var likeUid in likes) {
          batch.update(firebaseFirestore.collection('users').doc(likeUid), {
            'likes': FieldValue.arrayRemove([diaryDoc.id]),
          });
        }

        batch.delete(diaryDoc.reference);

        List<String> diaryImageUrls = List<String>.from(diaryDoc.data()['imageUrls']);
        diaryImageUrls.forEach((element) async {
          await firebaseStorage.refFromURL(element).delete();
        });
      });

      // 진료기록 삭제
      medicalQuerySnapshot.docs.forEach((medicalDoc) async {
        batch.delete(medicalDoc.reference);

        List<String> medicalImageUrls = List<String>.from(medicalDoc.data()['imageUrls']);
        medicalImageUrls.forEach((element) async {
          await firebaseStorage.refFromURL(element).delete();
        });
      });

      // 산책 삭제
      walkQuerySnapshot.docs.forEach((walkDoc) async {
        batch.delete(walkDoc.reference);

        String walkImageUrl = walkDoc.data()['mapImageUrl'];
        await firebaseStorage.refFromURL(walkImageUrl).delete();
      });

      await batch.commit();
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

  /// 로그아웃
  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut(); // 구글 로그아웃
      }

      await firebaseAuth.signOut();
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

  /// 이메일 로그인
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      bool isVerified = userCredential.user!.emailVerified;

      if (!isVerified) {
        await userCredential.user!.sendEmailVerification();
        await firebaseAuth.signOut();

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
    } catch (e) {
      throw const CustomException(
        title: "로그인",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  /// 이메일 회원가입
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 회원가입과 동시에 로그인이 됨
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      String providerId = userCredential.user!.providerData[0].providerId;

      await userCredential.user!.sendEmailVerification(); // 인증 메일 보내기

      String nickname = await randomNickname();

      // uid를 문서 ID로 설정 후 파이어스토어에 저장
      await firebaseFirestore.collection("users").doc(uid).set({
        "uid": uid,
        "email": email,
        "profileImage": null,
        "providerId": providerId,
        "nickname": nickname,
        "walkCount": 0,
        "diaryCount": 0,
        "medicalCount": 0,
        "likes": [], // 좋아요한 글
        "blocks": [], // 차단한 멤버 uid
        "createdAt": Timestamp.now(),
      });

      firebaseAuth.signOut(); // 회원가입과 동시에 로그인이 되기 때문에 로그아웃 (메일 인증 전)
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
      }
    } catch (e) {
      throw const CustomException(
        title: "회원가입",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  /// 구글 로그인
  Future<void> signInWithGoogle() async {
    try {
      // 구글 로그인 진행
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        throw const CustomException(
          title: "구글 로그인",
          message: "구글 로그인에 실패했습니다.\n다시 시도해주세요.",
        );
      }

      // 구글 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 구글 인증 정보로 Firebase 인증 정보 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase 인증
      final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
      final User user = userCredential.user!;

      // Firestore에서 사용자 정보 확인
      final userDoc = await firebaseFirestore.collection("users").doc(user.uid).get();

      // 신규 사용자인 경우 Firestore에 사용자 정보 저장
      if (!userDoc.exists) {
        String nickname = await randomNickname();

        await firebaseFirestore.collection("users").doc(user.uid).set({
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

  /// 애플 로그인
  Future<void> signInWithApple() async {
    try {
      final appleProvider = AppleAuthProvider();

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithProvider(appleProvider);

      final User user = userCredential.user!;

      final userDoc = await firebaseFirestore.collection("users").doc(user.uid).get();

      // 신규 사용자인 경우 Firestore에 사용자 정보 저장
      if (!userDoc.exists) {
        String nickname = await randomNickname();

        await firebaseFirestore.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "email": null,
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
}
