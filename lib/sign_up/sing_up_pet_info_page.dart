import 'package:flutter/material.dart';
import 'package:pet_log/components/next_button.dart';
import 'package:pet_log/components/textfield_with_title.dart';
import 'package:pet_log/pallete.dart';

class SingUpPetInfoPage extends StatefulWidget {
  const SingUpPetInfoPage({super.key});

  @override
  _SingUpPetInfoPageState createState() => _SingUpPetInfoPageState();
}

class _SingUpPetInfoPageState extends State<SingUpPetInfoPage> {
  String? _selectedGender;
  String? _selectedNeutering;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Pallete.white,
      appBar: AppBar(
        backgroundColor: Pallete.white,
        scrolledUnderElevation: 0,
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
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '반려동물의 상세정보를\n입력해주세요',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 24,
                color: Pallete.black,
                letterSpacing: -0.6,
              ),
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
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
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
                      TextFieldWithTitle(
                        labelText: '성별',
                        hintText: '선택해주세요',
                        isCupertinoPicker: true,
                        pickerItems: ['수컷', '암컷'],
                        selectedValue: _selectedGender,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 40),
                      TextFieldWithTitle(
                        labelText: '중성화',
                        hintText: '선택해주세요',
                        isCupertinoPicker: true,
                        pickerItems: ['중성화', '비중성화'],
                        selectedValue: _selectedNeutering,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedNeutering = newValue;
                          });
                        },
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NextButton(
        isActive: false,
        onTap: () {
          print("시작하기 눌림");
        },
        buttonText: "시작하기",
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final Color selectedColor;
  final Color unselectedColor;

  StepProgressIndicator({
    required this.totalSteps,
    required this.currentStep,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        return Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: index < currentStep ? selectedColor : unselectedColor,
            ),
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            height: 3.0,
          ),
        );
      }),
    );
  }
}
