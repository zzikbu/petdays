import 'package:flutter/material.dart';
import 'package:pet_log/palette.dart';

class WalkMapPage extends StatelessWidget {
  const WalkMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Palette.white,
              child: Center(
                child: Text(
                  '지도',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 74,
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: Palette.mainGreen,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    Text(
                      '00:00:00',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w600,
                        fontSize: 28,
                        color: Palette.white,
                        letterSpacing: -0.7,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        print('산책 종료 눌림');
                      },
                      icon: Icon(Icons.square),
                      color: Palette.white,
                      iconSize: 46,
                      highlightColor: Colors.transparent, // 꾹 눌렀을 때 애니메이션 제거
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
