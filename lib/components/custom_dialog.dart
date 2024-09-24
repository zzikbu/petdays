import 'package:flutter/material.dart';

import '../pallete.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final bool hasCancelButton;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.hasCancelButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Pallete.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Pallete.black,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Pallete.mediumGray,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                if (hasCancelButton) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Pallete.lightGray,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            '취소',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Pallete.black,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onConfirm();
                      // Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Pallete.mainGreen,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Center(
                        child: Text(
                          '확인',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Pallete.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
