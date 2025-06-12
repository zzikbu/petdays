import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/show_custom_dialog.dart';
import '../widgets/pd_circle_avatar.dart';
import '../widgets/w_bottom_confirm_button.dart';
import '../widgets/show_error_dialog.dart';
import '../../core/enums/select_pet_for.dart';
import '../../exceptions/custom_exception.dart';
import '../../domain/model/pet_model.dart';
import '../../palette.dart';
import '../../providers/pet/pet_provider.dart';
import '../../providers/pet/pet_state.dart';
import '../../utils/permission_utils.dart';

class SelectPetScreen extends StatefulWidget {
  final SelectPetFor type;

  const SelectPetScreen({
    super.key,
    required this.type,
  });

  @override
  State<SelectPetScreen> createState() => _SelectPetScreenState();
}

class _SelectPetScreenState extends State<SelectPetScreen> {
  List<int> selectedIndices = [];
  bool _isActive = false;

  void _checkBottomActive() {
    setState(() {
      _isActive = selectedIndices.isNotEmpty;
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      switch (widget.type) {
        case SelectPetFor.medical:
          selectedIndices = [index];
        case SelectPetFor.walk:
          if (selectedIndices.contains(index)) {
            selectedIndices.remove(index);
          } else {
            selectedIndices.add(index);
          }
      }
      _checkBottomActive();
    });
  }

  String get _titleText {
    switch (widget.type) {
      case SelectPetFor.medical:
        return '누구와 병원에 갔나요?';
      case SelectPetFor.walk:
        return '누구와 산책하나요?';
    }
  }

  String get _subTitleText {
    switch (widget.type) {
      case SelectPetFor.medical:
        return '중복 선택이 불가능합니다.';
      case SelectPetFor.walk:
        return '중복 선택이 가능합니다.';
    }
  }

  String get _buttonText {
    switch (widget.type) {
      case SelectPetFor.medical:
        return '다음';
      case SelectPetFor.walk:
        return '시작하기';
    }
  }

  void _handleConfirm(List<PetModel> petList) async {
    switch (widget.type) {
      case SelectPetFor.medical:
        final selectedPet = petList[selectedIndices[0]];
        context.go(
          '/home/medical/select_pet/upload',
          extra: selectedPet,
        );

      case SelectPetFor.walk:
        final selectedPets = selectedIndices.map((index) => petList[index]).toList();
        await _handleWalkStart(selectedPets);
    }
  }

  Future<void> _handleWalkStart(List<PetModel> selectedPets) async {
    if (Platform.isAndroid) {
      showCustomDialog(
        context: context,
        hasCancelButton: false,
        title: '백그라운드 위치',
        message: '이 앱은 사용 중이 아닐 때도 위치 데이터를 수집하여 산책 경로를 추적합니다.',
        onConfirm: () async {
          Navigator.pop(context);
          await _navigateToWalkMap(selectedPets);
        },
      );
    } else {
      await _navigateToWalkMap(selectedPets);
    }
  }

  Future<void> _navigateToWalkMap(List<PetModel> selectedPets) async {
    final hasPermission = await PermissionUtils.checkLocationPermission(context);
    if (!hasPermission) return;

    if (context.mounted) {
      context.go(
        '/home/walk/select_pet/map',
        extra: selectedPets,
      );
    }
  }

  void _getData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final currentUserId = context.read<User>().uid;
        await context.read<PetProvider>().getPetList(uid: currentUserId);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final petState = context.watch<PetState>();
    final petList = petState.petList;

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
                const SizedBox(height: 20),
                Text(
                  _titleText,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Palette.black,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _subTitleText,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Palette.mediumGray,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 150,
                ),
                itemCount: petList.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isSelected = selectedIndices.contains(index);
                  return GestureDetector(
                    onTap: () => _toggleSelection(index),
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: Palette.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Palette.black : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.black.withOpacity(0.05),
                            offset: const Offset(8, 8),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          PDCircleAvatar(
                            imageUrl: petList[index].image,
                            size: 100,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            petList[index].name,
                            style: const TextStyle(
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
      bottomNavigationBar: BottomConfirmButtonWidget(
        isActive: _isActive,
        onConfirm: () => _handleConfirm(petList),
        buttonText: _buttonText,
      ),
    );
  }
}
