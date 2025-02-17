import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:petdays/screens/spalash_screen.dart';

import '../../screens/frame_screen.dart';
import '../../screens/sign_in/reset_password_screen.dart';
import '../../screens/sign_in/sign_in_screen.dart';
import '../../screens/sign_up/sign_up_email_screen.dart';
import 'branches/feed_branch.dart';
import 'branches/home_branch.dart';
import 'branches/my_branch.dart';
import 'navigator_keys.dart';

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
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: NavigatorKeys.root,
      builder: (_, __, navigationShell) {
        return FrameScreen(navigationShell: navigationShell);
      },
      branches: [
        feedBranch,
        homeBranch,
        myBranch,
      ],
    ),
  ],
);
