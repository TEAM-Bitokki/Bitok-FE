import 'package:go_router/go_router.dart';

import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import 'main_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const String home = '/home';
  static const String explore = '/explore';
}

// 바텀 네비게이션이 필요한 화면은 StatefulShellRoute의 branch에만 추가합니다.
// 그 외 화면은 routes 최상위에 GoRoute로 추가하면 네비게이션 바 없이 표시됩니다.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => const ExploreScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
