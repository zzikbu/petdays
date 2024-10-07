import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:pet_log/providers/auth/auth_state.dart';
import 'package:pet_log/providers/auth/my_auth_provider.dart';
import 'package:pet_log/repositories/auth_repository.dart';
import 'package:pet_log/spalash_page.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
    // FirebaseAuth.instance.signOut(); // 로그아웃 테스트 할 때
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(
          create: (context) => AuthRepository(
              firebaseAuth: FirebaseAuth.instance,
              firebaseFirestore: FirebaseFirestore.instance),
        ),
        StreamProvider<User?>(
          // ‼️앱 자체에서 인증상태를 변경하는게 아닌,
          // 파이어베이스 인증상태의 변화에 따라 앱의 인증상태를 변경하게 하기 위함‼️
          // 로그인 한 유저의 (인증)상태를 실시간으로 모니터링 (Stream)
          // 로그인 했으면 User 데이터를 로그아웃이면 null 반환
          create: (context) => FirebaseAuth.instance.authStateChanges(),
          // Stream은 비동기로 동작하기 때문에
          // authStateChanges 함수를 최초로 호출해서 데이터를 가져오기 까지 시간이 걸림
          // 그 시간 동안에 미리 전달해 줄 데이터 지정
          initialData: null,
        ),
        StateNotifierProvider<MyAuthProvider, AuthState>(
          create: (context) => MyAuthProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true),
        home: SplashPage(),
      ),
    );
  }
}
