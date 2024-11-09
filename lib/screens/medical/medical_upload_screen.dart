import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:petdays/components/error_dialog_widget.dart';
import 'package:petdays/components/next_button.dart';
import 'package:petdays/components/textfield_with_title.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/medical_model.dart';
import 'package:petdays/models/pet_model.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/medical/medical_provider.dart';
import 'package:petdays/providers/medical/medical_state.dart';
import 'package:petdays/utils/permission_utils.dart';
import 'package:provider/provider.dart';

class MedicalUploadScreen extends StatefulWidget {
  final bool isEditMode;
  final PetModel selectedPet;
  final MedicalModel? originalMedicalModel; // 수정

  const MedicalUploadScreen({
    super.key,
    this.isEditMode = false,
    required this.selectedPet,
    this.originalMedicalModel, // 수정
  });

  @override
  State<MedicalUploadScreen> createState() => _MedicalUploadScreenState();
}

class _MedicalUploadScreenState extends State<MedicalUploadScreen> {
  /// Properties
  final TextEditingController _visitDateTEC = TextEditingController();
  final TextEditingController _reasonTEC = TextEditingController();
  final TextEditingController _hospitalTEC = TextEditingController();
  final TextEditingController _doctorTEC = TextEditingController();
  final TextEditingController _noteTEC = TextEditingController();

  final List<String> _files = [];
  final List<String> _remainImageUrls = []; // 유지할 기존 이미지들
  final List<String> _deleteImageUrls = []; // 삭제할 기존 이미지들

  bool _isActive = false; // 작성하기 버튼 활성화 여부

  /// Method
  void _checkBottomActive() {
    setState(() {
      _isActive = _visitDateTEC.text.isNotEmpty && _reasonTEC.text.isNotEmpty;
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

  // 기존 이미지 표시를 위한 위젯 리스트
  List<Widget> existingImageList() {
    final medicalStatus = context.watch<MedicalState>().medicalStatus;

    return _remainImageUrls.map((url) {
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                height: 80,
                width: 80,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: InkWell(
                onTap: medicalStatus == MedicalStatus.submitting
                    ? null
                    : () {
                        setState(() {
                          _remainImageUrls.remove(url); // 유지 목록에서 제거
                          _deleteImageUrls.add(url); // 삭제 목록에 추가
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

  /// LifeCycle
  @override
  void initState() {
    super.initState();

    // 수정 모드일 때 기존 데이터로 초기화
    if (widget.isEditMode && widget.originalMedicalModel != null) {
      // 기존 이미지 URLs를 유지할 이미지 목록에 추가
      _remainImageUrls.addAll(widget.originalMedicalModel!.imageUrls);

      _visitDateTEC.text = widget.originalMedicalModel!.visitDate;
      _reasonTEC.text = widget.originalMedicalModel!.reason;
      _hospitalTEC.text = widget.originalMedicalModel!.hospital;
      _doctorTEC.text = widget.originalMedicalModel!.doctor;
      _noteTEC.text = widget.originalMedicalModel!.note;
    }

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
    final medicalStatus = context.watch<MedicalState>().medicalStatus;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 다른 곳 클릭 시 키보드 내리기
      child: Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          backgroundColor: Palette.background,
          centerTitle: true,
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
                            ...existingImageList(), // 기존 이미지들 먼저 표시
                            ...selectedImageList(), // 새로 선택된 이미지들 표시
                          ],
                        ),
                      ),
                      SizedBox(height: 40),

                      // 진료일 (필수)
                      GestureDetector(
                        onTap: () {
                          DateTime selectedDate = DateTime.now();

                          showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 260,
                                color: Color(0xFFCED1D8),
                                child: Column(
                                  children: [
                                    Container(
                                      color: Color(0xFFF7F7F7),
                                      height: 40,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: CupertinoButton(
                                          padding: EdgeInsets.only(right: 16),
                                          child: Text(
                                            '완료',
                                            style: TextStyle(
                                              color: CupertinoColors.systemBlue,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _visitDateTEC.text =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(selectedDate);
                                              _checkBottomActive();
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.date,
                                        initialDateTime: DateTime.now(),
                                        maximumDate: DateTime.now(),
                                        minimumYear: 1900,
                                        onDateTimeChanged: (DateTime newDate) {
                                          selectedDate = newDate;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: TextFieldWithTitle(
                          labelText: '진료일 *',
                          hintText: '진료일을 선택해주세요',
                          controller: _visitDateTEC,
                          enabled: false,
                        ),
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

              if (widget.isEditMode) {
                // 진료기록 수정 로직
                await context.read<MedicalProvider>().updateMedical(
                      medicalId: widget.originalMedicalModel!.medicalId,
                      uid: widget.originalMedicalModel!.uid,
                      petId: widget.selectedPet.petId,
                      files: _files,
                      remainImageUrls: _remainImageUrls,
                      deleteImageUrls: _deleteImageUrls,
                      visitDate: _visitDateTEC.text,
                      reason: _reasonTEC.text,
                      hospital: _hospitalTEC.text,
                      doctor: _doctorTEC.text,
                      note: _noteTEC.text,
                    );

                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("수정 완료")));

                Navigator.pop(context);
              } else {
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

                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("작성 완료")));

                Navigator.pop(context);
                Navigator.pop(context);
              }
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
