import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../common/screens/frame_screen.dart';
import '../../presentation/sign_in/reset_password_screen.dart';
import '../../presentation/sign_in/sign_in_screen.dart';
import '../../presentation/sign_up/sign_up_email_screen.dart';
import 'branches/feed_branch.dart';
import 'branches/home_branch.dart';
import 'branches/my_branch.dart';
import 'navigator_keys.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  navigatorKey: NavigatorKeys.root,
  redirect: (context, state) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null && state.matchedLocation != '/') {
      return '/';
    }

    if (user != null && state.matchedLocation == '/') {
      return '/home';
    }

    return null;
  },
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
