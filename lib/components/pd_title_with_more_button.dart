import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../palette.dart';

class PDTitleWithMoreButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const PDTitleWithMoreButton({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Palette.black,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const Text(
            "더 보기",
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Palette.mediumGray,
              letterSpacing: -0.3,
            ),
          ),
          SvgPicture.asset('assets/icons/ic_home_more.svg'),
        ],
      ),
    );
  }
}
