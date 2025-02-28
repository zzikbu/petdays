import 'package:go_router/go_router.dart';

import '../../../common/screens/select_pet_screen.dart';
import '../../../models/medical_model.dart';
import '../../../models/pet_model.dart';
import '../../../screens/diary/diary_detail_screen.dart';
import '../../../screens/diary/diary_home_screen.dart';
import '../../../screens/home/home_screen.dart';
import '../../../screens/medical/medical_detail_screen.dart';
import '../../../screens/medical/medical_home_screen.dart';
import '../../../screens/medical/medical_upload_screen.dart';
import '../../../screens/pet/pet_detail_screen.dart';
import '../../../screens/pet/pet_upload_screen.dart';
import '../../../screens/walk/walk_detail_screen.dart';
import '../../../screens/walk/walk_home_screen.dart';
import '../../enums/select_pet_for.dart';
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
                final petModel = state.extra as PetModel;
                return PetUploadScreen(originalPetModel: petModel);
              },
            ),
          ],
        ),

        // 산책
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

        // 성장일기
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

        // 진료기록
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'medical',
          builder: (_, __) => const MedicalHomeScreen(),
          routes: [
            GoRoute(
              parentNavigatorKey: NavigatorKeys.root,
              path: 'select_pet',
              builder: (_, __) => const SelectPetScreen(type: SelectPetFor.medical),
              routes: [
                GoRoute(
                  parentNavigatorKey: NavigatorKeys.root,
                  path: 'upload',
                  builder: (_, state) {
                    final selectedPet = state.extra as PetModel;
                    return MedicalUploadScreen(selectedPet: selectedPet);
                  },
                ),
              ],
            ),
            GoRoute(
              parentNavigatorKey: NavigatorKeys.root,
              path: 'detail/:index',
              builder: (_, state) {
                final index = int.parse(state.pathParameters['index'] ?? '0');
                return MedicalDetailScreen(
                  index: index,
                  fromHome: false,
                );
              },
              routes: [
                GoRoute(
                  parentNavigatorKey: NavigatorKeys.root,
                  path: 'edit',
                  builder: (_, state) {
                    final medicalModel = state.extra as MedicalModel;
                    return MedicalUploadScreen(
                      originalMedicalModel: medicalModel,
                      selectedPet: medicalModel.pet,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'medical_detail/:index',
          builder: (_, state) {
            final index = int.parse(state.pathParameters['index'] ?? '0');
            return MedicalDetailScreen(
              index: index,
              fromHome: true,
            );
          },
          routes: [
            GoRoute(
              parentNavigatorKey: NavigatorKeys.root,
              path: 'edit',
              builder: (_, state) {
                final medicalModel = state.extra as MedicalModel;
                return MedicalUploadScreen(
                  originalMedicalModel: medicalModel,
                  selectedPet: medicalModel.pet,
                );
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
