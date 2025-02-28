import 'package:go_router/go_router.dart';
import 'package:petdays/screens/pet/pet_upload_screen.dart';

import '../../../models/pet_model.dart';
import '../../../screens/diary/diary_detail_screen.dart';
import '../../../screens/diary/diary_home_screen.dart';
import '../../../screens/home/home_screen.dart';
import '../../../screens/medical/medical_detail_screen.dart';
import '../../../screens/medical/medical_home_screen.dart';
import '../../../screens/pet/pet_detail_screen.dart';
import '../../../screens/walk/walk_detail_screen.dart';
import '../../../screens/walk/walk_home_screen.dart';
import '../navigator_keys.dart';

final StatefulShellBranch homeBranch = StatefulShellBranch(
  navigatorKey: NavigatorKeys.homeTab,
  routes: [
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
      routes: [
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'pet_detail/:index',
          builder: (_, state) {
            final index = int.parse(state.pathParameters['index'] ?? '0');
            return PetDetailScreen(index: index);
          },
          routes: [
            GoRoute(
              parentNavigatorKey: NavigatorKeys.root,
              path: 'edit',
              builder: (_, state) {
                // extra 파라미터에서 petModel을 가져옴
                final petModel = state.extra as PetModel;
                return PetUploadScreen(originalPetModel: petModel);
              },
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'walk_home',
          builder: (_, __) => const WalkHomeScreen(),
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'walk_detail/:index',
          builder: (_, state) {
            final index = int.parse(state.pathParameters['index'] ?? '0');
            return WalkDetailScreen(index: index);
          },
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'diary_home',
          builder: (_, __) => const DiaryHomeScreen(),
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'diary_detail/:index',
          builder: (_, state) {
            final index = int.parse(state.pathParameters['index'] ?? '0');
            return DiaryDetailScreen(
              index: index,
              diaryType: DiaryType.my,
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'medical_home',
          builder: (_, __) => const MedicalHomeScreen(),
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'medical_detail/:index',
          builder: (_, state) {
            final index = int.parse(state.pathParameters['index'] ?? '0');
            return MedicalDetailScreen(index: index);
          },
        ),
      ],
    ),
  ],
);
