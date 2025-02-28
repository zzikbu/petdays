import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:petdays/common/widgets/pd_app_bar.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/show_error_dialog.dart';
import '../../common/widgets/w_textfield_with_title.dart';
import '../../common/widgets/w_bottom_confirm_button.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/medical_model.dart';
import '../../models/pet_model.dart';
import '../../palette.dart';
import '../../providers/medical/medical_provider.dart';
import '../../providers/medical/medical_state.dart';
import '../../utils/permission_utils.dart';

class MedicalUploadScreen extends StatefulWidget {
  final PetModel selectedPet;
  final MedicalModel? originalMedicalModel; // 수정

  const MedicalUploadScreen({
    super.key,
    required this.selectedPet,
    this.originalMedicalModel, // 수정
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
  final List<String> _remainImageUrls = []; // 유지할 기존 이미지들
  final List<String> _deleteImageUrls = []; // 삭제할 기존 이미지들

  bool _isEnabled = true;
  bool _isBottomActive = false;

  void _checkBottomActive() {
    setState(() {
      _isBottomActive = _visitDateTEC.text.isNotEmpty && _reasonTEC.text.isNotEmpty;
    });
  }

  Future<void> _onConfirmButtonPressed() async {
    try {
      // 비활성화
      setState(() {
        _isEnabled = false;
        _isBottomActive = false;
      });

      if (widget.originalMedicalModel != null) {
        // 수정
        await context.read<MedicalProvider>().updateMedical(
              medicalId: widget.originalMedicalModel!.medicalId,
              uid: widget.originalMedicalModel!.uid,
              petId: widget.originalMedicalModel!.pet.petId,
              files: _files,
              remainImageUrls: _remainImageUrls,
              deleteImageUrls: _deleteImageUrls,
              visitedDate: _visitDateTEC.text,
              reason: _reasonTEC.text,
              hospital: _hospitalTEC.text,
              doctor: _doctorTEC.text,
              note: _noteTEC.text,
            );

        Navigator.pop(context);
      } else {
        // 업로드
        await context.read<MedicalProvider>().uploadMedical(
              files: _files,
              visitedDate: _visitDateTEC.text,
              reason: _reasonTEC.text,
              hospital: _hospitalTEC.text,
              doctor: _doctorTEC.text,
              petId: widget.selectedPet.petId,
              note: _noteTEC.text,
            );

        context.go('/home/medical');
      }
    } on CustomException catch (e) {
      showErrorDialog(context, e);

      // 에러 발생시 활성화
      setState(() {
        _isEnabled = true;
        _isBottomActive = true;
      });
    }
  }

  Future<List<String>> selectImages() async {
    final hasPermission = await PermissionUtils.checkPhotoPermission(context);
    if (!hasPermission) return [];

    List<XFile> images = await ImagePicker().pickMultiImage(
      maxHeight: 1024,
      maxWidth: 1024,
    );

    return images.map((e) => e.path).toList(); // XFile.path를 갖는 문자열 리스트
  }

  List<Widget> _selectedImageList() {
    final medicalStatus = context.watch<MedicalState>().medicalStatus;

    return _files.map((filePath) {
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image(
                image: ExtendedFileImageProvider(File(filePath)),
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
                onTap: medicalStatus == MedicalStatus.submitting
                    ? null // 작성 중일때 삭제 버튼 클릭 막기
                    : () {
                        setState(() {
                          _files.remove(filePath);
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

  List<Widget> _existingImageList() {
    final medicalStatus = context.watch<MedicalState>().medicalStatus;

    return _remainImageUrls.map((imageUrl) {
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image(
                image: ExtendedNetworkImageProvider(imageUrl),
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
                          _remainImageUrls.remove(imageUrl); // 유지 목록에서 제거
                          _deleteImageUrls.add(imageUrl); // 삭제 목록에 추가
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

    // 수정일 때
    if (widget.originalMedicalModel != null) {
      _remainImageUrls.addAll(widget.originalMedicalModel!.imageUrls);

      _visitDateTEC.text = widget.originalMedicalModel!.visitedDate;
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
        appBar: const PDAppBar(titleText: '진료기록'),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: medicalStatus == MedicalStatus.submitting ? null : 1,
              backgroundColor: Colors.transparent,
              color:
                  medicalStatus == MedicalStatus.submitting ? Palette.subGreen : Colors.transparent,
            ),
            Expanded(
              child: Scrollbar(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 사진
                      const Text(
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
                              onTap: _isEnabled
                                  ? () async {
                                      final images = await selectImages();
                                      setState(() {
                                        _files.addAll(images);
                                        _checkBottomActive();
                                      });
                                    }
                                  : null,
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
                            ..._existingImageList(), // 기존 이미지들 먼저 표시
                            ..._selectedImageList(), // 새로 선택된 이미지들 표시
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 진료일 (필수)
                      GestureDetector(
                        onTap: () {
                          DateTime selectedDate = DateTime.now();

                          showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 260,
                                color: const Color(0xFFCED1D8),
                                child: Column(
                                  children: [
                                    Container(
                                      color: const Color(0xFFF7F7F7),
                                      height: 40,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: CupertinoButton(
                                          padding: const EdgeInsets.only(right: 16),
                                          onPressed: () {
                                            setState(() {
                                              _visitDateTEC.text =
                                                  DateFormat('yyyy-MM-dd').format(selectedDate);
                                              _checkBottomActive();
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            '완료',
                                            style: TextStyle(color: CupertinoColors.systemBlue),
                                          ),
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
                        child: TextFieldWithTitleWidget(
                          labelText: '진료일 *',
                          hintText: '진료일을 선택해주세요',
                          controller: _visitDateTEC,
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 이유 (필수)
                      TextFieldWithTitleWidget(
                        controller: _reasonTEC,
                        labelText: '이유 *',
                        hintText: '병원에 간 이유를 입력해주세요',
                        enabled: _isEnabled,
                      ),
                      const SizedBox(height: 40),

                      // 병원
                      TextFieldWithTitleWidget(
                        controller: _hospitalTEC,
                        labelText: '병원',
                        hintText: '병원 이름을 입력해주세요',
                        enabled: _isEnabled,
                      ),
                      const SizedBox(height: 40),

                      // 수의사
                      TextFieldWithTitleWidget(
                        controller: _doctorTEC,
                        labelText: '수의사',
                        hintText: '수의사 이름을 입력해주세요',
                        enabled: _isEnabled,
                      ),
                      const SizedBox(height: 40),

                      // 메모
                      TextFieldWithTitleWidget(
                        controller: _noteTEC,
                        isMultiLine: true,
                        labelText: '메모',
                        hintText: '특이사항이나 메모를 입력해주세요',
                        enabled: _isEnabled,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomConfirmButtonWidget(
          isActive: _isBottomActive,
          onConfirm: _onConfirmButtonPressed,
          buttonText: widget.originalMedicalModel != null ? "수정하기" : "작성하기",
        ),
      ),
    );
  }
}
