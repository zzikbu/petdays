import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/diary_model.dart';
import 'package:pet_log/models/user_model.dart';

class LikeRepository {
  final FirebaseFirestore firebaseFirestore;

  const LikeRepository({
    required this.firebaseFirestore,
  });

  Future<List<DiaryModel>> getLikeList({
    required String uid,
  }) async {
    try {
      Map<String, dynamic> userMapData = await firebaseFirestore
          .collection('users')
          .doc(uid)
          .get()
          .then((value) => value.data()!);

      List<String> likes = List<String>.from(userMapData['likes']);

      List<DiaryModel> diaryList = await Future.wait(likes.map((diaryId) async {
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await firebaseFirestore.collection('diaries').doc(diaryId).get();
        Map<String, dynamic> diaryMapData = documentSnapshot.data()!;
        DocumentReference<Map<String, dynamic>> userDocRef =
            diaryMapData['writer'];
        Map<String, dynamic> writerMapData =
            await userDocRef.get().then((value) => value.data()!);
        diaryMapData['writer'] = UserModel.fromMap(writerMapData);
        return DiaryModel.fromMap(diaryMapData);
      }).toList());
      return diaryList;
    } catch (e) {
      // 호출한 곳에서 처리하게 throw
      throw CustomException(
        code: "Exception",
        message: e.toString(),
      );
    }
  }
}
