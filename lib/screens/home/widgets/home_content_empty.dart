import 'package:flutter/material.dart';

import '../../../palette.dart';

class HomeContentEmpty extends StatelessWidget {
  final String title;

  const HomeContentEmpty({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Palette.mediumGray,
            letterSpacing: -0.4,
          ),
        ),
      ),
    );
  }
}
