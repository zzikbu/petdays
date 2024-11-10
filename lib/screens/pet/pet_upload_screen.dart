import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:petdays/components/show_error_dialog.dart';
import 'package:petdays/components/next_button.dart';
import 'package:petdays/components/textfield_with_title.dart';
import 'package:petdays/exceptions/custom_exception.dart';
import 'package:petdays/models/pet_model.dart';
import 'package:petdays/palette.dart';
import 'package:petdays/providers/pet/pet_provider.dart';
import 'package:petdays/providers/pet/pet_state.dart';
import 'package:petdays/screens/sign_in/reset_password_screen.dart';
import 'package:petdays/utils/permission_utils.dart';
import 'package:provider/provider.dart';

class PetUploadScreen extends StatefulWidget {
  final PetModel? originalPetModel;

  const PetUploadScreen({
    super.key,
    this.originalPetModel,
  });

  @override
  _PetUploadScreenState createState() => _PetUploadScreenState();
}

class _PetUploadScreenState extends State<PetUploadScreen> {
  /// Properties
  final TextEditingController _nameTEC = TextEditingController();
  final TextEditingController _breedTEC = TextEditingController();
  final TextEditingController _birthdayTEC = TextEditingController();
  final TextEditingController _firstMeetingDateTEC = TextEditingController();

  String? _selectedGender;
  String? _selectedNeutering;

  final List<String> genderTypes = ['수컷', '암컷'];
  final List<String> NeuteringTypes = ['했어요', '안했어요'];

  Uint8List? _image; // Uint8List: 이미지나 동영상 같은 바이너리 데이터 취급할 때
  bool _isActive = false; // 작성하기 버튼 활성화 여부

  /// Method
  // 사진 선택 함수
  Future<void> selectImage() async {
    final hasPermission = await PermissionUtils.checkPhotoPermission(context);
    if (!hasPermission) return;

    ImagePicker imagePicker = new ImagePicker();
    // XFile: 기기의 파일시스템에 접근할 수 있는 클래스
    // 사진을 선택하지 안했을 때는 null 반환
    XFile? file = await imagePicker.pickImage(
      source: ImageSource.gallery,
      // 용량 줄이기
      maxHeight: 512,
      maxWidth: 512,
    );

    if (file != null) {
      Uint8List uint8list =
          await file.readAsBytes(); // 선택한 이미지를 코드로 조작할 수 있게 반환
      setState(() {
        _image = uint8list;
        _checkBottomActive();
      });
    }
  }

  void _checkBottomActive() {
    setState(() {
      _isActive = _image != null &&
          _nameTEC.text.isNotEmpty &&
          _breedTEC.text.isNotEmpty &&
          _birthdayTEC.text.isNotEmpty &&
          _firstMeetingDateTEC.text.isNotEmpty &&
          (_selectedGender?.isNotEmpty ?? false) &&
          (_selectedNeutering?.isNotEmpty ?? false);
    });
  }

  // 네트워크 이미지를 Uint8List로 변환
  Future<void> loadNetworkImage(String imageUrl) async {
    final Uint8List? bytes =
        await ExtendedNetworkImageProvider(imageUrl).getNetworkImageData();
    if (bytes != null) {
      setState(() {
        _image = bytes;
        _checkBottomActive();
      });
    }
  }

  /// LifeCycle
  @override
  void initState() {
    super.initState();

    // 수정일 때 기존 데이터
    if (widget.originalPetModel != null) {
      loadNetworkImage(widget.originalPetModel!.image);
      _nameTEC.text = widget.originalPetModel!.name;
      _breedTEC.text = widget.originalPetModel!.breed;
      _birthdayTEC.text = widget.originalPetModel!.birthDay;
      _firstMeetingDateTEC.text = widget.originalPetModel!.firstMeetingDate;
      _selectedGender = widget.originalPetModel!.gender == "male" ? "수컷" : "암컷";
      _selectedNeutering =
          widget.originalPetModel!.isNeutering ? "했어요" : "안했어요";
    }

    _nameTEC.addListener(_checkBottomActive);
    _breedTEC.addListener(_checkBottomActive);
    _birthdayTEC.addListener(_checkBottomActive);
    _firstMeetingDateTEC.addListener(_checkBottomActive);
  }

  @override
  void dispose() {
    _nameTEC.removeListener(_checkBottomActive);
    _breedTEC.removeListener(_checkBottomActive);
    _birthdayTEC.removeListener(_checkBottomActive);
    _firstMeetingDateTEC.removeListener(_checkBottomActive);

    _nameTEC.dispose();
    _breedTEC.dispose();
    _birthdayTEC.dispose();
    _firstMeetingDateTEC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petStatus = context.watch<PetState>().petStatus;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // 다른 곳 클릭 시 키보드 내리기
      child: Scaffold(
        backgroundColor: Palette.background,
        appBar: AppBar(
          backgroundColor: Palette.background,
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            LinearProgressIndicator(
              value: petStatus == PetStatus.submitting ? null : 1,
              backgroundColor: Colors.transparent,
              color: petStatus == PetStatus.submitting
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
                      SizedBox(height: 30),
                      Text(
                        '반려동물의 상세정보를\n입력해주세요',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 24,
                          color: Palette.black,
                          letterSpacing: -0.6,
                        ),
                      ),
                      SizedBox(height: 30),

                      // 사진
                      Center(
                        child: Stack(
                          // clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Palette.lightGray,
                                  width: 2.0,
                                ),
                                image: _image != null
                                    ? DecorationImage(
                                        image: MemoryImage(_image!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  await selectImage();
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: Icon(
                                    color: Colors.white,
                                    size: 24,
                                    Icons.camera_alt,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),

                      // 이름
                      TextFieldWithTitle(
                        labelText: '이름',
                        maxLength: 6,
                        hintText: '이름을 입력해주세요',
                        controller: _nameTEC,
                      ),
                      SizedBox(height: 40),

                      // 품종
                      TextFieldWithTitle(
                        labelText: '품종',
                        maxLength: 10,
                        hintText: '품종을 입력해주세요',
                        controller: _breedTEC,
                      ),
                      SizedBox(height: 40),

                      // 생년월일
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
                                              _birthdayTEC.text =
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
                          labelText: '생년월일',
                          hintText: '생년월일을 선택해주세요',
                          controller: _birthdayTEC,
                          enabled: false,
                        ),
                      ),
                      SizedBox(height: 40),

                      // 만난 날
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
                                              _firstMeetingDateTEC.text =
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
                          labelText: '만난 날',
                          hintText: '만난 날을 선택해주세요',
                          controller: _firstMeetingDateTEC,
                          enabled: false,
                        ),
                      ),
                      SizedBox(height: 40),

                      // 성별
                      Text(
                        '성별',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Palette.black,
                          letterSpacing: -0.45,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        runSpacing: 8.0, // 상하
                        spacing: 8.0, // 좌우
                        children: genderTypes.map((e) {
                          return ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedGender == e
                                    ? Palette.subGreen
                                    : Palette.lightGray,
                                width: 1.0,
                              ),
                            ),
                            label: Text(e),
                            backgroundColor: Palette.white,
                            selected: _selectedGender == e,
                            selectedColor: Palette.mainGreen,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: _selectedGender == e
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 16,
                              color: _selectedGender == e
                                  ? Palette.white
                                  : Palette.lightGray,
                            ),
                            onSelected: (bool isSelected) {
                              setState(() {
                                _selectedGender = isSelected ? e : null;
                                _checkBottomActive();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 30),

                      // 중성화
                      Text(
                        '중성화',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Palette.black,
                          letterSpacing: -0.45,
                        ),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        runSpacing: 8.0, // 상하
                        spacing: 8.0, // 좌우
                        children: NeuteringTypes.map((e) {
                          return ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedNeutering == e
                                    ? Palette.subGreen
                                    : Palette.lightGray,
                                width: 1.0,
                              ),
                            ),
                            label: Text(e),
                            backgroundColor: Palette.white,
                            selected: _selectedNeutering == e,
                            selectedColor: Palette.mainGreen,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: _selectedNeutering == e
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 16,
                              color: _selectedNeutering == e
                                  ? Palette.white
                                  : Palette.lightGray,
                            ),
                            onSelected: (bool isSelected) {
                              setState(() {
                                _selectedNeutering = isSelected ? e : null;
                                _checkBottomActive();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 30),
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

              if (widget.originalPetModel != null) {
                // 펫 수정 로직
                await context.read<PetProvider>().updatePet(
                      petId: widget.originalPetModel!.petId,
                      file: _image,
                      name: _nameTEC.text,
                      breed: _breedTEC.text,
                      birthDay: _birthdayTEC.text,
                      firstMeetingDate: _firstMeetingDateTEC.text,
                      gender: _selectedGender! == "수컷" ? "male" : "female",
                      isNeutering: _selectedNeutering! == "했어요" ? true : false,
                      currentImageUrl: widget.originalPetModel!.image,
                      createAt: widget.originalPetModel!.createAt,
                    );

                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("수정 완료")));
              } else {
                // 펫 업로드 로직
                await context.read<PetProvider>().uploadPet(
                      file: _image,
                      name: _nameTEC.text,
                      breed: _breedTEC.text,
                      birthDay: _birthdayTEC.text,
                      firstMeetingDate: _firstMeetingDateTEC.text,
                      gender: _selectedGender! == "수컷" ? "male" : "female",
                      isNeutering: _selectedNeutering! == "했어요" ? true : false,
                    );

                // 스낵바
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("추가 완료")));
              }
              Navigator.pop(context);
            } on CustomException catch (e) {
              showErrorDialog(context, e);

              // 에러 발생시 버튼 재활성화
              setState(() {
                _isActive = true;
              });
            }
          },
          buttonText: widget.originalPetModel == null ? "시작하기" : "수정하기",
        ),
      ),
    );
  }
}
