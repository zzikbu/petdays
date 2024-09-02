import 'package:flutter/material.dart';
import 'package:pet_log/walk/walk_map_page.dart';

import '../components/next_button.dart';
import '../pallete.dart';

class WalkSelectPetPage extends StatelessWidget {
  const WalkSelectPetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.background,
      appBar: AppBar(
        backgroundColor: Pallete.background,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  '누구와 산책하나요?',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: Pallete.black,
                    letterSpacing: -0.6,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '중복 선택이 가능합니다.',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Pallete.mediumGray,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 30),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 150, // 높이
                ),
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Pallete.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: index == 2 ? Pallete.black : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Pallete.black.withOpacity(0.05),
                          offset: Offset(8, 8),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Pallete.lightGray,
                        ),
                        SizedBox(height: 2),
                        Text(
                          '망고',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: Pallete.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: NextButton(
        isActive: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WalkMapPage()),
          );
        },
        buttonText: "시작하기",
      ),
    );
  }
}
