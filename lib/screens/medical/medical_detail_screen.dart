import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../components/w_detail_info_with_title.dart';
import '../../components/show_custom_dialog.dart';
import '../../models/medical_model.dart';
import '../../palette.dart';
import '../../providers/medical/medical_provider.dart';
import '../../providers/medical/medical_state.dart';
import 's_medical_upload.dart';

class MedicalDetailScreen extends StatefulWidget {
  final int index;

  const MedicalDetailScreen({
    super.key,
    required this.index,
  });

  @override
  State<MedicalDetailScreen> createState() => _MedicalDetailScreenState();
}

class _MedicalDetailScreenState extends State<MedicalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    MedicalModel medicalModel =
        context.watch<MedicalState>().medicalList[widget.index];

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PullDownButton(
              itemBuilder: (context) => [
                PullDownMenuItem(
                  title: '수정하기',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MedicalUploadScreen(
                          selectedPet: medicalModel.pet,
                          originalMedicalModel: medicalModel,
                        ),
                      ),
                    );
                  },
                ),
                PullDownMenuItem(
                  title: '삭제하기',
                  isDestructive: true,
                  onTap: () {
                    showCustomDialog(
                      context: context,
                      title: '진료기록 삭제',
                      message: '진료기록을 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
                      onConfirm: () async {
                        Navigator.pop(context);

                        await context
                            .read<MedicalProvider>()
                            .deleteMedical(medicalModel: medicalModel);

                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
              buttonBuilder: (context, showMenu) => CupertinoButton(
                onPressed: showMenu,
                padding: EdgeInsets.zero,
                child: SvgPicture.asset('assets/icons/ic_more.svg'),
              ),
            ),
          ),
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailInfoWithTitleWidget(
                title: '진료받은 반려동물',
                content: medicalModel.pet.name,
              ),
              SizedBox(height: 20),

              DetailInfoWithTitleWidget(
                title: '진료일',
                content: medicalModel.visitedDate,
              ),
              SizedBox(height: 20),

              DetailInfoWithTitleWidget(
                title: '이유',
                content: medicalModel.reason,
              ),
              SizedBox(height: 20),

              DetailInfoWithTitleWidget(
                title: '병원',
                content:
                    medicalModel.hospital.isEmpty ? '-' : medicalModel.hospital,
              ),
              SizedBox(height: 20),

              DetailInfoWithTitleWidget(
                title: '수의사',
                content:
                    medicalModel.doctor.isEmpty ? '-' : medicalModel.doctor,
              ),
              SizedBox(height: 20),

              DetailInfoWithTitleWidget(
                title: '메모',
                content: medicalModel.note.isEmpty ? '-' : medicalModel.note,
              ),
              SizedBox(height: 20),

              // 사진
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                itemCount: medicalModel.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 300,
                    width: 300,
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(0),
                      image: DecorationImage(
                        image: ExtendedNetworkImageProvider(
                            medicalModel.imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
