import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pet_log/components/custom_dialog.dart';
import 'package:pet_log/components/info_column.dart';
import 'package:pet_log/models/medical_model.dart';
import 'package:pet_log/palette.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MedicalDetailScreen extends StatefulWidget {
  final MedicalModel medicalModel;

  const MedicalDetailScreen({
    super.key,
    required this.medicalModel,
  });

  @override
  State<MedicalDetailScreen> createState() => _MedicalDetailScreenState();
}

class _MedicalDetailScreenState extends State<MedicalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         MedicalWritePage(isEditMode: true),
                    //   ),
                    // );
                  },
                ),
                PullDownMenuItem(
                  title: '삭제하기',
                  isDestructive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialog(
                          title: '진료기록 삭제',
                          message: '진료기록을 삭제하면 복구 할 수 없습니다.\n삭제하시겠습니까?',
                          onConfirm: () {
                            print('삭제됨');
                          },
                        );
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
      backgroundColor: Palette.background,
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              InfoColumn(
                title: '진료받은 반려동물',
                content: widget.medicalModel.pet.name,
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '진료일',
                content: widget.medicalModel.visitDate,
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '이유',
                content: widget.medicalModel.reason,
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '병원',
                content: widget.medicalModel.hospital.isEmpty
                    ? "-"
                    : widget.medicalModel.hospital,
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '수의사',
                content: widget.medicalModel.doctor.isEmpty
                    ? "-"
                    : widget.medicalModel.doctor,
              ),
              SizedBox(height: 20),
              InfoColumn(
                title: '메모',
                content: widget.medicalModel.note.isEmpty
                    ? "-"
                    : widget.medicalModel.note,
              ),
              SizedBox(height: 10),

              // 사진
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                primary: false,
                itemCount: widget.medicalModel.imageUrls.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: 300,
                    width: 300,
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: ExtendedNetworkImageProvider(
                            widget.medicalModel.imageUrls[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
