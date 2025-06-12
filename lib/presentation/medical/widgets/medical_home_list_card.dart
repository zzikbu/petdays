import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../common/widgets/pd_circle_avatar.dart';
import '../../../domain/model/medical_model.dart';
import '../../../palette.dart';

class MedicalHomeListCard extends StatelessWidget {
  final MedicalModel medicalModel;
  final int index;

  const MedicalHomeListCard({
    super.key,
    required this.medicalModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/home/medical/detail/$index'),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 110,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // 사진
                      PDCircleAvatar(
                        imageUrl: medicalModel.pet.image,
                        size: 36,
                      ),
                      const SizedBox(width: 8),

                      // 이름
                      Text(
                        medicalModel.pet.name,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Palette.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 방문날짜
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
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 이유
                  Text(
                    medicalModel.reason,
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
                ],
              ),
            ),
          ),

          // 메모가 있을 경우 아이콘 표시
          if (medicalModel.note.isNotEmpty)
            const Positioned(
              top: 10,
              right: 16,
              child: Icon(
                size: 22,
                Icons.sticky_note_2_outlined,
              ),
            ),
        ],
      ),
    );
  }
}
