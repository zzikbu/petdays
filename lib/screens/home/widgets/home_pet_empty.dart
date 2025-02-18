import 'package:flutter/material.dart';

import '../../../palette.dart';
import '../../pet/pet_upload_screen.dart';

class HomePetEmpty extends StatelessWidget {
  const HomePetEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PetUploadScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 24, top: 68, right: 24, bottom: 42),
        decoration: BoxDecoration(
          color: Palette.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 32,
              color: Palette.black,
            ),
            SizedBox(height: 4),
            Text(
              '반려동물 추가하기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: Palette.black,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
