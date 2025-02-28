import 'package:go_router/go_router.dart';

import '../../../screens/my/delete_account_screen.dart';
import '../../../screens/my/like_home_screen.dart';
import '../../../screens/my/mypage_screen.dart';
import '../../../screens/my/open_diary_home_screen.dart';
import '../../../screens/my/terms_policy_screen.dart';
import '../../../screens/my/update_nickname_screen.dart';
import '../../../screens/pet/pet_upload_screen.dart';
import '../navigator_keys.dart';

final StatefulShellBranch myBranch = StatefulShellBranch(
  navigatorKey: NavigatorKeys.myTab,
  routes: [
    GoRoute(
      path: '/my',
      builder: (_, __) => const MyPageScreen(),
      routes: [
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'update_nickname',
          builder: (_, __) => const UpdateNicknameScreen(),
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'add_pet',
          builder: (_, __) => const PetUploadScreen(),
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'open_diary',
          builder: (_, __) => const OpenDiaryHomeScreen(),
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'like_diary',
          builder: (_, __) => const LikeHomeScreen(),
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'terms',
          builder: (_, __) => const TermsPolicyScreen(isTerms: true),
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'policy',
          builder: (_, __) => const TermsPolicyScreen(isTerms: false),
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'delete_account',
          builder: (_, __) => const DeleteAccountScreen(),
        ),
      ],
    ),
  ],
);
