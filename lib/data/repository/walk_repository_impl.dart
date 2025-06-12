import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../exceptions/custom_exception.dart';
import '../../domain/model/pet_model.dart';
import '../../domain/model/user_model.dart';
import '../../domain/model/walk_model.dart';
import '../../domain/repository/walk_repository.dart';

class WalkRepositoryImpl implements WalkRepository {
  final FirebaseStorage _firebaseStorage;
  final FirebaseFirestore _firebaseFirestore;

  const WalkRepositoryImpl({
    required FirebaseStorage firebaseStorage,
    required FirebaseFirestore firebaseFirestore,
  })  : _firebaseStorage = firebaseStorage,
        _firebaseFirestore = firebaseFirestore;

  @override
  Future<WalkModel> uploadWalk({
    required String uid,
    required Uint8List mapImage,
    required String distance,
    required String duration,
    required List<String> petIds,
  }) async {
    late String mapImageUrl;

    try {
      WriteBatch batch = _firebaseFirestore.batch();
      String walkId = const Uuid().v1();

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> userDocRef =
          _firebaseFirestore.collection("users").doc(uid);

      DocumentReference<Map<String, dynamic>> walkDocRef =
          _firebaseFirestore.collection("walks").doc(walkId);

      // Firestore Storage에 지도 이미지 업로드
      Reference ref = _firebaseStorage.ref().child("walks").child(walkId);
      TaskSnapshot taskSnapshot = await ref.putData(mapImage);
      mapImageUrl = await taskSnapshot.ref.getDownloadURL();

      // 유저 모델 생성
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await userDocRef.get();
      UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

      // 펫 모델 생성
      List<DocumentReference<Map<String, dynamic>>> petDocRefs = [];
      List<PetModel> petModels = [];

      for (String petId in petIds) {
        DocumentReference<Map<String, dynamic>> petDocRef =
            _firebaseFirestore.collection("pets").doc(petId);
        petDocRefs.add(petDocRef);

        DocumentSnapshot<Map<String, dynamic>> petSnapshot = await petDocRef.get();
        petModels.add(PetModel.fromMap(petSnapshot.data()!));
      }

      WalkModel walkModel = WalkModel(
        uid: uid,
        walkId: walkId,
        distance: distance,
        duration: duration,
        mapImageUrl: mapImageUrl,
        pets: petModels,
        writer: userModel,
        createdAt: Timestamp.now(),
      );

      // Firestore에 산책 데이터 추가
      batch.set(
        walkDocRef,
        walkModel.toMap(
          petDocRefs: petDocRefs,
          userDocRef: userDocRef,
        ),
      );

      // 사용자의 산책 횟수 증가
      batch.update(userDocRef, {
        "walkCount": FieldValue.increment(1),
      });

      await batch.commit();
      return walkModel;
    } on FirebaseException {
      await _deleteImage(mapImageUrl);

      throw const CustomException(
        title: '산책',
        message: '산책 삭제하기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      await _deleteImage(mapImageUrl);

      throw const CustomException(
        title: "산책",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<List<WalkModel>> getWalkList({
    required String uid,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firebaseFirestore
          .collection('walks')
          .where('uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .get();

      return await Future.wait(snapshot.docs.map(
        (doc) async {
          Map<String, dynamic> data = doc.data();

          // pets 필드 처리
          List<PetModel> pets = await Future.wait(
            (data['pets'] as List<dynamic>).map((petRef) async {
              DocumentSnapshot petSnapshot = await (petRef as DocumentReference).get();
              return PetModel.fromMap(petSnapshot.data() as Map<String, dynamic>);
            }),
          );
          data['pets'] = pets;

          // writer 필드 처리
          DocumentReference writerDocRef = data['writer'];
          DocumentSnapshot writerSnapshot = await writerDocRef.get();
          data['writer'] = UserModel.fromMap(writerSnapshot.data() as Map<String, dynamic>);

          return WalkModel.fromMap(data);
        },
      ).toList());
    } on FirebaseException {
      throw const CustomException(
        title: '산책',
        message: '산책 가져오기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "산책",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  @override
  Future<void> deleteWalk({
    required WalkModel walkModel,
  }) async {
    try {
      WriteBatch batch = _firebaseFirestore.batch();

      DocumentReference<Map<String, dynamic>> walksDocRef =
          _firebaseFirestore.collection('walks').doc(walkModel.walkId);
      DocumentReference<Map<String, dynamic>> writerDocRef =
          _firebaseFirestore.collection('users').doc(walkModel.uid);

      // diaries 컬렉션에서 문서 삭제
      batch.delete(walksDocRef);

      // 작성자의 users 문서에서 walkCount 1 감소
      batch.update(writerDocRef, {
        'walkCount': FieldValue.increment(-1),
      });

      await batch.commit();

      // storage 이미지 삭제
      await _firebaseStorage.ref('walks/${walkModel.walkId}').delete();
    } on FirebaseException {
      throw const CustomException(
        title: '산책',
        message: '산책 삭제하기에 실패했습니다.\n다시 시도해주세요.',
      );
    } catch (_) {
      throw const CustomException(
        title: "산책",
        message: "알 수 없는 오류가 발생했습니다.\n다시 시도해주세요.\n문의: devmoichi@gmail.com",
      );
    }
  }

  /// 이미지 삭제 함수
  Future<void> _deleteImage(String imageUrl) async {
    try {
      await _firebaseStorage.refFromURL(imageUrl).delete();
    } catch (e) {
      print('Failed to delete image: $imageUrl, error: $e');
    }
  }
}
