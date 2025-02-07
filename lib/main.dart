import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_state_notifier/flutter_state_notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:petdays/core/router/app_router.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth/auth_state.dart';
import 'providers/auth/my_auth_provider.dart';
import 'providers/diary/diary_provider.dart';
import 'providers/diary/diary_state.dart';
import 'providers/feed/feed_provider.dart';
import 'providers/feed/feed_state.dart';
import 'providers/home/home_provider.dart';
import 'providers/home/home_state.dart';
import 'providers/like/like_provider.dart';
import 'providers/like/like_state.dart';
import 'providers/medical/medical_provider.dart';
import 'providers/medical/medical_state.dart';
import 'providers/pet/pet_provider.dart';
import 'providers/pet/pet_state.dart';
import 'providers/profile/profile_provider.dart';
import 'providers/profile/profile_state.dart';
import 'providers/walk/walk_provider.dart';
import 'providers/walk/walk_state.dart';
import 'repositories/auth_repository.dart';
import 'repositories/diary_repository.dart';
import 'repositories/feed_repository.dart';
import 'repositories/like_repository.dart';
import 'repositories/medical_repository.dart';
import 'repositories/pet_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/walk_repository.dart';
import 'screens/spalash_screen.dart';

late final PackageInfo packageInfo;

void main() async {
  WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized(); // main 함수에서 async 사용하기 위함

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  packageInfo = await PackageInfo.fromPlatform();

  FlutterNativeSplash.remove();

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
            firebaseFirestore: FirebaseFirestore.instance,
            firebaseStorage: FirebaseStorage.instance,
          ),
        ),
        Provider<PetRepository>(
          create: (context) => PetRepository(
            firebaseStorage: FirebaseStorage.instance,
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<WalkRepository>(
          create: (context) => WalkRepository(
            firebaseStorage: FirebaseStorage.instance,
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<FeedRepository>(
          create: (context) => FeedRepository(
            firebaseStorage: FirebaseStorage.instance,
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<DiaryRepository>(
          create: (context) => DiaryRepository(
            firebaseStorage: FirebaseStorage.instance,
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<MedicalRepository>(
          create: (context) => MedicalRepository(
            firebaseStorage: FirebaseStorage.instance,
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<ProfileRepository>(
          create: (context) => ProfileRepository(
            firebaseStorage: FirebaseStorage.instance,
            firebaseFirestore: FirebaseFirestore.instance,
          ),
        ),
        Provider<LikeRepository>(
          create: (context) => LikeRepository(
            firebaseFirestore: FirebaseFirestore.instance,
          ),
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
        StateNotifierProvider<PetProvider, PetState>(
          create: (context) => PetProvider(),
        ),
        StateNotifierProvider<WalkProvider, WalkState>(
          create: (context) => WalkProvider(),
        ),
        StateNotifierProvider<FeedProvider, FeedState>(
          create: (context) => FeedProvider(),
        ),
        StateNotifierProvider<DiaryProvider, DiaryState>(
          create: (context) => DiaryProvider(),
        ),
        StateNotifierProvider<MedicalProvider, MedicalState>(
          create: (context) => MedicalProvider(),
        ),
        StateNotifierProvider<HomeProvider, HomeState>(
          create: (context) => HomeProvider(),
        ),
        StateNotifierProvider<ProfileProvider, ProfileState>(
          create: (context) => ProfileProvider(),
        ),
        StateNotifierProvider<LikeProvider, LikeState>(
          create: (context) => LikeProvider(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
        ],
      ),
    );
  }
}
