import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/components/next_button.dart';
import 'package:pet_log/components/textfield_with_title.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/pet_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/medical/medical_provider.dart';
import 'package:pet_log/providers/medical/medical_state.dart';
import 'package:provider/provider.dart';

class MedicalUploadScreen extends StatefulWidget {
  final bool isEditMode;
  final PetModel selectedPet;

  const MedicalUploadScreen({
    super.key,
    this.isEditMode = false,
    required this.selectedPet,
  });

  @override
  State<MedicalUploadScreen> createState() => _MedicalUploadScreenState();
}

class _MedicalUploadScreenState extends State<MedicalUploadScreen> {
  final TextEditingController _visitDateTEC = TextEditingController();
  final TextEditingController _reasonTEC = TextEditingController();
  final TextEditingController _hospitalTEC = TextEditingController();
  final TextEditingController _doctorTEC = TextEditingController();
  final TextEditingController _noteTEC = TextEditingController();

  final List<String> _files = [];

  bool _isActive = false; // 작성하기 버튼 활성화 여부

  void _checkBottomActive() {
    setState(() {
      _isActive = _visitDateTEC.text.isNotEmpty && _reasonTEC.text.isNotEmpty;
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
    final diaryStatus = context.watch<MedicalState>().medicalStatus;

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
                onTap: diaryStatus == MedicalStatus.submitting
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

    _visitDateTEC.addListener(_checkBottomActive);
    _reasonTEC.addListener(_checkBottomActive);
    _hospitalTEC.addListener(_checkBottomActive);
    _doctorTEC.addListener(_checkBottomActive);
    _noteTEC.addListener(_checkBottomActive);
  }

  @override
  void dispose() {
    _visitDateTEC.removeListener(_checkBottomActive);
    _reasonTEC.removeListener(_checkBottomActive);
    _hospitalTEC.removeListener(_checkBottomActive);
    _doctorTEC.removeListener(_checkBottomActive);
    _noteTEC.removeListener(_checkBottomActive);

    _visitDateTEC.dispose();
    _reasonTEC.dispose();
    _hospitalTEC.dispose();
    _doctorTEC.dispose();
    _noteTEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.selectedPet);
    final medicalStatus = context.watch<MedicalState>().medicalStatus;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 다른 곳 클릭 시 키보드 내리기
      child: Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Palette.background,
          title: Text(
            "진료기록",
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Palette.black,
              letterSpacing: -0.5,
            ),
          ),
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: medicalStatus == MedicalStatus.submitting ? null : 1,
              backgroundColor: Colors.transparent,
              color: medicalStatus == MedicalStatus.submitting
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

                      // 진료일 (필수)
                      TextFieldWithTitle(
                        controller: _visitDateTEC,
                        labelText: '진료일 *',
                        hintText: '2000-08-07 형식으로 입력해주세요',
                      ),
                      SizedBox(height: 40),

                      // 이유 (필수)
                      TextFieldWithTitle(
                        controller: _reasonTEC,
                        labelText: '이유 *',
                        hintText: '병원에 간 이유를 입력해주세요',
                      ),
                      SizedBox(height: 40),

                      // 병원
                      TextFieldWithTitle(
                        controller: _hospitalTEC,
                        labelText: '병원',
                        hintText: '병원 이름을 입력해주세요',
                      ),
                      SizedBox(height: 40),

                      // 수의사
                      TextFieldWithTitle(
                        controller: _doctorTEC,
                        labelText: '수의사',
                        hintText: '수의사 이름을 입력해주세요',
                      ),
                      SizedBox(height: 40),

                      //메모
                      TextFieldWithTitle(
                        controller: _noteTEC,
                        isMultiLine: true,
                        labelText: '메모',
                        hintText: '특이사항이나 메모를 입력해주세요',
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

              // 진료기록 업로드 로직
              await context.read<MedicalProvider>().uploadMedical(
                    files: _files,
                    visitDate: _visitDateTEC.text,
                    reason: _reasonTEC.text,
                    hospital: _hospitalTEC.text,
                    doctor: _doctorTEC.text,
                    note: _noteTEC.text,
                    petId: widget.selectedPet.petId,
                  );

              // 스낵바
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("작성 완료")));

              Navigator.pop(context);
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
