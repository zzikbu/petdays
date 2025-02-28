import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/pd_app_bar.dart';
import '../../common/widgets/w_bottom_confirm_button.dart';
import '../../common/widgets/show_custom_dialog.dart';
import '../../common/widgets/show_error_dialog.dart';
import '../../common/widgets/w_textfield_with_title.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/diary_model.dart';
import '../../palette.dart';
import '../../providers/diary/diary_provider.dart';
import '../../providers/diary/diary_state.dart';
import '../../providers/feed/feed_provider.dart';
import '../../providers/like/like_provider.dart';
import '../../utils/permission_utils.dart';

class DiaryUploadScreen extends StatefulWidget {
  final bool isEditMode;
  final DiaryModel? originalDiaryModel;

  const DiaryUploadScreen({
    super.key,
    this.isEditMode = false,
    this.originalDiaryModel,
  });

  @override
  State<DiaryUploadScreen> createState() => _DiaryUploadScreenState();
}

class _DiaryUploadScreenState extends State<DiaryUploadScreen> {
  final TextEditingController _titleTEC = TextEditingController();
  final TextEditingController _descTEC = TextEditingController();

  final List<String> _files = []; // 새로 추가할 이미지 파일들
  final List<String> _remainImageUrls = []; // 유지할 기존 이미지 URLs
  final List<String> _deleteImageUrls = []; // 삭제할 기존 이미지 URLs

  bool _isLock = true;
  bool _isActive = false;

  void _lockTap() {
    setState(() {
      _isLock = !_isLock;
      Navigator.pop(context);
    });
  }

  void _checkBottomActive() {
    setState(() {
      // 수정 모드일 때는 기존 이미지나 새 이미지가 하나라도 있으면 활성화
      bool hasImages = widget.isEditMode
          ? (_remainImageUrls.isNotEmpty || _files.isNotEmpty)
          : _files.isNotEmpty;

      _isActive = hasImages && _titleTEC.text.isNotEmpty && _descTEC.text.isNotEmpty;
    });
  }

  Future<List<String>> selectImages() async {
    final hasPermission = await PermissionUtils.checkPhotoPermission(context);
    if (!hasPermission) return [];

    List<XFile> images = await ImagePicker().pickMultiImage(
      maxHeight: 1024,
      maxWidth: 1024,
    ); // 여러 장

    return images.map((e) => e.path).toList(); // XFile.path를 갖는 문자열 리스트
  }

  List<Widget> selectedImageList() {
    final diaryStatus = context.watch<DiaryState>().diaryStatus;
    List<Widget> imageWidgets = [];

    // 기존 이미지 표시
    for (String imageUrl in _remainImageUrls) {
      imageWidgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: diaryStatus == DiaryStatus.submitting
                      ? null
                      : () {
                          setState(() {
                            _remainImageUrls.remove(imageUrl);
                            _deleteImageUrls.add(imageUrl);
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
        ),
      );
    }

    // 새로 선택한 이미지 표시
    for (String file in _files) {
      imageWidgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(file),
                  fit: BoxFit.cover,
                  height: 80,
                  width: 80,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: InkWell(
                  onTap: diaryStatus == DiaryStatus.submitting
                      ? null
                      : () {
                          setState(() {
                            _files.remove(file);
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
        ),
      );
    }

    return imageWidgets;
  }

  @override
  void initState() {
    super.initState();

    // 수정 모드일 때 초기값 설정
    if (widget.isEditMode && widget.originalDiaryModel != null) {
      _titleTEC.text = widget.originalDiaryModel!.title;
      _descTEC.text = widget.originalDiaryModel!.desc;
      _isLock = widget.originalDiaryModel!.isLock;

      // 기존 이미지 URLs를 유지할 이미지 목록에 추가
      _remainImageUrls.addAll(widget.originalDiaryModel!.imageUrls);
    }

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
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Palette.background,
        appBar: PDAppBar(
          titleText: '성장일기',
          actions: [
            if (!widget.isEditMode) // 성장일기 업로드 일 때
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    if (_isLock) {
                      showCustomDialog(
                        context: context,
                        title: '성장일기 공개',
                        message: '성장일기를 공개하면 피드에 게시되고,\n업로드 후 이를 변경할 수 없습니다.',
                        onConfirm: () {
                          _lockTap();
                        },
                      );
                    } else {
                      showCustomDialog(
                        context: context,
                        title: '성장일기 비공개',
                        message: '성장일기를 비공개하면 작성자만 볼 수 있고,\n업로드 후 이를 변경할 수 없습니다.',
                        onConfirm: () {
                          _lockTap();
                        },
                      );
                    }
                  },
                  child: _isLock
                      ? SvgPicture.asset('assets/icons/ic_lock.svg')
                      : SvgPicture.asset('assets/icons/ic_unlock.svg'),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: diaryStatus == DiaryStatus.submitting ? null : 1,
              backgroundColor: Colors.transparent,
              color: diaryStatus == DiaryStatus.submitting ? Palette.subGreen : Colors.transparent,
            ),
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),
                      const Text(
                        '사진 *',
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
                            GestureDetector(
                              onTap: () async {
                                final images = await selectImages();
                                setState(() {
                                  _files.addAll(images);
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
                                child: const Icon(
                                  Icons.add,
                                  color: Palette.lightGray,
                                ),
                              ),
                            ),
                            ...selectedImageList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      TextFieldWithTitleWidget(
                        controller: _titleTEC,
                        labelText: '제목 *',
                        hintText: '제목을 입력해주세요',
                      ),
                      const SizedBox(height: 40),
                      TextFieldWithTitleWidget(
                        controller: _descTEC,
                        isMultiLine: true,
                        labelText: '내용 *',
                        hintText: '내용을 입력해주세요',
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomConfirmButtonWidget(
          isActive: _isActive,
          onConfirm: () async {
            try {
              setState(() {
                _isActive = false;
              });

              if (widget.isEditMode && widget.originalDiaryModel != null) {
                // 수정 로직
                DiaryModel updatedDiary = await context.read<DiaryProvider>().updateDiary(
                      diaryId: widget.originalDiaryModel!.diaryId,
                      files: _files,
                      remainImageUrls: _remainImageUrls,
                      deleteImageUrls: _deleteImageUrls,
                      title: _titleTEC.text,
                      desc: _descTEC.text,
                    );

                // 내가 좋아요 한 성장일기 리스트 갱신
                context.read<LikeProvider>().updateDiary(updatedDiaryModel: updatedDiary);

                // 공개 상태에 따른 처리
                if (!updatedDiary.isLock) {
                  context.read<FeedProvider>().updateDiary(updatedDiaryModel: updatedDiary);
                }
              } else {
                // 새로운 일기 업로드 로직
                DiaryModel diaryModel = await context.read<DiaryProvider>().uploadDiary(
                      files: _files,
                      title: _titleTEC.text,
                      desc: _descTEC.text,
                      isLock: _isLock,
                    );

                if (!_isLock) {
                  context.read<FeedProvider>().uploadFeed(diaryModel: diaryModel);
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(widget.isEditMode ? "수정 완료" : "작성 완료")),
              );

              Navigator.pop(context);
            } on CustomException catch (e) {
              showErrorDialog(context, e);
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
