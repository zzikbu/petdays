import 'package:flutter/material.dart';

import '../pallete.dart';

class NextButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final String buttonText;

  const NextButton({
    super.key,
    required this.isActive,
    required this.onTap,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = isActive ? Pallete.white : Pallete.subGreen;

    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        height: 94,
        width: MediaQuery.of(context).size.width,
        color: Pallete.mainGreen,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              buttonText,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: textColor, // Use the determined textColor
              ),
            ),
          ),
        ),
      ),
    );
  }
}
