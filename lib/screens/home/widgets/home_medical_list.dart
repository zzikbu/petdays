import 'package:flutter/material.dart';

import '../../../models/medical_model.dart';
import '../../medical/s_medical_home.dart';
import '../../../components/pd_title_with_more_button.dart';
import 'home_content_empty.dart';
import 'home_medical_list_card.dart';

class HomeMedicalList extends StatelessWidget {
  final List<MedicalModel> medicalList;

  const HomeMedicalList({
    super.key,
    required this.medicalList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PDTitleWithMoreButton(
          title: '진료기록',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MedicalHomeScreen()),
            );
          },
        ),
        const SizedBox(height: 10),
        medicalList.isEmpty
            ? const HomeContentEmpty(title: '진료기록이 없습니다')
            : SingleChildScrollView(
                primary: false,
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    medicalList.length,
                    (index) => HomeMedicalListCard(
                      medicalModel: medicalList[index],
                      index: index,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
