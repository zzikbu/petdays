import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:petdays/models/medical_model.dart';

import '../../palette.dart';
import 's_medical_detail.dart';

class MedicalHomeCardWidget extends StatelessWidget {
  final MedicalModel medicalModel;
  final int index;

  const MedicalHomeCardWidget({
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
              builder: (context) => MedicalDetailScreen(index: index)),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 20),
            height: 110,
            decoration: BoxDecoration(
              color: Palette.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Palette.black.withOpacity(0.05),
                  offset: Offset(8, 8),
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
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Palette.lightGray,
                            width: 0.4,
                          ),
                          image: DecorationImage(
                            image: ExtendedNetworkImageProvider(
                              medicalModel.pet.image,
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),

                      // 이름
                      Text(
                        medicalModel.pet.name,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Palette.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(width: 8),

                      // 방문날짜
                      Text(
                        medicalModel.visitedDate,
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Palette.mediumGray,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),

                  // 이유
                  Text(
                    medicalModel.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
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
            Positioned(
              top: 10,
              right: 16,
              child: Icon(Icons.sticky_note_2_outlined),
            ),
        ],
      ),
    );
  }
}
