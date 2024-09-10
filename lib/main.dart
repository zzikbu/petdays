import 'package:flutter/material.dart';
import 'package:pet_log/feed/feed_home_page.dart';
import 'package:pet_log/mypage/mypage_page.dart';
import 'package:pet_log/pallete.dart';
import 'package:pet_log/sign_up/sign_up_nickname_page.dart';

import 'home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: SignUpNicknamePage(),
      // home: Scaffold(
      //   resizeToAvoidBottomInset: false,
      //   body: IndexedStack(
      //     index: currentIndex, // index 순서에 해당하는 child를 맨 위에 보여줌
      //     children: [
      //       FeedHomePage(),
      //       HomePage(),
      //       MypagePage(),
      //     ],
      //   ),
      //   bottomNavigationBar: NavigationBar(
      //     height: 60,
      //     backgroundColor: Pallete.white,
      //     selectedIndex: currentIndex, // 현재 보여주는 탭
      //     onDestinationSelected: (newIndex) {
      //       print("selected newIndex : $newIndex");
      //       // 다른 페이지로 이동
      //       setState(() {
      //         currentIndex = newIndex;
      //       });
      //     },
      //     destinations: [
      //       NavigationDestination(icon: Icon(Icons.feed_outlined), label: "피드"),
      //       NavigationDestination(icon: Icon(Icons.home), label: "홈"),
      //       NavigationDestination(icon: Icon(Icons.person), label: "MY"),
      //     ],
      //   ),
      // ),
    );
  }
}
