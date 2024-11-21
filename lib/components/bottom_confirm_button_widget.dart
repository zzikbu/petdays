import 'package:flutter/material.dart';

import '../palette.dart';

class BottomConfirmButtonWidget extends StatelessWidget {
  final bool isActive;
  final VoidCallback onConfirm;
  final String buttonText;

  const BottomConfirmButtonWidget({
    super.key,
    required this.isActive,
    required this.onConfirm,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = isActive ? Palette.white : Palette.subGreen;

    return GestureDetector(
      onTap: isActive ? onConfirm : null,
      child: Container(
        height: 84,
        width: MediaQuery.of(context).size.width,
        color: Palette.mainGreen,
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
