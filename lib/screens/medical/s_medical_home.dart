import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petdays/screens/medical/w_medical_home_card.dart';
import 'package:provider/provider.dart';

import '../../components/show_custom_dialog.dart';
import '../../components/show_error_dialog.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/medical_model.dart';
import '../../palette.dart';
import '../../providers/medical/medical_provider.dart';
import '../../providers/medical/medical_state.dart';
import '../../providers/pet/pet_state.dart';
import '../select_pet_screen.dart';

class MedicalHomeScreen extends StatefulWidget {
  const MedicalHomeScreen({super.key});

  @override
  State<MedicalHomeScreen> createState() => _MedicalHomeScreenState();
}

class _MedicalHomeScreenState extends State<MedicalHomeScreen> {
  late final String _currentUserId;
  late final MedicalProvider _medicalProvider;

  void _getMedicalList() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _medicalProvider.getMedicalList(uid: _currentUserId);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  void _onFloatingButtonPressed() {
    if (context.read<PetState>().petList.isEmpty) {
      showCustomDialog(
        context: context,
        title: '진료기록',
        message: '반려동물을 추가해주세요.',
        hasCancelButton: false,
        onConfirm: () => Navigator.pop(context),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectPetScreen(isMedical: true),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<User>().uid;
    _medicalProvider = context.read<MedicalProvider>();
    _getMedicalList();
  }

  @override
  Widget build(BuildContext context) {
    MedicalState medicalState = context.watch<MedicalState>();
    List<MedicalModel> medicalList = medicalState.medicalList;

    bool isLoading = medicalState.medicalStatus == MedicalStatus.fetching;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
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
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Palette.subGreen))
          : RefreshIndicator(
              color: Palette.subGreen,
              backgroundColor: Palette.white,
              onRefresh: () async => _getMedicalList(),
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: medicalList.length,
                  itemBuilder: (context, index) {
                    return MedicalHomeCardWidget(
                      medicalModel: medicalList[index],
                      index: index,
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFloatingButtonPressed,
        backgroundColor: Palette.darkGray,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(Icons.edit, color: Palette.white),
      ),
    );
  }
}
