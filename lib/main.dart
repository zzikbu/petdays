import 'package:flutter/material.dart';
import 'package:pet_log/components/custom_bottom_navigation_bar.dart';
import 'package:pet_log/sign_in/sign_in_page.dart';
import 'package:pet_log/sign_up/sign_up_nickname_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      // home: CustomBottomNavigationBar(),
      home: SignInPage(),
    );
  }
}
