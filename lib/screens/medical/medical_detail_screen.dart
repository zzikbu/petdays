import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../common/widgets/pd_app_bar.dart';
import '../../common/widgets/pd_content_with_title.dart';
import '../../common/widgets/show_custom_dialog.dart';
import '../../models/medical_model.dart';
import '../../palette.dart';
import '../../providers/medical/medical_provider.dart';
import '../../providers/medical/medical_state.dart';
import 'medical_upload_screen.dart';

class MedicalDetailScreen extends StatelessWidget {
  final int index;

  const MedicalDetailScreen({
    super.key,
    required this.index,
  });

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    MedicalModel medicalModel,
  ) {
    return PDAppBar(
      actions: [
        PullDownButton(
          itemBuilder: (context) => _buildMenuItems(context, medicalModel),
          buttonBuilder: _buildMenuButton,
        ),
      ],
    );
  }

  List<PullDownMenuItem> _buildMenuItems(
    BuildContext context,
    MedicalModel medicalModel,
  ) {
    return [
      PullDownMenuItem(
        title: '수정하기',
        onTap: () => _onEditTap(context, medicalModel),
      ),
      PullDownMenuItem(
        title: '삭제하기',
        isDestructive: true,
        onTap: () => _onDeleteTap(context, medicalModel),
      ),
    ];
  }

  Widget _buildMenuButton(BuildContext context, VoidCallback showMenu) {
    return IconButton(
      onPressed: showMenu,
      icon: const Icon(
        Icons.more_vert,
        size: 26,
      ),
    );
  }

  void _onEditTap(BuildContext context, MedicalModel medicalModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MedicalUploadScreen(
          selectedPet: medicalModel.pet,
          originalMedicalModel: medicalModel,
        ),
      ),
    );
  }

  void _onDeleteTap(BuildContext context, MedicalModel medicalModel) {
    showCustomDialog(
      context: context,
      title: '진료기록 삭제',
      message: '진료기록을 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
      onConfirm: () async {
        Navigator.pop(context);
        await context.read<MedicalProvider>().deleteMedical(medicalModel: medicalModel);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    MedicalModel medicalModel = context.watch<MedicalState>().medicalList[index];

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: _buildAppBar(context, medicalModel),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 20,
            children: [
              PDContentWithTitle(
                title: '진료받은 반려동물',
                content: medicalModel.pet.name,
              ),
              PDContentWithTitle(
                title: '진료일',
                content: medicalModel.visitedDate,
              ),
              PDContentWithTitle(
                title: '이유',
                content: medicalModel.reason,
              ),
              PDContentWithTitle(
                title: '병원',
                content: medicalModel.hospital.isEmpty ? '-' : medicalModel.hospital,
              ),
              PDContentWithTitle(
                title: '수의사',
                content: medicalModel.doctor.isEmpty ? '-' : medicalModel.doctor,
              ),
              PDContentWithTitle(
                title: '메모',
                content: medicalModel.note.isEmpty ? '-' : medicalModel.note,
              ),
              ...List.generate(
                medicalModel.imageUrls.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ExtendedImage.network(
                    medicalModel.imageUrls[index],
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
