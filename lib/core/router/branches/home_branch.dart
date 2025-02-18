import 'package:go_router/go_router.dart';

import '../../../screens/home/home_screen.dart';
import '../navigator_keys.dart';

final StatefulShellBranch homeBranch = StatefulShellBranch(
  navigatorKey: NavigatorKeys.homeTab,
  routes: [
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
  ],
);
