import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/components/custom_dialog.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/components/next_button.dart';
import 'package:pet_log/components/textfield_with_title.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/palette.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_log/providers/diary/diary_provider.dart';
import 'package:pet_log/providers/diary/diary_state.dart';
import 'package:provider/provider.dart';

class DiaryUploadScreen extends StatefulWidget {
  final bool isEditMode;

  const DiaryUploadScreen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<DiaryUploadScreen> createState() => _DiaryUploadScreenState();
}

class _DiaryUploadScreenState extends State<DiaryUploadScreen> {
  final TextEditingController _titleTEC = TextEditingController();
  final TextEditingController _descTEC = TextEditingController();

  final List<String> _files = [];

  bool _isLock = true; // 성장일기 공개 여부
  bool _isActive = false; // 작성하기 버튼 활성화 여부

  void _lockTap() {
    setState(() {
      _isLock = !_isLock;
      Navigator.pop(context);
    });
  }

  void _checkBottomActive() {
    setState(() {
      _isActive = _files.isNotEmpty &&
          _titleTEC.text.isNotEmpty &&
          _descTEC.text.isNotEmpty;
    });
  }

  Future<List<String>> selectImages() async {
    List<XFile> images = await ImagePicker().pickMultiImage(
      maxHeight: 1024,
      maxWidth: 1024,
    ); // 여러 장

    return images.map((e) => e.path).toList(); // XFile.path를 갖는 문자열 리스트
  }

  List<Widget> selectedImageList() {
    final diaryStatus = context.watch<DiaryState>().diaryStatus;

    return _files.map((data) {
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(data),
                fit: BoxFit.cover,
                height: 80,
                width: 80,
              ),
            ),
            Positioned(
              // 이미지 삭제 버튼
              top: 4,
              right: 4,
              child: InkWell(
                onTap: diaryStatus == DiaryStatus.submitting
                    ? null // 작성 중일때 버튼 막기
                    : () {
                        setState(() {
                          _files.remove(data); // 사진 삭제
                          _checkBottomActive();
                        });
                      },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  height: 24,
                  width: 24,
                  child: Icon(
                    color: Colors.black.withOpacity(0.6),
                    size: 24,
                    Icons.highlight_remove_outlined,
                  ),
                ),
              ),
            )
          ],
        ),
      );
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    _titleTEC.addListener(_checkBottomActive);
    _descTEC.addListener(_checkBottomActive);
  }

  @override
  void dispose() {
    _titleTEC.removeListener(_checkBottomActive);
    _titleTEC.removeListener(_checkBottomActive);

    _titleTEC.dispose();
    _descTEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final diaryStatus = context.watch<DiaryState>().diaryStatus;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 다른 곳 클릭 시 키보드 내리기
      child: Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Palette.background,
          title: Text(
            "성장일기",
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Palette.black,
              letterSpacing: -0.5,
            ),
          ),
          actions: !widget.isEditMode
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () {
                        if (_isLock) {
                          // 비공개 -> 공개
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                title: '성장일기 공개',
                                message: '성장일기를 공개하면 피드에 게시됩니다.\n변경하시겠습니까?',
                                onConfirm: () {
                                  _lockTap();
                                },
                              );
                            },
                          );
                        } else {
                          // 공개 -> 비공개
                          // _isLock이 false일 때 바로 _lockTap() 호출
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                title: '성장일기 비공개',
                                message: '성장일기를 비공개하면 피드에서 삭제됩니다.\n변경하시겠습니까?',
                                onConfirm: () {
                                  _lockTap();
                                },
                              );
                            },
                          );
                        }
                      },
                      child: _isLock
                          ? SvgPicture.asset('assets/icons/ic_lock.svg')
                          : SvgPicture.asset('assets/icons/ic_unlock.svg'),
                    ),
                  ),
                ]
              : [],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: diaryStatus == DiaryStatus.submitting ? null : 1,
              backgroundColor: Colors.transparent,
              color: diaryStatus == DiaryStatus.submitting
                  ? Palette.subGreen
                  : Colors.transparent,
            ),
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),

                      // 사진
                      Text(
                        '사진',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Palette.black,
                          letterSpacing: -0.45,
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // 이미지 추가 버튼
                            GestureDetector(
                              onTap: () async {
                                final _images = await selectImages();
                                setState(() {
                                  _files.addAll(_images);
                                  _checkBottomActive();
                                });
                              },
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Palette.lightGray,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Palette.lightGray,
                                ),
                              ),
                            ),
                            ...selectedImageList(),
                          ],
                        ),
                      ),
                      SizedBox(height: 40),

                      // 제목
                      TextFieldWithTitle(
                        controller: _titleTEC,
                        labelText: '제목',
                        hintText: '제목을 입력해주세요',
                      ),
                      SizedBox(height: 40),

                      // 내용
                      TextFieldWithTitle(
                        controller: _descTEC,
                        isMultiLine: true,
                        labelText: '내용',
                        hintText: '내용을 입력해주세요',
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: NextButton(
          isActive: _isActive,
          onTap: () async {
            try {
              // 버튼 비활성화
              setState(() {
                _isActive = false;
              });

              // 성장일기 업로드 로직
              await context.read<DiaryProvider>().uploadDiary(
                    files: _files,
                    title: _titleTEC.text,
                    desc: _descTEC.text,
                    isLock: _isLock,
                  );

              // 스낵바
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("작성 완료")));

              Navigator.pop(context);
            } on CustomException catch (e) {
              errorDialogWidget(context, e);

              // 에러 발생시 버튼 재활성화
              setState(() {
                _isActive = true;
              });
            }
          },
          buttonText: widget.isEditMode ? "수정하기" : "작성하기",
        ),
      ),
    );
  }
}
