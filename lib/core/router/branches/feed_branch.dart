import 'package:go_router/go_router.dart';

import '../../../screens/feed/feed_home_screen.dart';
import '../navigator_keys.dart';

final StatefulShellBranch feedBranch = StatefulShellBranch(
  navigatorKey: NavigatorKeys.feedTab,
  routes: [
    GoRoute(
      path: '/feed',
      builder: (_, __) => const FeedHomeScreen(),
    ),
  ],
);
