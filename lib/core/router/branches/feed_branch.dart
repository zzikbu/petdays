import 'package:go_router/go_router.dart';

import '../../../screens/diary/diary_detail_screen.dart';
import '../../../screens/feed/feed_home_screen.dart';
import '../navigator_keys.dart';

final StatefulShellBranch feedBranch = StatefulShellBranch(
  navigatorKey: NavigatorKeys.feedTab,
  routes: [
    GoRoute(
      path: '/feed',
      builder: (_, __) => const FeedHomeScreen(),
      routes: [
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'hot/detail/:index',
          builder: (_, state) {
            final index = int.parse(state.pathParameters['index'] ?? '0');
            return DiaryDetailScreen(
              index: index,
              diaryType: DiaryType.hotFeed,
            );
          },
        ),
        GoRoute(
          parentNavigatorKey: NavigatorKeys.root,
          path: 'all/detail/:index',
          builder: (_, state) {
            final index = int.parse(state.pathParameters['index'] ?? '0');
            return DiaryDetailScreen(
              index: index,
              diaryType: DiaryType.allFeed,
            );
          },
        ),
      ],
    ),
  ],
);
