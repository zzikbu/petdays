import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/pet_model.dart';
import 'package:pet_log/models/walk_model.dart';
import 'package:uuid/uuid.dart';

class WalkRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const WalkRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  // 산책 업로드
  Future<WalkModel> uploadWalk({
    required String uid,
    required Uint8List mapImage,
    required String distance,
    required String duration,
    required String petId,
  }) async {
    late String mapImageUrl;

    try {
      WriteBatch batch = firebaseFirestore.batch();
      String walkId = Uuid().v1();

      // firestore 문서 참조
      DocumentReference<Map<String, dynamic>> userDocRef =
          firebaseFirestore.collection("users").doc(uid);

      DocumentReference<Map<String, dynamic>> walkDocRef =
          firebaseFirestore.collection("walks").doc(walkId);

      DocumentReference<Map<String, dynamic>> petDocRef =
          firebaseFirestore.collection("pets").doc(petId);

      // firestorage에 이미지 업로드
      Reference ref = firebaseStorage.ref().child("walks").child(walkId);
      TaskSnapshot taskSnapshot = await ref.putData(mapImage);
      mapImageUrl = await taskSnapshot.ref.getDownloadURL();

      // 펫 모델 생성
      DocumentSnapshot<Map<String, dynamic>> petSnapshot =
          await petDocRef.get();
      PetModel petModel = PetModel.fromMap(petSnapshot.data()!);

      WalkModel walkModel = WalkModel.fromMap({
        'uid': uid,
        'walkId': walkId,
        'distance': distance,
        'duration': duration,
        'mapImageUrl': mapImageUrl,
        'pet': petModel,
        'createAt': Timestamp.now()
      });

      // walks 컬렉션에 데이터 추가
      batch.set(
        walkDocRef,
        walkModel.toMap(
          petDocRef: petDocRef,
        ),
      );

      // 유저의 산책 카운트 증가
      batch.update(userDocRef, {
        "walkCount": FieldValue.increment(1),
      });

      // 배치 작업 실행
      await batch.commit();
      return walkModel;
    } on FirebaseException catch (e) {
      // 에러 발생시 store에 등록된 이미지 삭제
      await _deleteImage(mapImageUrl);

      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      // 에러 발생시 store에 등록된 이미지 삭제
      await _deleteImage(mapImageUrl);

      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }

  // 이미지 삭제 함수
  Future<void> _deleteImage(String imageUrl) async {
    await firebaseStorage.refFromURL(imageUrl).delete();
  }
}
