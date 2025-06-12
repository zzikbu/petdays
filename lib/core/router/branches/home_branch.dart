import 'package:go_router/go_router.dart';
import 'package:petdays/domain/model/diary_model.dart';

import '../../../common/screens/select_pet_screen.dart';
import '../../../domain/model/medical_model.dart';
import '../../../domain/model/pet_model.dart';
import '../../../presentation/diary/diary_detail_screen.dart';
import '../../../presentation/diary/diary_home_screen.dart';
import '../../../presentation/diary/diary_upload_screen.dart';
import '../../../presentation/home/home_screen.dart';
import '../../../presentation/medical/medical_detail_screen.dart';
import '../../../presentation/medical/medical_home_screen.dart';
import '../../../presentation/medical/medical_upload_screen.dart';
import '../../../presentation/pet/pet_detail_screen.dart';
import '../../../presentation/pet/pet_upload_screen.dart';
import '../../../presentation/walk/walk_detail_screen.dart';
import '../../../presentation/walk/walk_home_screen.dart';
import '../../../presentation/walk/walk_map_screen.dart';
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
          path: 'walk',
          builder: (_, __) => const WalkHomeScreen(),
          routes: [
            GoRoute(
              parentNavigatorKey: NavigatorKeys.root,
              path: 'select_pet',
              builder: (_, __) => const SelectPetScreen(type: SelectPetFor.walk),
              routes: [
                GoRoute(
                  parentNavigatorKey: NavigatorKeys.root,
                  path: 'map',
                  builder: (_, state) {
                    final selectedPets = state.extra as List<PetModel>;
                    return WalkMapScreen(selectedPets: selectedPets);
                  },
                ),
              ],
            ),
            GoRoute(
              parentNavigatorKey: NavigatorKeys.root,
              path: 'detail/:index',
              builder: (_, state) {
                final index = int.parse(state.pathParameters['index'] ?? '0');
                return WalkDetailScreen(
                  index: index,
                  isFromHome: false,
                );
              },
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'walk_detail/:index',
          builder: (_, state) {
            final index = int.parse(state.pathParameters['index'] ?? '0');
            return WalkDetailScreen(
              index: index,
              isFromHome: true,
            );
          },
        ),

        // 성장일기
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'diary',
          builder: (_, __) => const DiaryHomeScreen(),
          routes: [
            GoRoute(
              parentNavigatorKey: NavigatorKeys.root,
              path: 'upload',
              builder: (_, __) => const DiaryUploadScreen(),
            ),
            GoRoute(
              parentNavigatorKey: NavigatorKeys.root,
              path: 'detail/:index',
              builder: (_, state) {
                final index = int.parse(state.pathParameters['index'] ?? '0');
                return DiaryDetailScreen(
                  index: index,
                  diaryType: DiaryType.my,
                  isFromHome: false,
                );
              },
              routes: [
                GoRoute(
                  parentNavigatorKey: NavigatorKeys.root,
                  path: 'edit',
                  builder: (_, state) {
                    final dialyModel = state.extra as DiaryModel;
                    return DiaryUploadScreen(
                      isEditMode: true,
                      originalDiaryModel: dialyModel,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'diary_detail/:index',
          builder: (_, state) {
            final index = int.parse(state.pathParameters['index'] ?? '0');
            return DiaryDetailScreen(
              index: index,
              diaryType: DiaryType.my,
              isFromHome: true,
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
