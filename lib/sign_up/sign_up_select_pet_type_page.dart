import 'package:flutter/material.dart';
import 'package:pet_log/pallete.dart';
import 'package:pet_log/sign_up/sign_up_pet_info_page.dart';

import '../components/next_button.dart';
import '../components/step_progress_indicator.dart';

class SignUpSelectPetTypePage extends StatefulWidget {
  const SignUpSelectPetTypePage({super.key});

  @override
  State<SignUpSelectPetTypePage> createState() =>
      _SignUpSelectPetTypePageState();
}

class _SignUpSelectPetTypePageState extends State<SignUpSelectPetTypePage> {
  String? selectedPet;

  final List<String> petTypes = [
    '강아지',
    '고양이',
    '거북이',
    '고슴도치',
    '도마뱀',
    '뱀',
    '새',
    '햄스터',
    '토끼',
  ];

  @override
  void initState() {
    super.initState();
    petTypes.sort(); // 가나다 순 정렬
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.white,
      appBar: AppBar(
        backgroundColor: Pallete.white,
      ),
      bottomNavigationBar: NextButton(
        isActive: selectedPet != null, // 선택된 펫이 있을 때 활성화
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpPetInfoPage()),
          );
        },
        buttonText: "다음",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            StepProgressIndicator(
              totalSteps: 3,
              currentStep: 2,
              selectedColor: Pallete.black,
              unselectedColor: Pallete.lightGray,
            ),
            SizedBox(height: 30),
            Text(
              '어떤 반려동물을 추가하나요?',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Pallete.black,
                letterSpacing: -0.6,
              ),
            ),
            SizedBox(height: 5),
            Text(
              '가입 시에는 한 마리만 등록 가능합니다.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Pallete.mediumGray,
                letterSpacing: -0.6,
              ),
            ),
            SizedBox(height: 60),
            Wrap(
              runSpacing: 8.0, // 상하
              spacing: 8.0, // 좌우
              children: petTypes.map((pet) {
                return ChoiceChip(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: selectedPet == pet
                          ? Pallete.subGreen
                          : Pallete.lightGray,
                      width: 1.0,
                    ),
                  ),
                  label: Text(pet),
                  backgroundColor: Pallete.white,
                  selected: selectedPet == pet,
                  selectedColor: Pallete.mainGreen,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight:
                        selectedPet == pet ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 16,
                    color:
                        selectedPet == pet ? Pallete.white : Pallete.lightGray,
                  ),
                  onSelected: (bool isSelected) {
                    setState(() {
                      selectedPet = isSelected ? pet : null;
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
