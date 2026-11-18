import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/bitok_status_chip.dart';
import '../utils/date_formatter.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/explore/presentation/models/map_restaurant.dart';
import '../../features/explore/presentation/models/mock_menu_catalog.dart';
import '../../features/explore/presentation/providers/saved_restaurants_provider.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/explore/presentation/screens/menu_detail_screen.dart';
import '../../features/explore/presentation/screens/personalized_menu_list_screen.dart';
import '../../features/explore/presentation/screens/restaurant_detail_screen.dart';
import '../../features/explore/presentation/screens/restaurant_select_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/mypage/presentation/providers/account_provider.dart';
import '../../features/mypage/presentation/providers/dietary_profile_provider.dart';
import '../../features/mypage/presentation/providers/my_checks_provider.dart';
import '../../features/mypage/presentation/screens/account_deletion_screen.dart';
import '../../features/mypage/presentation/screens/dietary_profile_screen.dart';
import '../../features/mypage/presentation/screens/edit_profile_screen.dart';
import '../../features/mypage/presentation/screens/my_page_screen.dart';
import '../../features/mypage/presentation/screens/saved_menus_screen.dart';
import '../../features/mypage/presentation/screens/saved_restaurants_screen.dart';
import '../../features/mypage/presentation/widgets/dietary_profile_summary.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
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

  // 마이페이지에서 알레르기·식단을 수정하는 화면입니다. (온보딩 화면을 Save 모드로 재사용)
  static const String foodAllergies = '/my/dietary/allergies';
  static const String dietPreference = '/my/dietary/diet';

  // 식당 상세는 '/restaurant/:id' 입니다. 이동할 때는 restaurantDetailOf(id)를 씁니다.
  // '/restaurant/select'가 ':id'로 잡히지 않도록 식당 선택 라우트를 먼저 등록합니다.
  static const String restaurantSelect = '/restaurant/select';
  static const String restaurantDetail = '/restaurant/:id';
  static const String personalizedMenus = '/restaurant/:id/for-you';
  static const String menuDetail = '/menu/:id';

  static String restaurantDetailOf(String id) =>
      '/restaurant/${Uri.encodeComponent(id)}';

  /// [status]를 주면 메뉴 상세가 임시 카탈로그 대신 그 판정(저장한 확인 결과)을 보여줍니다.
  static String menuDetailOf(String id, {BitokMenuStatus? status}) => Uri(
    path: '/menu/${Uri.encodeComponent(id)}',
    queryParameters: status == null ? null : {'status': status.name},
  ).toString();
  static String personalizedMenusOf(String id) =>
      '${restaurantDetailOf(id)}/for-you';

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
              builder: (context, state) => Consumer(
                builder: (context, ref, _) => HomeScreen(
                  recentChecks: [
                    for (final check in ref.watch(myChecksProvider))
                      RecentCheck(
                        menuId: check.menuId,
                        koreanName: check.koreanName,
                        englishName: check.englishName,
                        subtitle: _checkSubtitle(check),
                        status: check.status,
                      ),
                  ],
                  onProfileTap: () => context.push(AppRoutes.myPage),
                  // 식당 선택 화면은 최상위 경로라 하단 탭 없이 열립니다.
                  onCheckMenuTap: () =>
                      context.push(AppRoutes.restaurantSelect),
                  // 메뉴 상세는 최상위 경로라 하단 탭 없이 열립니다.
                  onRecentCheckTap: (check) => context.push(
                    AppRoutes.menuDetailOf(check.menuId, status: check.status),
                  ),
                ),
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
                  onMenuResultsTap: (restaurant) =>
                      context.push(AppRoutes.restaurantDetailOf(restaurant.id)),
                ),
              ),
            ),
          ],
        ),
      ],
    ),

    // ---- 마이페이지 (네비게이션 바 없음) ----
    GoRoute(
      path: AppRoutes.myPage,
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => MyPageScreen(
          nickname: ref.watch(accountProvider).nickname,
          email: ref.watch(accountProvider).email,
          dietarySummary: myPageDietarySummaryOf(
            AppLocalizations.of(context),
            ref.watch(dietaryProfileProvider),
          ),
          onBack: () => context.pop(),
          onProfileTap: () => context.push(AppRoutes.editProfile),
          onDietaryTap: () => context.push(AppRoutes.dietaryProfile),
          onSavedRestaurantsTap: () => context.push(AppRoutes.savedRestaurants),
          onSavedMenusTap: () => context.push(AppRoutes.savedMenus),
          onDeleteAccountTap: () => context.push(AppRoutes.accountDeletion),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.editProfile,
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => EditProfileScreen(
          initialNickname: ref.read(accountProvider).nickname,
          onBack: () => context.pop(),
          onSave: (nickname) {
            ref.read(accountProvider.notifier).saveNickname(nickname);
            context.pop();
          },
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.dietaryProfile,
      builder: (context, state) => Consumer(
        builder: (context, ref, _) {
          final l10n = AppLocalizations.of(context);
          final profile = ref.watch(dietaryProfileProvider);

          // 수정 화면은 현재 프로필을 불러온 입력값(onboardingProvider)을 고칩니다.
          // Save를 눌러야 프로필에 반영되고, 뒤로 가면 고친 내용은 버려집니다.
          void openEditor(String location) {
            ref.read(onboardingProvider.notifier).loadProfile(profile);
            context.push(location);
          }

          return DietaryProfileScreen(
            allergySummary: allergySummaryOf(l10n, profile),
            dietSummary: dietSummaryOfProfile(l10n, profile),
            onBack: () => context.pop(),
            onEditAllergies: () => openEditor(AppRoutes.foodAllergies),
            onEditDiet: () => openEditor(AppRoutes.dietPreference),
          );
        },
      ),
    ),
    GoRoute(
      path: AppRoutes.foodAllergies,
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => OnboardingAllergiesScreen(
          onSave: () {
            ref
                .read(dietaryProfileProvider.notifier)
                .saveAllergies(ref.read(onboardingProvider).allergies);
            context.pop();
          },
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.dietPreference,
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => OnboardingDietScreen(
          onSave: () {
            final draft = ref.read(onboardingProvider);
            final diet = draft.diet;
            if (diet == null) return;
            ref
                .read(dietaryProfileProvider.notifier)
                .saveDiet(
                  diet: diet,
                  eatsEggs: draft.eatsEggs,
                  eatsDairy: draft.eatsDairy,
                );
            context.pop();
          },
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.savedRestaurants,
      // 식당 상세·Explore의 북마크와 같은 상태(savedRestaurantIdsProvider)를 보여줍니다.
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => SavedRestaurantsScreen(
          restaurants: [
            // TODO: 저장한 식당 목록 API로 교체합니다. 지금은 지도 샘플에서 id로 찾습니다.
            for (final id in ref.watch(savedRestaurantIdsProvider))
              if (findMapRestaurant(id) case final restaurant?)
                SavedRestaurant(
                  id: restaurant.id,
                  name: restaurant.name,
                  category: restaurant.category,
                  address: restaurant.address,
                ),
          ],
          onBack: () => context.pop(),
          onRestaurantTap: (restaurant) =>
              context.push(AppRoutes.restaurantDetailOf(restaurant.id)),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.savedMenus,
      // 홈 Recent Checks와 같은 My Checks 목록을 보여줍니다.
      builder: (context, state) => Consumer(
        builder: (context, ref, _) => SavedMenusScreen(
          menus: [
            for (final check in ref.watch(myChecksProvider))
              SavedMenu(
                menuId: check.menuId,
                koreanName: check.koreanName,
                englishName: check.englishName,
                subtitle: _checkSubtitle(check),
                status: check.status,
              ),
          ],
          onBack: () => context.pop(),
          onMenuTap: (menu) => context.push(
            AppRoutes.menuDetailOf(menu.menuId, status: menu.status),
          ),
        ),
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

    // ---- 메뉴 상세 ('/menu/:id') ----
    // TODO: 메뉴 상세 API(id)로 교체합니다. 지금은 임시 메뉴 목록에서 id로 찾습니다.
    GoRoute(
      path: AppRoutes.menuDetail,
      builder: (context, state) => MenuDetailScreen(
        menu: findMockMenuDetail(
          state.pathParameters['id']!,
          status: BitokMenuStatus.values
              .asNameMap()[state.uri.queryParameters['status']],
        ),
        onBack: () => context.pop(),
      ),
    ),
    // ---- 식당 선택 (REST-01) ----
    GoRoute(
      path: AppRoutes.restaurantSelect,
      builder: (context, state) => RestaurantSelectScreen(
        restaurants: mapRestaurantSamples,
        onBack: () => context.pop(),
        onSelect: (restaurant) {
          // 이전 스캔 결과가 남지 않도록 초기화한 뒤 선택한 식당으로 스캔을 시작합니다.
          final scanRestaurant = ScanRestaurant(
            name: restaurant.name,
            category: restaurant.category,
            address: restaurant.address,
          );
          ProviderScope.containerOf(
            context,
          ).read(scanFlowProvider.notifier).start(scanRestaurant);
          context.push(AppRoutes.scan, extra: scanRestaurant);
        },
      ),
    ),

    // ---- 식당 상세 (EXP-02) ----
    // 식당 선택('/restaurant/select') 뒤에 등록해야 'select'가 :id로 잡히지 않습니다.
    // TODO: 식당 상세 API(id)로 교체합니다. 지금은 지도 샘플에서 id로 찾습니다.
    GoRoute(
      path: AppRoutes.restaurantDetail,
      redirect: (context, state) =>
          findMapRestaurant(state.pathParameters['id']!) == null
          ? AppRoutes.explore
          : null,
      builder: (context, state) {
        final restaurant = findMapRestaurant(state.pathParameters['id']!)!;
        return Consumer(
          builder: (context, ref, _) => RestaurantDetailScreen(
            name: restaurant.name,
            info: '${restaurant.category} · 350 m',
            // TODO: distance_m 연결
            imageUrl: restaurant.imageUrl,
            menus: _mockCheckedMenus,
            saved: ref
                .watch(savedRestaurantIdsProvider)
                .contains(restaurant.id),
            onToggleSaved: () => ref
                .read(savedRestaurantIdsProvider.notifier)
                .toggle(restaurant.id),
            onBack: () => context.pop(),
            onForYouTap: () =>
                context.push(AppRoutes.personalizedMenusOf(restaurant.id)),
            onMenuTap: (menu) =>
                context.push(AppRoutes.menuDetailOf(menu.menuId)),
          ),
        );
      },
    ),
    // ---- 개인화 메뉴 리스트 (EXP-03) ----
    // TODO: state.pathParameters['id']로 개인화 메뉴 목록 API를 호출합니다.
    GoRoute(
      path: AppRoutes.personalizedMenus,
      builder: (context, state) => PersonalizedMenuListScreen(
        menus: _mockPersonalizedMenus,
        onBack: () => context.pop(),
        onMenuTap: (menu) => context.push(AppRoutes.menuDetailOf(menu.menuId)),
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
        // TODO: 메뉴 분석 API가 메뉴 id를 주면 그 값을 씁니다.
        onViewDetails: (item) => context.push(
          AppRoutes.menuDetailOf(
            mockMenuIdOf(item.englishName),
            // 직원 답변으로 정한 판정을 상세에도 그대로 보여줍니다.
            status: ProviderScope.containerOf(
              context,
            ).read(scanFlowProvider).statusOf(item.id),
          ),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.scanSaved,
      builder: (context, state) => ScanSavedScreen(
        restaurant:
            ProviderScope.containerOf(
              context,
            ).read(scanFlowProvider).restaurant ??
            _mockScanRestaurant,
        onBack: () => context.pop(),
        onDone: () => context.go(AppRoutes.home),
      ),
    ),
  ],
);

/// 홈 Recent Checks·Saved Menus 카드의 부제입니다. 예: 'Myeongdong Kyoja · Today'
String _checkSubtitle(MenuCheck check) {
  final day = check.checkedAt.toRelativeDayLabel();
  return check.restaurantName.isEmpty ? day : '${check.restaurantName} · $day';
}

// ---- 임시 데이터 (서버/상태 연결 전까지만 사용) ----
const List<String> _mockAllergens = [
  'Shrimp',
  'Prawn',
  'Walnut',
  'Anchovy',
  'Peanut',
];
const ScanRestaurant _mockScanRestaurant = ScanRestaurant(
  name: 'Myeongdong Kyoja',
  category: 'Korean Restaurant',
  address: '29 Myeongdong 10-gil, Jung-gu',
);
const List<CheckedMenu> _mockCheckedMenus = [
  CheckedMenu(
    menuId: 'kimchi-jjigae',
    koreanName: '김치찌개',
    englishName: 'Kimchi Jjigae',
  ),
  CheckedMenu(menuId: 'bibimbap', koreanName: '비빔밥', englishName: 'Bibimbap'),
  CheckedMenu(menuId: 'bulgogi', koreanName: '불고기', englishName: 'Bulgogi'),
];
const List<PersonalizedMenu> _mockPersonalizedMenus = [
  PersonalizedMenu(
    menuId: 'kimchi-jjigae',
    koreanName: '김치찌개',
    englishName: 'Kimchi Jjigae',
    status: BitokMenuStatus.avoid,
  ),
  PersonalizedMenu(
    menuId: 'bibimbap',
    koreanName: '비빔밥',
    englishName: 'Bibimbap',
    status: BitokMenuStatus.safe,
  ),
  PersonalizedMenu(
    menuId: 'bulgogi',
    koreanName: '불고기',
    englishName: 'Bulgogi',
    status: BitokMenuStatus.notSure,
  ),
];
