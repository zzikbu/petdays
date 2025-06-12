import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../common/widgets/pd_circle_avatar.dart';
import '../../../domain/model/walk_model.dart';
import '../../../palette.dart';

class WalkListCard extends StatelessWidget {
  final WalkModel walkModel;
  final int index;

  const WalkListCard({
    super.key,
    required this.walkModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/home/walk_detail/$index'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 70,
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
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 날짜
              Text(
                DateFormat('yyyy-MM-dd E', 'ko_KR').format(walkModel.createdAt.toDate()),
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Palette.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 10),

              // 사진
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: SingleChildScrollView(
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        walkModel.pets.length,
                        (index) {
                          final petModel = walkModel.pets[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: PDCircleAvatar(
                              imageUrl: petModel.image,
                              size: 36,
                            ),
                          );
                        },
                      ),
                    ),
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
