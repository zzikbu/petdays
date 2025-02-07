import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../screens/sign_in/reset_password_screen.dart';
import '../../screens/sign_in/sign_in_screen.dart';
import '../../screens/sign_up/sign_up_email_screen.dart';

class NavigatorKeys {
  static final root = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final homeTab = GlobalKey<NavigatorState>(debugLabel: 'homeTab');
  static final feedTab = GlobalKey<NavigatorState>(debugLabel: 'feedTab');
  static final myTab = GlobalKey<NavigatorState>(debugLabel: 'myTab');
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: NavigatorKeys.root,
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SignInScreen(),
      routes: [
        GoRoute(
          path: 'reset_password',
          builder: (_, __) => const ResetPasswordScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/sign_up_email',
      builder: (_, __) => const SignupEmailScreen(),
    ),
    // StatefulShellRoute.indexedStack(
    //   parentNavigatorKey: NavigatorKeys.root,
    //   builder: (_, __, navigationShell) {
    //     return FrameScreen(navigationShell: navigationShell);
    //   },
    //   branches: [
    //     homeBranch,
    //     collectionBranch,
    //     diaryBranch,
    //     communityBranch,
    //   ],
    // ),
  ],
);
