import 'package:go_router/go_router.dart';

import '../../../screens/my/mypage_screen.dart';
import '../navigator_keys.dart';

final StatefulShellBranch myBranch = StatefulShellBranch(
  navigatorKey: NavigatorKeys.myTab,
  routes: [
    GoRoute(
      path: '/my',
      builder: (_, __) => const MyPageScreen(),
    ),
  ],
);
