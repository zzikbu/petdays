import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/pet_model.dart';
import 'package:petdays/models/user_model.dart';
import 'package:petdays/models/walk_model.dart';
import 'package:uuid/uuid.dart';

class WalkRepository {
  final FirebaseStorage firebaseStorage;
  final FirebaseFirestore firebaseFirestore;

  const WalkRepository({
    required this.firebaseStorage,
    required this.firebaseFirestore,
  });

  // 산책 삭제
  Future<void> deleteWalk({
    required WalkModel walkModel,
  }) async {
    try {
      WriteBatch batch = firebaseFirestore.batch();

      DocumentReference<Map<String, dynamic>> walksDocRef =
          firebaseFirestore.collection('walks').doc(walkModel.walkId);
      DocumentReference<Map<String, dynamic>> writerDocRef =
          firebaseFirestore.collection('users').doc(walkModel.uid);

      // diaries 컬렉션에서 문서 삭제
      batch.delete(walksDocRef);

      // 작성자의 users 문서에서 walkCount 1 감소
      batch.update(writerDocRef, {
        'walkCount': FieldValue.increment(-1),
      });

      batch.commit();

      // storage 이미지 삭제
      await firebaseStorage.ref('walks/${walkModel.walkId}').delete();
    } on FirebaseException catch (e) {
      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }

  // 산책 기록 가져오기
  Future<List<WalkModel>> getWalkList({
    required String uid,
  }) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await firebaseFirestore
          .collection('walks')
          .where('uid', isEqualTo: uid)
          .orderBy('createAt', descending: true)
          .get();

      return await Future.wait(snapshot.docs.map(
        (doc) async {
          Map<String, dynamic> data = doc.data();

          // pets 필드 처리
          List<PetModel> pets = await Future.wait(
            (data['pets'] as List<dynamic>).map((petRef) async {
              DocumentSnapshot petSnapshot =
                  await (petRef as DocumentReference).get();
              return PetModel.fromMap(
                  petSnapshot.data() as Map<String, dynamic>);
            }),
          );
          data['pets'] = pets;

          // writer 필드 처리
          DocumentReference writerDocRef = data['writer'];
          DocumentSnapshot writerSnapshot = await writerDocRef.get();
          data['writer'] =
              UserModel.fromMap(writerSnapshot.data() as Map<String, dynamic>);

          return WalkModel.fromMap(data);
        },
      ).toList());
    } on FirebaseException catch (e) {
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }

  // 산책 업로드
  Future<WalkModel> uploadWalk({
    required String uid,
    required Uint8List mapImage,
    required String distance,
    required String duration,
    required List<String> petIds,
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

      // Firestore Storage에 지도 이미지 업로드
      Reference ref = firebaseStorage.ref().child("walks").child(walkId);
      TaskSnapshot taskSnapshot = await ref.putData(mapImage);
      mapImageUrl = await taskSnapshot.ref.getDownloadURL();

      // 유저 모델 생성
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await userDocRef.get();
      UserModel userModel = UserModel.fromMap(userSnapshot.data()!);

      // 펫 모델 생성
      List<DocumentReference<Map<String, dynamic>>> petDocRefs = [];
      List<PetModel> petModels = [];

      for (String petId in petIds) {
        DocumentReference<Map<String, dynamic>> petDocRef =
            firebaseFirestore.collection("pets").doc(petId);
        petDocRefs.add(petDocRef);

        DocumentSnapshot<Map<String, dynamic>> petSnapshot =
            await petDocRef.get();
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
        createAt: Timestamp.now(),
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
    } on FirebaseException catch (e) {
      await _deleteImage(mapImageUrl);
      throw CustomException(
        code: e.code,
        message: e.message!,
      );
    } catch (e) {
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
