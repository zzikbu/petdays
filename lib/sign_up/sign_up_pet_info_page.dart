import 'package:flutter/material.dart';
import 'package:pet_log/components/next_button.dart';
import 'package:pet_log/components/textfield_with_title.dart';
import 'package:pet_log/pallete.dart';

import '../components/step_progress_indicator.dart';

class SignUpPetInfoPage extends StatefulWidget {
  const SignUpPetInfoPage({super.key});

  @override
  _SignUpPetInfoPageState createState() => _SignUpPetInfoPageState();
}

class _SignUpPetInfoPageState extends State<SignUpPetInfoPage> {
  String? selectedGender;
  String? selectedNeutering;

  final List<String> genderTypes = [
    '수컷',
    '암컷',
  ];

  final List<String> NeuteringTypes = [
    '했어요',
    '안했어요',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Pallete.white,
      appBar: AppBar(
        backgroundColor: Pallete.white,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBar: NextButton(
        isActive: false,
        onTap: () {
          print("시작하기 눌림");
        },
        buttonText: "시작하기",
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: StepProgressIndicator(
              totalSteps: 3,
              currentStep: 3,
              selectedColor: Pallete.black,
              unselectedColor: Pallete.lightGray,
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
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
                          color: Pallete.black,
                          letterSpacing: -0.6,
                        ),
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 120.0,
                              height: 120.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Pallete.lightGray,
                                  width: 2.0, // 원형 테두리의 두께
                                ),
                                color: Colors.white, // 원형의 배경색
                              ),
                              child: Icon(
                                Icons.pets,
                                color: Colors.black,
                                size: 40.0,
                              ),
                            ),
                            Positioned(
                              bottom: -10,
                              right: -5,
                              child: IconButton(
                                icon: Icon(
                                  Icons.camera_alt,
                                  color: Pallete.black,
                                  size: 30.0,
                                ),
                                onPressed: () {
                                  print('카메라 아이콘 눌림');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
                          TextFieldWithTitle(
                            labelText: '이름',
                            maxLength: 5,
                            hintText: '이름을 입력해주세요',
                          ),
                          SizedBox(height: 40),
                          TextFieldWithTitle(
                            labelText: '품종',
                            maxLength: 8,
                            hintText: '품종을 입력해주세요',
                          ),
                          SizedBox(height: 40),
                          TextFieldWithTitle(
                            labelText: '생년월일',
                            hintText: '2000-08-07 형식으로 입력해주세요',
                            keyboardType: TextInputType.datetime,
                          ),
                          SizedBox(height: 40),
                          TextFieldWithTitle(
                            labelText: '만날 날',
                            hintText: '2000-08-07 형식으로 입력해주세요',
                            keyboardType: TextInputType.datetime,
                          ),
                          SizedBox(height: 40),
                          Text(
                            '성별',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Pallete.black,
                              letterSpacing: -0.45,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            runSpacing: 8.0, // 상하
                            spacing: 8.0, // 좌우
                            children: this.genderTypes.map((pet) {
                              return ChoiceChip(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: this.selectedGender == pet
                                        ? Pallete.subGreen
                                        : Pallete.lightGray,
                                    width: 1.0,
                                  ),
                                ),
                                label: Text(pet),
                                backgroundColor: Pallete.white,
                                selected: this.selectedGender == pet,
                                selectedColor: Pallete.mainGreen,
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: this.selectedGender == pet
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 16,
                                  color: this.selectedGender == pet
                                      ? Pallete.white
                                      : Pallete.lightGray,
                                ),
                                onSelected: (bool isSelected) {
                                  setState(() {
                                    this.selectedGender =
                                        isSelected ? pet : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 30),
                          Text(
                            '중성화',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Pallete.black,
                              letterSpacing: -0.45,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            runSpacing: 8.0, // 상하
                            spacing: 8.0, // 좌우
                            children: this.NeuteringTypes.map((pet) {
                              return ChoiceChip(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: this.selectedNeutering == pet
                                        ? Pallete.subGreen
                                        : Pallete.lightGray,
                                    width: 1.0,
                                  ),
                                ),
                                label: Text(pet),
                                backgroundColor: Pallete.white,
                                selected: this.selectedNeutering == pet,
                                selectedColor: Pallete.mainGreen,
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontWeight: this.selectedNeutering == pet
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: 16,
                                  color: this.selectedNeutering == pet
                                      ? Pallete.white
                                      : Pallete.lightGray,
                                ),
                                onSelected: (bool isSelected) {
                                  setState(() {
                                    this.selectedNeutering =
                                        isSelected ? pet : null;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
