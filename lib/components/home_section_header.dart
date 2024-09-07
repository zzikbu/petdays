import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../pallete.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  final Function() onTap;

  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Pallete.black,
            letterSpacing: -0.5,
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(
                "더 보기",
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Pallete.mediumGray,
                  letterSpacing: -0.3,
                ),
              ),
              SvgPicture.asset(
                'assets/icons/ic_home_more.svg',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
