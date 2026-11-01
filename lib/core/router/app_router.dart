import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_allergies_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_diet_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_nickname_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_review_screen.dart';
import 'main_shell.dart';

class AppRoutes {
  const AppRoutes._();

  static const String login = '/login';
  static const String home = '/home';
  static const String explore = '/explore';

  // 온보딩: 처음 로그인한 사용자에게만 보여줍니다.
  static const String onboardingNickname = '/onboarding/nickname';
  static const String onboardingAllergies = '/onboarding/allergies';
  static const String onboardingDiet = '/onboarding/diet';
  static const String onboardingReview = '/onboarding/review';
  static const String onboardingComplete = '/onboarding/complete';
}

// 바텀 네비게이션이 필요한 화면은 StatefulShellRoute의 branch에만 추가합니다.
// 그 외 화면은 routes 최상위에 GoRoute로 추가하면 네비게이션 바 없이 표시됩니다.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    // 온보딩 단계는 push로 쌓아 뒤로가기로 이전 단계에 돌아갈 수 있게 하고,
    // 완료 화면은 go로 이동해 이전 단계 스택을 비웁니다.
    GoRoute(
      path: AppRoutes.onboardingNickname,
      builder: (context, state) => const OnboardingNicknameScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingAllergies,
      builder: (context, state) => const OnboardingAllergiesScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingDiet,
      builder: (context, state) => const OnboardingDietScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingReview,
      builder: (context, state) => const OnboardingReviewScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingComplete,
      builder: (context, state) => const OnboardingCompleteScreen(),
    ),
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
