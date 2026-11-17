import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/bitok_status_chip.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/explore/presentation/models/map_restaurant.dart';
import '../../features/explore/presentation/providers/saved_restaurants_provider.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/explore/presentation/screens/restaurant_detail_screen.dart';
import '../../features/explore/presentation/screens/restaurant_select_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/mypage/presentation/screens/account_deletion_screen.dart';
import '../../features/mypage/presentation/screens/dietary_profile_screen.dart';
import '../../features/mypage/presentation/screens/edit_profile_screen.dart';
import '../../features/mypage/presentation/screens/my_page_screen.dart';
import '../../features/mypage/presentation/screens/saved_menus_screen.dart';
import '../../features/mypage/presentation/screens/saved_restaurants_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_allergies_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_diet_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_nickname_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_review_screen.dart';
import '../../features/scan/data/models/scan_restaurant.dart';
import '../../features/scan/presentation/providers/scan_flow_provider.dart';
import '../../features/scan/presentation/screens/scan_ask_staff_screen.dart';
import '../../features/scan/presentation/screens/scan_check_screen.dart';
import '../../features/scan/presentation/screens/scan_preview_screen.dart';
import '../../features/scan/presentation/screens/scan_result_screen.dart';
import '../../features/scan/presentation/screens/scan_saved_screen.dart';
import '../../features/scan/presentation/screens/scan_screen.dart';
import '../../features/scan/presentation/screens/scan_select_screen.dart';
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

  static const String myPage = '/my';
  static const String editProfile = '/my/profile';
  static const String dietaryProfile = '/my/dietary';
  static const String savedRestaurants = '/my/restaurants';
  static const String savedMenus = '/my/menus';
  static const String accountDeletion = '/my/delete-account';

  static const String foodAllergies = '/onboarding/allergies';
  static const String dietPreference = '/onboarding/diet';

  static const String restaurantDetail = '/restaurant';
  static const String restaurantSelect = '/restaurant/select';

  // 메뉴 스캔 (REST-02 ~ REST-08)
  static const String scan = '/scan';
  static const String scanPreview = '/scan/preview';
  static const String scanCheck = '/scan/check';
  static const String scanSelect = '/scan/select';
  static const String scanAskStaff = '/scan/ask-staff';
  static const String scanResult = '/scan/result';
  static const String scanSaved = '/scan/saved';
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
              builder: (context, state) => HomeScreen(
                recentChecks: _mockRecentChecks,
                onProfileTap: () => context.push(AppRoutes.myPage),
                // 식당 선택 화면은 최상위 경로라 하단 탭 없이 열립니다.
                onCheckMenuTap: () => context.push(AppRoutes.restaurantSelect),
                // TODO: 메뉴 상세 화면이 만들어지면 onRecentCheckTap을 연결합니다.
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.explore,
              builder: (context, state) => Consumer(
                builder: (context, ref, _) => ExploreScreen(
                  restaurants: mapRestaurantSamples,
                  savedIds: ref.watch(savedRestaurantIdsProvider),
                  onProfileTap: () => context.push(AppRoutes.myPage),
                  onToggleSaved: (restaurant) => ref
                      .read(savedRestaurantIdsProvider.notifier)
                      .toggle(restaurant.id),
                  onMenuResultsTap: (restaurant) => context.push(
                    AppRoutes.restaurantDetail,
                    extra: restaurant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),

    // ---- 마이페이지 (네비게이션 바 없음) ----
    // TODO: 아래 화면의 임시 데이터(_mock...)는 provider/API 연결 시 교체합니다.
    GoRoute(
      path: AppRoutes.myPage,
      builder: (context, state) => MyPageScreen(
        nickname: _mockNickname,
        email: _mockEmail,
        dietarySummary: _mockDietarySummary,
        onBack: () => context.pop(),
        onProfileTap: () => context.push(AppRoutes.editProfile),
        onDietaryTap: () => context.push(AppRoutes.dietaryProfile),
        onSavedRestaurantsTap: () => context.push(AppRoutes.savedRestaurants),
        onSavedMenusTap: () => context.push(AppRoutes.savedMenus),
        onDeleteAccountTap: () => context.push(AppRoutes.accountDeletion),
      ),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => EditProfileScreen(
        initialNickname: _mockNickname,
        onBack: () => context.pop(),
        onSave: (nickname) => context.pop(), // TODO: 닉네임 저장 API
      ),
    ),
    GoRoute(
      path: AppRoutes.dietaryProfile,
      builder: (context, state) => DietaryProfileScreen(
        allergySummary: _mockAllergySummary,
        dietSummary: _mockDietSummary,
        onBack: () => context.pop(),
        onEditAllergies: () => context.push(AppRoutes.foodAllergies),
        onEditDiet: () => context.push(AppRoutes.dietPreference),
      ),
    ),
    GoRoute(
      path: AppRoutes.savedRestaurants,
      builder: (context, state) => SavedRestaurantsScreen(
        restaurants: _mockSavedRestaurants,
        onBack: () => context.pop(),
        onRestaurantTap: (_) => context.push(AppRoutes.restaurantDetail),
      ),
    ),
    GoRoute(
      path: AppRoutes.savedMenus,
      builder: (context, state) => SavedMenusScreen(
        menus: _mockSavedMenus,
        onBack: () => context.pop(),
        // TODO: 메뉴 상세 화면이 만들어지면 연결합니다.
      ),
    ),
    GoRoute(
      path: AppRoutes.accountDeletion,
      builder: (context, state) => AccountDeletionScreen(
        onBack: () => context.pop(),
        // TODO: 탈퇴 API 연결 후 로그인 화면으로 이동합니다.
        onDelete: (deleteSavedMenus) => context.go(AppRoutes.home),
      ),
    ),

    // ---- 온보딩 (알레르기 / 식단) ----

    // ---- 식당 상세 ----
    // TODO: 식당 id를 받도록 '/restaurant/:id' 형태로 바꿉니다.
    GoRoute(
      path: AppRoutes.restaurantDetail,
      builder: (context, state) {
        // 식당 정보를 넘기지 않고 들어오면(예: 저장한 식당 목록) 임시로 샘플 식당을 보여줍니다.
        final restaurant =
            state.extra as MapRestaurant? ?? mapRestaurantSamples.last;
        return Consumer(
          builder: (context, ref, _) => RestaurantDetailScreen(
            name: restaurant.name,
            info: '${restaurant.category} · 350 m',
            // TODO: distance_m 연결
            menus: _mockCheckedMenus,
            saved: ref
                .watch(savedRestaurantIdsProvider)
                .contains(restaurant.id),
            onToggleSaved: () => ref
                .read(savedRestaurantIdsProvider.notifier)
                .toggle(restaurant.id),
            onBack: () => context.pop(),
          ),
        );
      },
    ),
    // ---- 식당 선택 (REST-01) ----
    GoRoute(
      path: AppRoutes.restaurantSelect,
      builder: (context, state) => RestaurantSelectScreen(
        restaurants: mapRestaurantSamples,
        onBack: () => context.pop(),
        onSelect: (restaurant) {
          // 이전 스캔 결과가 남지 않도록 초기화한 뒤 선택한 식당으로 스캔을 시작합니다.
          ProviderScope.containerOf(
            context,
          ).read(scanFlowProvider.notifier).reset();
          context.push(
            AppRoutes.scan,
            extra: ScanRestaurant(
              name: restaurant.name,
              category: restaurant.category,
              address: restaurant.address,
            ),
          );
        },
      ),
    ),

    // ---- 메뉴 스캔 (네비게이션 바 없음) ----
    // 진입점: 식당 선택(REST-01)의 Select. 식당 정보는 extra(ScanRestaurant)로 받습니다.
    GoRoute(
      path: AppRoutes.scan,
      builder: (context, state) => ScanScreen(
        restaurant: state.extra as ScanRestaurant? ?? _mockScanRestaurant,
        onBack: () => context.pop(),
        onImageSelected: (image) =>
            context.push(AppRoutes.scanPreview, extra: image.path),
      ),
    ),
    // extra로 선택한 이미지 경로(String)를 넘겨받습니다.
    GoRoute(
      path: AppRoutes.scanPreview,
      redirect: (context, state) =>
          state.extra is String ? null : AppRoutes.scan,
      builder: (context, state) => ScanPreviewScreen(
        imagePath: state.extra! as String,
        onBack: () => context.pop(),
        onNext: () async {
          // 라우터는 위젯 트리 밖에 있으므로 ProviderScope에서 직접 provider를 읽습니다.
          await ProviderScope.containerOf(
            context,
          ).read(scanFlowProvider.notifier).recognize(state.extra! as String);
          if (context.mounted) context.push(AppRoutes.scanCheck);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.scanCheck,
      builder: (context, state) => ScanCheckScreen(
        onBack: () => context.pop(),
        onNext: () => context.push(AppRoutes.scanSelect),
      ),
    ),
    GoRoute(
      path: AppRoutes.scanSelect,
      builder: (context, state) => ScanSelectScreen(
        onBack: () => context.pop(),
        onNext: () async {
          final container = ProviderScope.containerOf(context);
          await container.read(scanFlowProvider.notifier).analyze();
          if (!context.mounted) return;
          if (container.read(scanFlowProvider).questions.isEmpty) {
            // 직원에게 확인할 질문이 없으면 REST-06을 건너뜁니다.
            context.push(AppRoutes.scanResult);
            return;
          }
          context.push(AppRoutes.scanAskStaff);
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.scanAskStaff,
      builder: (context, state) => ScanAskStaffScreen(
        onBack: () => context.pop(),
        onComplete: () => context.push(AppRoutes.scanResult),
      ),
    ),
    GoRoute(
      path: AppRoutes.scanResult,
      builder: (context, state) => ScanResultScreen(
        onBack: () => context.pop(),
        onSave: () async {
          await ProviderScope.containerOf(
            context,
          ).read(scanFlowProvider.notifier).save();
          if (context.mounted) context.push(AppRoutes.scanSaved);
        },
        onFinish: () => context.go(AppRoutes.home),
        // TODO: 메뉴 상세 화면이 만들어지면 연결합니다.
      ),
    ),
    GoRoute(
      path: AppRoutes.scanSaved,
      builder: (context, state) => ScanSavedScreen(
        restaurant: _mockScanRestaurant,
        onBack: () => context.pop(),
        onDone: () => context.go(AppRoutes.home),
      ),
    ),
  ],
);

// ---- 임시 데이터 (서버/상태 연결 전까지만 사용) ----
const String _mockNickname = 'Biiiiii';
const String _mockEmail = 'bitok@kakao.com';
const String _mockDietarySummary = '4 food allergies · Vegetarian';
const String _mockAllergySummary = 'Shrimp · Anchovy · Walnut';
const String _mockDietSummary = 'No particular diet';
const List<String> _mockAllergens = [
  'Shrimp',
  'Prawn',
  'Walnut',
  'Anchovy',
  'Peanut',
];
const List<RecentCheck> _mockRecentChecks = [
  RecentCheck(
    koreanName: '비빔밥',
    englishName: 'Bibimbap',
    subtitle: 'Myeongdong Kyoja · Today',
    status: BitokMenuStatus.safe,
  ),
  RecentCheck(
    koreanName: '김치찌개',
    englishName: 'Kimchi Jjigae',
    subtitle: 'Myeongdong Kyoja · Today',
    status: BitokMenuStatus.avoid,
  ),
  RecentCheck(
    koreanName: '불고기',
    englishName: 'Bulgogi',
    subtitle: 'Myeongdong Kyoja · Today',
    status: BitokMenuStatus.notSure,
  ),
  RecentCheck(
    koreanName: '비빔밥',
    englishName: 'Bibimbap',
    subtitle: 'Myeongdong Kyoja · Today',
    status: BitokMenuStatus.safe,
  ),
  RecentCheck(
    koreanName: '김치찌개',
    englishName: 'Kimchi Jjigae',
    subtitle: 'Myeongdong Kyoja · Today',
    status: BitokMenuStatus.avoid,
  ),
  RecentCheck(
    koreanName: '불고기',
    englishName: 'Bulgogi',
    subtitle: 'Myeongdong Kyoja · Today',
    status: BitokMenuStatus.notSure,
  ),
];
const List<SavedRestaurant> _mockSavedRestaurants = [
  SavedRestaurant(
    name: 'Myeongdong Kyoja',
    category: 'Korean Restaurant',
    address: '29 Myeongdong 10-gil, Jung-gu',
  ),
];
const List<SavedMenu> _mockSavedMenus = [
  SavedMenu(
    koreanName: '비빔밥',
    englishName: 'Bibimbap',
    subtitle: 'Myeongdong Kyoja · Today',
    status: BitokMenuStatus.safe,
  ),
];
const ScanRestaurant _mockScanRestaurant = ScanRestaurant(
  name: 'Myeongdong Kyoja',
  category: 'Korean Restaurant',
  address: '29 Myeongdong 10-gil, Jung-gu',
);
const List<CheckedMenu> _mockCheckedMenus = [
  CheckedMenu(koreanName: '김치찌개', englishName: 'Kimchi Jjigae'),
  CheckedMenu(koreanName: '비빔밥', englishName: 'Bibimbap'),
  CheckedMenu(koreanName: '불고기', englishName: 'Bulgogi'),
];
