import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/components/next_button.dart';
import 'package:pet_log/components/textfield_with_title.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/providers/pet/pet_provider.dart';
import 'package:pet_log/providers/pet/pet_state.dart';
import 'package:provider/provider.dart';

class SignUpPetInfoPage extends StatefulWidget {
  const SignUpPetInfoPage({super.key});

  @override
  _SignUpPetInfoPageState createState() => _SignUpPetInfoPageState();
}

class _SignUpPetInfoPageState extends State<SignUpPetInfoPage> {
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

  // 사진 선택 함수
  Future<void> selectImage() async {
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

  @override
  void initState() {
    super.initState();

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
                        maxLength: 5,
                        hintText: '이름을 입력해주세요',
                        controller: _nameTEC,
                      ),
                      SizedBox(height: 40),

                      // 품종
                      TextFieldWithTitle(
                        labelText: '품종',
                        maxLength: 8,
                        hintText: '품종을 입력해주세요',
                        controller: _breedTEC,
                      ),
                      SizedBox(height: 40),

                      // 생년월일
                      TextFieldWithTitle(
                        labelText: '생년월일',
                        hintText: '2000-08-07 형식으로 입력해주세요',
                        keyboardType: TextInputType.datetime,
                        controller: _birthdayTEC,
                      ),
                      SizedBox(height: 40),

                      // 만난 날
                      TextFieldWithTitle(
                        labelText: '만난 날',
                        hintText: '2000-08-07 형식으로 입력해주세요',
                        keyboardType: TextInputType.datetime,
                        controller: _firstMeetingDateTEC,
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
                        children: genderTypes.map((pet) {
                          return ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedGender == pet
                                    ? Palette.subGreen
                                    : Palette.lightGray,
                                width: 1.0,
                              ),
                            ),
                            label: Text(pet),
                            backgroundColor: Palette.white,
                            selected: _selectedGender == pet,
                            selectedColor: Palette.mainGreen,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: _selectedGender == pet
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 16,
                              color: _selectedGender == pet
                                  ? Palette.white
                                  : Palette.lightGray,
                            ),
                            onSelected: (bool isSelected) {
                              setState(() {
                                _selectedGender = isSelected ? pet : null;
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
                        children: NeuteringTypes.map((pet) {
                          return ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: _selectedNeutering == pet
                                    ? Palette.subGreen
                                    : Palette.lightGray,
                                width: 1.0,
                              ),
                            ),
                            label: Text(pet),
                            backgroundColor: Palette.white,
                            selected: _selectedNeutering == pet,
                            selectedColor: Palette.mainGreen,
                            showCheckmark: false,
                            labelStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: _selectedNeutering == pet
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 16,
                              color: _selectedNeutering == pet
                                  ? Palette.white
                                  : Palette.lightGray,
                            ),
                            onSelected: (bool isSelected) {
                              setState(() {
                                _selectedNeutering = isSelected ? pet : null;
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

              // 펫 업로드 로직
              await context.read<PetProvider>().uploadPet(
                    file: _image,
                    type: "임시 더미",
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

              Navigator.pop(context);
            } on CustomException catch (e) {
              errorDialogWidget(context, e);

              // 에러 발생시 버튼 재활성화
              setState(() {
                _isActive = true;
              });
            }
          },
          buttonText: "시작하기",
        ),
      ),
    );
  }
}
