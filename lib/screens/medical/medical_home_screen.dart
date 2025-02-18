import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widgets/pd_app_bar.dart';
import '../../common/widgets/pd_floating_button.dart';
import '../../common/widgets/pd_loading_circular.dart';
import '../../common/widgets/pd_refresh_indicator.dart';
import '../../common/widgets/show_custom_dialog.dart';
import '../../common/widgets/show_error_dialog.dart';
import '../../core/enums/select_pet_for.dart';
import '../../exceptions/custom_exception.dart';
import '../../models/medical_model.dart';
import '../../palette.dart';
import '../../providers/medical/medical_provider.dart';
import '../../providers/medical/medical_state.dart';
import '../../providers/pet/pet_state.dart';
import '../../common/screens/select_pet_screen.dart';
import 'widgets/medical_home_list_card.dart';

class MedicalHomeScreen extends StatefulWidget {
  const MedicalHomeScreen({super.key});

  @override
  State<MedicalHomeScreen> createState() => _MedicalHomeScreenState();
}

class _MedicalHomeScreenState extends State<MedicalHomeScreen> {
  void _getData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final currentUserId = context.read<User>().uid;
        await context.read<MedicalProvider>().getMedicalList(uid: currentUserId);
      } on CustomException catch (e) {
        showErrorDialog(context, e);
      }
    });
  }

  void _onAddPress() {
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
          builder: (context) => const SelectPetScreen(type: SelectPetFor.medical),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    MedicalState medicalState = context.watch<MedicalState>();
    List<MedicalModel> medicalList = medicalState.medicalList;

    bool isLoading = medicalState.medicalStatus == MedicalStatus.fetching;

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: const PDAppBar(titleText: '진료기록'),
      body: isLoading
          ? const PDLoadingCircular()
          : PDRefreshIndicator(
              onRefresh: () async => _getData(),
              child: Scrollbar(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: medicalList.length,
                  itemBuilder: (context, index) {
                    return MedicalHomeListCard(
                      medicalModel: medicalList[index],
                      index: index,
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: PDFloatingButton(onPressed: _onAddPress),
    );
  }
}
