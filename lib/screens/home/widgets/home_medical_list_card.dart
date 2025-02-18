import 'package:flutter/material.dart';

import '../../../components/pd_ circle_avatar.dart';
import '../../../models/medical_model.dart';
import '../../../palette.dart';
import '../../medical/medical_detail_screen.dart';

class HomeMedicalListCard extends StatelessWidget {
  final MedicalModel medicalModel;
  final int index;

  const HomeMedicalListCard({
    super.key,
    required this.medicalModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MedicalDetailScreen(index: index),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 10),
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          color: Palette.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Palette.black.withOpacity(0.05),
              offset: const Offset(8, 8),
              blurRadius: 8,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 사진
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: PDCircleAvatar(
                      imageUrl: medicalModel.pet.image,
                      size: 36,
                    ),
                  ),

                  // 이름
                  Expanded(
                    child: Text(
                      medicalModel.pet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Palette.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 방문 날짜
              Text(
                medicalModel.visitedDate,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Palette.mediumGray,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),

              // 이유
              Text(
                medicalModel.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: Palette.black,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
