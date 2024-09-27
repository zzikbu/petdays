import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pet_log/components/custom_bottom_navigation_bar.dart';
import 'package:pet_log/router.dart';
import 'package:pet_log/service/auth_service.dart';
import 'package:pet_log/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  SharedPreferences prefs =
      await SharedPreferences.getInstance(); // shared_preferences 인스턴스 생성

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Provider를 이용하여 위젯 트리의 최상단에
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService(prefs)),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
      // 자동 로그인 분기 처리
      // home: user == null ? SignInPage() : CustomBottomNavigationBar(),
    );
  }
}
