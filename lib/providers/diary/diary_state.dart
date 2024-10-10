import 'package:pet_log/models/diary_model.dart';

enum DiaryStatus {
  init, // DiaryState를 최초로 객체 생성한 상태
  submitting, // 게시글을 등록하는 중인 상태
  fetching, // 가져오는 중인 상태
  success, // 작업이 성공한 상태
  error, // 작업이 실패한 상태
}

class DiaryState {
  final DiaryStatus diaryStatus;
  final List<DiaryModel> diaryList;

  const DiaryState({
    required this.diaryStatus,
    required this.diaryList,
  });

  factory DiaryState.init() {
    return DiaryState(
      diaryStatus: DiaryStatus.init,
      diaryList: [],
    );
  }

  DiaryState copyWith({
    DiaryStatus? diaryStatus,
    List<DiaryModel>? diaryList,
  }) {
    return DiaryState(
      diaryStatus: diaryStatus ?? this.diaryStatus,
      diaryList: diaryList ?? this.diaryList,
    );
  }
}
