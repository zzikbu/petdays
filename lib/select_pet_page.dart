import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pet_log/components/error_dialog_widget.dart';
import 'package:pet_log/exceptions/custom_exception.dart';
import 'package:pet_log/models/pet_model.dart';
import 'package:pet_log/providers/pet/pet_provider.dart';
import 'package:pet_log/providers/pet/pet_state.dart';
import 'package:pet_log/walk/walk_map_page.dart';
import 'package:provider/provider.dart';

import 'components/next_button.dart';
import 'medical/medical_write_page.dart';
import 'palette.dart';

class SelectPetPage extends StatefulWidget {
  final bool isMedical;

  const SelectPetPage({
    super.key,
    required this.isMedical,
  });

  @override
  State<SelectPetPage> createState() => _SelectPetPageState();
}

class _SelectPetPageState extends State<SelectPetPage>
    with AutomaticKeepAliveClientMixin<SelectPetPage> {
  late final PetProvider petProvider;

  List<int> selectedIndices = []; // 선택된 애완동물 인덱스 저장

  bool _isActive = false; // 작성하기 버튼 활성화 여부

  // 다른 화면에서 돌아올 때
  // 데이터를 매번 가져오지 않도록
  @override
  bool get wantKeepAlive => true;

  void _checkBottomActive() {
    setState(() {
      _isActive = selectedIndices.isNotEmpty;
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (widget.isMedical) {
        // 중복 선택이 불가능할 경우
        selectedIndices = [index]; // 선택한 인덱스만 저장
      } else {
        // 중복 선택이 가능할 경우
        if (selectedIndices.contains(index)) {
          selectedIndices.remove(index); // 이미 선택된 경우 선택 해제
        } else {
          selectedIndices.add(index); // 선택 추가
        }
      }
      _checkBottomActive();
    });
  }

  // 펫 가져오기
  void _getData() {
    String uid = context.read<User>().uid;

    // 위젯들이 만들어 진 후에
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await petProvider.getPetList(uid: uid);
      } on CustomException catch (e) {
        errorDialogWidget(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    petProvider = context.read<PetProvider>();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    PetState petState = context.watch<PetState>();
    List<PetModel> petList = petState.petList;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),

                // 타이틀
                Text(
                  widget.isMedical ? '누구와 병원에 갔나요?' : '누구와 산책하나요?',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Palette.black,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 5),

                // 설명
                Text(
                  widget.isMedical ? '중복 선택이 불가능합니다.' : '중복 선택이 가능합니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Palette.mediumGray,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),

          // GridView
          Expanded(
            child: Scrollbar(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 150, // 높이
                ),
                itemCount: petList.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isSelected = selectedIndices.contains(index); // 선택 여부 확인
                  return GestureDetector(
                    onTap: () => _toggleSelection(index), // 선택 토글
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: Palette.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              isSelected ? Palette.black : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.black.withOpacity(0.05),
                            offset: Offset(8, 8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: ExtendedNetworkImageProvider(
                                    petList[index].image),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            petList[index].name,
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Palette.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NextButton(
        isActive: _isActive,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  widget.isMedical ? MedicalWritePage() : WalkMapPage(),
            ),
          );
        },
        buttonText: "시작하기",
      ),
    );
  }
}
