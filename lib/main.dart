import 'package:flutter/material.dart';
import 'package:pet_log/sign_in/sign_in_page.dart';
import 'package:pet_log/sign_up/sign_up_nickname_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const Scaffold(
        resizeToAvoidBottomInset: false,
        body: SignUpNicknamePage(),
      ),
    );
  }
}
