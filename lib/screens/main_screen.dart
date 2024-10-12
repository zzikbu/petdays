import 'package:flutter/material.dart';
import 'package:pet_log/palette.dart';
import 'package:pet_log/screens/feed/feed_home_screen.dart';
import 'package:pet_log/screens/home/home_screen.dart';
import 'package:pet_log/screens/mypage/mypage_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex, // index 순서에 해당하는 child를 맨 위에 보여줌
        children: [
          FeedHomeScreen(),
          HomeScreen(),
          MypagePageScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        height: 60,
        backgroundColor: Palette.white,
        selectedIndex: currentIndex, // 현재 보여주는 탭
        onDestinationSelected: (newIndex) {
          print("selected newIndex : $newIndex");
          // 다른 페이지로 이동
          setState(() {
            currentIndex = newIndex;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.feed_outlined), label: "피드"),
          NavigationDestination(icon: Icon(Icons.home), label: "홈"),
          NavigationDestination(icon: Icon(Icons.person), label: "MY"),
        ],
      ),
    );
  }
}
