import 'package:firebase_auth/firebase_auth.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/providers/diary/diary_state.dart';
import 'package:pet_log/repositories/diary_repository.dart';
import 'package:state_notifier/state_notifier.dart';

class DiaryProvider extends StateNotifier<DiaryState> with LocatorMixin {
  // DiaryProvider 만들어질 때 DiaryState도 같이 만들기
  DiaryProvider() : super(DiaryState.init());

  Future<void> uploadDiary({
    required List<String> files, // 이미지들
    required String title, // 제목
    required String desc, // 내용
    required bool isLock, // 공개여부
  }) async {
    try {
      state = state.copyWith(
          diaryStatus: DiaryStatus.submitting); // 게시글을 등록하는 중인 상태로 변경

      print(state);

      String uid = read<User>().uid; // 작성자

      await read<DiaryRepository>().uploadDiary(
        files: files,
        desc: desc,
        uid: uid,
        title: title,
        isLock: isLock,
      );

      state = state.copyWith(diaryStatus: DiaryStatus.success); // 등록 완료 상태로 변경
    } on CustomException catch (_) {
      state = state.copyWith(
          diaryStatus: DiaryStatus.error); // 문제가 생기면 error로 상태 변경
      rethrow; // 호출한 곳에다가 다시 rethrow
    }
  }
}
