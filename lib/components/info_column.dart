import 'package:flutter/cupertino.dart';

import '../pallete.dart';

class InfoColumn extends StatelessWidget {
  final String title;
  final String content;

  const InfoColumn({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Pallete.mediumGray,
            letterSpacing: -0.35,
          ),
        ),
        SizedBox(height: 4), // 텍스트 간의 간격 추가
        Text(
          content,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Pallete.black,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
