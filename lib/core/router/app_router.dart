import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:go_router/go_router.dart';

import '../../common/widgets/bitok_button.dart';
import '../../common/widgets/bitok_toast.dart';
import '../../common/widgets/double_back_to_exit.dart';
import '../utils/date_formatter.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../features/auth/presentation/providers/account_provider.dart';
import '../../features/auth/presentation/providers/login_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/explore/data/repositories/restaurant_repository.dart';
import '../../features/explore/presentation/providers/menu_detail_provider.dart';
import '../../features/explore/presentation/providers/personalized_menus_provider.dart';
import '../../features/explore/presentation/providers/saved_restaurants_provider.dart';
import '../../features/explore/presentation/providers/selected_restaurant_provider.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/explore/presentation/screens/menu_detail_screen.dart';
import '../../features/explore/presentation/screens/personalized_menu_list_screen.dart';
import '../../features/explore/presentation/screens/restaurant_detail_page.dart';
import '../../features/explore/presentation/screens/restaurant_select_screen.dart';
import '../../features/explore/presentation/widgets/explore_status_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
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
import '../../features/scan/presentation/providers/analysis_detail_provider.dart';
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

  // 식당 상세는 '/restaurant/:id' 입니다. id는 서버의 restaurant_id입니다.
  // 이동할 때는 restaurantDetailOf(id)를 씁니다.
  // '/restaurant/select'가 ':id'로 잡히지 않도록 식당 선택 라우트를 먼저 등록합니다.
  static const String restaurantSelect = '/restaurant/select';
  static const String restaurantDetail = '/restaurant/:id';
  static const String personalizedMenus = '/restaurant/:id/for-you';
  static const String restaurantMenuDetail = '/restaurant/:id/menu/:dishId';

  // 내 기록의 메뉴 상세입니다. id는 서버의 analysis_id입니다.
  // 스캔 결과·Recent Checks·Saved Menus의 View details가 엽니다.
  static const String analysisDetail = '/analysis/:id';

  static String restaurantDetailOf(String id) =>
      '/restaurant/${Uri.encodeComponent(id)}';

  static String restaurantMenuDetailOf(int restaurantId, int dishId) =>
      '/restaurant/$restaurantId/menu/$dishId';

  static String analysisDetailOf(int analysisId) => '/analysis/$analysisId';

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
//
// [initialLocation]은 앱 시작 시 정합니다. 이미 가입·온보딩을 마친 기기면
// main()에서 홈을 넘겨 로그인 화면을 건너뜁니다.
GoRouter createAppRouter({String initialLocation = AppRoutes.login}) =>
    GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: AppRoutes.login,
          // 로그인은 첫 화면이라 뒤로 가기를 누르면 앱이 종료됩니다. 안내는 Get Started 버튼 위에 띄웁니다.
          builder: (context, state) => const DoubleBackToExit(
            bottomOffset: _bottomButtonTop,
            child: LoginScreen(),
          ),
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
          // go로 이동해 이전 단계 스택이 비어 있으므로 뒤로 가기를 누르면 앱이 종료됩니다.
          // 안내는 Start 버튼 위에 띄웁니다.
          builder: (context, state) => const DoubleBackToExit(
            bottomOffset: _bottomButtonTop,
            child: OnboardingCompleteScreen(),
          ),
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
                    builder: (context, ref, _) {
                      // 불러오지 못하면 토스트로 알리고, 목록 자리에 오류 안내와 다시 시도 버튼을 보여줍니다.
                      // 토스트는 네비게이션 바 위에 띄웁니다.
                      _toastOnLoadError(
                        context,
                        ref,
                        myChecksProvider,
                        path: AppRoutes.home,
                        bottomOffset: MainShell.contentBottomInset,
                      );
                      final checks = ref.watch(myChecksProvider);
                      final page = checks.value;
                      return HomeScreen(
                        // 처음 불러오는 동안만 로딩 표시합니다. 저장 후 다시 불러올 때는 이전 목록을 그대로 둡니다.
                        isLoading: _isFirstLoad(checks),
                        loadFailed: _loadFailed(checks),
                        onRetry: () => ref.invalidate(myChecksProvider),
                        recentChecks: [
                          for (final check in page?.items ?? const <MenuCheck>[])
                            RecentCheck(
                              analysisId: check.analysisId,
                              koreanName: check.koreanName,
                              englishName: check.englishName,
                              subtitle: _checkSubtitle(check),
                              status: check.status,
                            ),
                        ],
                        loadingMore: page?.loadingMore ?? false,
                        loadMoreFailed: page?.loadMoreFailed ?? false,
                        onLoadMore: () => _loadMoreMyChecks(
                          context,
                          ref,
                          bottomOffset: MainShell.contentBottomInset,
                        ),
                        onRetryLoadMore: () => _loadMoreMyChecks(
                          context,
                          ref,
                          bottomOffset: MainShell.contentBottomInset,
                          retry: true,
                        ),
                        onProfileTap: () => context.push(AppRoutes.myPage),
                        // 식당 선택 화면은 최상위 경로라 하단 탭 없이 열립니다.
                        onCheckMenuTap: () =>
                            context.push(AppRoutes.restaurantSelect),
                        // 메뉴 상세는 최상위 경로라 하단 탭 없이 열립니다.
                        onRecentCheckTap: (check) => context.push(
                          AppRoutes.analysisDetailOf(check.analysisId),
                        ),
                      );
                    },
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
                      savedIds: ref.watch(savedRestaurantIdsProvider),
                      onProfileTap: () => context.push(AppRoutes.myPage),
                  // 북마크는 바로 바뀌고, 서버 저장에 실패하면 되돌린 뒤 안내합니다.
                      onToggleSaved: (restaurant) => ref
                      .read(savedRestaurantsProvider.notifier)
                      .toggle(restaurant.toBrief())
                      .catchError((Object _) {
                        // 일반 스낵바는 네비게이션 바에 가려지므로 그 위에 토스트로 띄웁니다.
                        if (context.mounted) {
                          showBitokToast(
                            context,
                            AppLocalizations.of(context).errorTryAgain,
                            bottomOffset: MainShell.contentBottomInset,
                          );
                        }
                      }),
                      onMenuResultsTap: (restaurant) {
                        final restaurantId = restaurant.restaurantId;
                        if (restaurantId == null) return;
                        context.push(AppRoutes.restaurantDetailOf('$restaurantId'));
                      },
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
              nickname: ref.watch(accountProvider)?.nickname ?? '',
              // 불러오는 동안은 비워 두고, 실패하면 안내 문구를 보여줍니다.
              // 카드를 눌러 Dietary Profile 화면에서 다시 시도할 수 있습니다.
              dietarySummary: switch (ref.watch(dietaryProfileProvider)) {
                AsyncData(:final value) => myPageDietarySummaryOf(
                  AppLocalizations.of(context),
                  value,
                ),
                AsyncError() => AppLocalizations.of(context).errorLoadFailed,
                _ => '',
              },
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
              initialNickname: ref.read(accountProvider)?.nickname ?? '',
              onBack: () => context.pop(),
              onSave: (nickname) async {
                await ref.read(accountProvider.notifier).saveNickname(nickname);
                if (context.mounted) context.pop();
              },
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.dietaryProfile,
          builder: (context, state) => Consumer(
            builder: (context, ref, _) {
              final l10n = AppLocalizations.of(context);
              final async = ref.watch(dietaryProfileProvider);
              // 저장 후 다시 그릴 때도 이전 값을 보여주도록 value를 씁니다.
              final profile = async.value;

              if (profile == null) {
                return DietaryProfileScreen(
                  allergySummary: '',
                  dietSummary: '',
                  onBack: () => context.pop(),
                  isLoading: !async.hasError,
                  onRetry: async.hasError
                      ? () => ref.invalidate(dietaryProfileProvider)
                      : null,
                );
              }

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
              onSave: () async {
                await ref
                    .read(dietaryProfileProvider.notifier)
                    .saveAllergies(ref.read(onboardingProvider).allergies);
                if (context.mounted) context.pop();
              },
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.dietPreference,
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => OnboardingDietScreen(
              onSave: () async {
                final draft = ref.read(onboardingProvider);
                final diet = draft.diet;
                if (diet == null) return;
                await ref
                    .read(dietaryProfileProvider.notifier)
                    .saveDiet(
                  diet: diet,
                  eatsEggs: draft.eatsEggs,
                  eatsDairy: draft.eatsDairy,
                );
                if (context.mounted) context.pop();
              },
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.savedRestaurants,
          // 처음 불러오는 동안 로딩 표시, 실패하면 토스트와 오류 안내·다시 시도 버튼을 보여줍니다.
          builder: (context, state) => Consumer(
            builder: (context, ref, _) {
              _toastOnLoadError(
                context,
                ref,
                savedRestaurantsProvider,
                path: AppRoutes.savedRestaurants,
              );
              final restaurants = ref.watch(savedRestaurantsProvider);
              return SavedRestaurantsScreen(
                isLoading: _isFirstLoad(restaurants),
                loadFailed: _loadFailed(restaurants),
                onRetry: () => ref.invalidate(savedRestaurantsProvider),
                restaurants: [
                  for (final restaurant in restaurants.value ?? const [])
                    if (restaurant.restaurantId case final restaurantId?)
                      SavedRestaurant(
                        id: '$restaurantId',
                        name: restaurant.name,
                        category: restaurant.category ?? '',
                        address: restaurant.address ?? '',
                      ),
                ],
                onBack: () => context.pop(),
                onRestaurantTap: (restaurant) =>
                    context.push(AppRoutes.restaurantDetailOf(restaurant.id)),
              );
            },
          ),
        ),
        GoRoute(
          path: AppRoutes.savedMenus,
          // 홈 Recent Checks와 같은 My Checks 목록을 보여줍니다.
          // 처음 불러오는 동안 로딩 표시, 실패하면 토스트와 오류 안내·다시 시도 버튼을 보여줍니다.
          builder: (context, state) => Consumer(
            builder: (context, ref, _) {
              _toastOnLoadError(
                context,
                ref,
                myChecksProvider,
                path: AppRoutes.savedMenus,
              );
              final checks = ref.watch(myChecksProvider);
              final page = checks.value;
              return SavedMenusScreen(
                isLoading: _isFirstLoad(checks),
                loadFailed: _loadFailed(checks),
                onRetry: () => ref.invalidate(myChecksProvider),
                menus: [
                  for (final check in page?.items ?? const <MenuCheck>[])
                    SavedMenu(
                      analysisId: check.analysisId,
                      koreanName: check.koreanName,
                      englishName: check.englishName,
                      subtitle: _checkSubtitle(check),
                      status: check.status,
                    ),
                ],
                loadingMore: page?.loadingMore ?? false,
                loadMoreFailed: page?.loadMoreFailed ?? false,
                onLoadMore: () => _loadMoreMyChecks(context, ref),
                onRetryLoadMore: () =>
                    _loadMoreMyChecks(context, ref, retry: true),
                onBack: () => context.pop(),
                onMenuTap: (menu) =>
                    context.push(AppRoutes.analysisDetailOf(menu.analysisId)),
              );
            },
          ),
        ),
        GoRoute(
          path: AppRoutes.accountDeletion,
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => AccountDeletionScreen(
              onBack: () => context.pop(),
              onDelete: (deleteSavedMenus) async {
                // 요청 중에 뒤로 가서 이 화면(ref, context)이 사라져도 정리와 이동을 마치도록,
                // 앱 수명의 container와 router를 요청 전에 잡아 둡니다.
                final container = ProviderScope.containerOf(context);
                final router = GoRouter.of(context);
                await container
                    .read(accountProvider.notifier)
                    .deleteAccount(deleteSavedMenus: deleteSavedMenus);
                // 탈퇴한 계정의 화면 상태를 비웁니다. 식단 프로필은 계정이 바뀌면 스스로 다시 불러옵니다.
                container
                  ..invalidate(loginProvider)
                  ..invalidate(onboardingProvider)
                  ..invalidate(myChecksProvider)
                  ..invalidate(savedRestaurantsProvider)
                  ..invalidate(selectedRestaurantIdProvider)
                  ..invalidate(scanFlowProvider);
                router.go(AppRoutes.login);
              },
            ),
          ),
        ),

        // ---- 내 기록의 메뉴 상세 ('/analysis/:id') ----
        // 그 스캔에서 받은 직원 답으로 판정한 결과입니다(GET /api/analyses/{id}).
        GoRoute(
          path: AppRoutes.analysisDetail,
          redirect: (context, state) => _redirectUnlessInts(state, const ['id']),
          builder: (context, state) {
            final analysisId = int.parse(state.pathParameters['id']!);
            return Consumer(
              builder: (context, ref, _) => _menuDetailPage(
                context,
                ref.watch(analysisDetailProvider(analysisId)),
                onRetry: () =>
                    ref.invalidate(analysisDetailProvider(analysisId)),
              ),
            );
          },
        ),
        // ---- 식당 선택 (REST-01) ----
        GoRoute(
          path: AppRoutes.restaurantSelect,
          builder: (context, state) => RestaurantSelectScreen(
            onBack: () => context.pop(),
            onSelect: (restaurant) async {
              final container = ProviderScope.containerOf(context);
              final registered = await container
                  .read(restaurantRepositoryProvider)
                  .register(restaurant.toBrief());
              if (!context.mounted) return;
              container
                  .read(selectedRestaurantIdProvider.notifier)
                  .select(registered.restaurantId);
              // 이전 스캔 결과가 남지 않도록 초기화한 뒤 선택한 식당으로 스캔을 시작합니다.
              final scanRestaurant = ScanRestaurant(
                restaurantId: registered.restaurantId,
                name: registered.name,
                category: registered.category ?? '',
                address: registered.address ?? '',
              );
              container.read(scanFlowProvider.notifier).start(scanRestaurant);
              context.push(AppRoutes.scan, extra: scanRestaurant);
            },
          ),
        ),

        // ---- 식당 상세 (EXP-02) ----
        // 식당 선택('/restaurant/select') 뒤에 등록해야 'select'가 :id로 잡히지 않습니다.
        GoRoute(
          path: AppRoutes.restaurantDetail,
          redirect: (context, state) => _redirectUnlessInts(state, const ['id']),
          builder: (context, state) {
            final restaurantId = int.parse(state.pathParameters['id']!);
            return RestaurantDetailPage(
              restaurantId: restaurantId,
              onBack: () => context.pop(),
              onForYouTap: () => context.push(
                AppRoutes.personalizedMenusOf('$restaurantId'),
              ),
              onMenuTap: (menu) => context.push(
                AppRoutes.restaurantMenuDetailOf(restaurantId, menu.dishId),
              ),
            );
          },
        ),
        // ---- 개인화 메뉴 리스트 (EXP-03) ----
        GoRoute(
          path: AppRoutes.personalizedMenus,
          redirect: (context, state) => _redirectUnlessInts(state, const ['id']),
          builder: (context, state) {
            final restaurantId = int.parse(state.pathParameters['id']!);
            return Consumer(
              builder: (context, ref, _) =>
              switch (ref.watch(personalizedMenusProvider(restaurantId))) {
                AsyncData(:final value) => PersonalizedMenuListScreen(
                  menus: value,
                  onBack: () => context.pop(),
                  onMenuTap: (menu) => context.push(
                    AppRoutes.restaurantMenuDetailOf(restaurantId, menu.dishId),
                  ),
                ),
                AsyncError() => ExploreErrorScreen(
                  title: 'Personalized Menu List',
                  onBack: () => context.pop(),
                  onRetry: () =>
                      ref.invalidate(personalizedMenusProvider(restaurantId)),
                ),
                _ => ExploreLoadingScreen(
                  title: 'Personalized Menu List',
                  onBack: () => context.pop(),
                ),
              },
            );
          },
        ),
        // ---- 메뉴 상세 ('/restaurant/:id/menu/:dishId') ----
        GoRoute(
          path: AppRoutes.restaurantMenuDetail,
          redirect: (context, state) =>
              _redirectUnlessInts(state, const ['id', 'dishId']),
          builder: (context, state) {
            final key = (
            restaurantId: int.parse(state.pathParameters['id']!),
            dishId: int.parse(state.pathParameters['dishId']!),
            );
            return Consumer(
              builder: (context, ref, _) => _menuDetailPage(
                context,
                ref.watch(menuDetailProvider(key)),
                onRetry: () => ref.invalidate(menuDetailProvider(key)),
              ),
            );
          },
        ),

        // ---- 메뉴 스캔 (네비게이션 바 없음) ----
        // 진입점: 식당 선택(REST-01)의 Select. 식당 정보는 extra(ScanRestaurant)로 받습니다.
        // extra 없이 열리면(식당을 고르지 않은 경우) 식당 선택 화면으로 보냅니다.
        GoRoute(
          path: AppRoutes.scan,
          redirect: (context, state) =>
              state.extra is ScanRestaurant ? null : AppRoutes.restaurantSelect,
          builder: (context, state) => ScanScreen(
            restaurant: state.extra! as ScanRestaurant,
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
            // 인식에 실패하면 예외가 화면까지 올라가 안내 스낵바가 뜹니다.
            // 기다리는 동안 뒤로 가서 이 화면을 떠났으면 다음 화면을 열지 않습니다.
            onNext: () async {
              // 라우터는 위젯 트리 밖에 있으므로 ProviderScope에서 직접 provider를 읽습니다.
              await ProviderScope.containerOf(
                context,
              ).read(scanFlowProvider.notifier).recognize(state.extra! as String);
              if (context.mounted && _isShowing(context, AppRoutes.scanPreview)) {
                context.push(AppRoutes.scanCheck);
              }
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
            // 분석에 실패하면 예외가 화면까지 올라가 안내 스낵바가 뜹니다.
            // 분석 중에도 뒤로 갈 수 있으므로, 끝났을 때 이 화면을 떠났으면 다음 화면을 열지 않습니다.
            onNext: () async {
              final container = ProviderScope.containerOf(context);
              final scan = container.read(scanFlowProvider.notifier);
              await scan.analyze();
              if (!context.mounted || !_isShowing(context, AppRoutes.scanSelect)) return;
              if (container.read(scanFlowProvider).questions.isEmpty) {
                // 직원에게 확인할 질문이 없으면 REST-06을 건너뛰고 바로 최종 결과를 받습니다.
                await scan.loadResult();
                if (context.mounted && _isShowing(context, AppRoutes.scanSelect)) {
                  context.push(AppRoutes.scanResult);
                }
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
            // 마지막 답변 뒤 최종 결과를 받습니다. 실패하면 화면에 안내 스낵바가 뜹니다.
            onComplete: () async {
              await ProviderScope.containerOf(
                context,
              ).read(scanFlowProvider.notifier).loadResult();
              if (context.mounted && _isShowing(context, AppRoutes.scanAskStaff)) {
                context.push(AppRoutes.scanResult);
              }
            },
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
              if (context.mounted && _isShowing(context, AppRoutes.scanResult)) {
                context.push(AppRoutes.scanSaved);
              }
            },
            onFinish: () => context.go(AppRoutes.home),
            // 이 스캔의 직원 답으로 판정한 내 기록의 메뉴 상세를 엽니다.
            onViewDetails: (menu) =>
                context.push(AppRoutes.analysisDetailOf(menu.analysisId)),
          ),
        ),
        // 스캔 상태에 식당이 없으면(스캔을 거치지 않고 열린 경우) 홈으로 보냅니다.
        GoRoute(
          path: AppRoutes.scanSaved,
          redirect: (context, state) =>
              ProviderScope.containerOf(context).read(scanFlowProvider).restaurant ==
                  null
              ? AppRoutes.home
              : null,
          builder: (context, state) => ScanSavedScreen(
            restaurant: ProviderScope.containerOf(
              context,
            ).read(scanFlowProvider).restaurant!,
            onBack: () => context.pop(),
            onDone: () => context.go(AppRoutes.home),
          ),
        ),
      ],
    );

/// 메뉴 상세 응답 상태에 맞는 화면입니다. 식당 메뉴 상세와 내 기록의 메뉴 상세가 함께 씁니다.
Widget _menuDetailPage(
  BuildContext context,
  AsyncValue<MenuDetail> detail, {
  required VoidCallback onRetry,
}) => switch (detail) {
  AsyncData(:final value) => MenuDetailScreen(
    menu: value,
    onBack: () => context.pop(),
  ),
  AsyncError() => ExploreErrorScreen(
    title: MenuDetailScreen.title,
    onBack: () => context.pop(),
    onRetry: onRetry,
  ),
  _ => ExploreLoadingScreen(
    title: MenuDetailScreen.title,
    onBack: () => context.pop(),
  ),
};

/// 로그인·온보딩 완료 화면의 하단 버튼 윗변 높이입니다(안전 영역 기준).
/// 두 화면 모두 버튼 아래 여백이 10이라 10 + 버튼 높이입니다. 화면 여백을 바꾸면 같이 바꿔 주세요.
const double _bottomButtonTop = 10 + BitokButton.height;

/// 아직 한 번도 값을 받지 못한 채 불러오는 중이면 true입니다. 목록 자리에 로딩 표시를 보여줍니다.
/// - 다시 불러오는 중(invalidate 뒤)에는 이전 값이 있으므로 false입니다.
/// - Riverpod가 실패한 provider를 자동으로 다시 시도하는 동안(30초 넘게)은 false입니다.
///   그동안은 로딩만 보여주지 않고 [_loadFailed]의 오류 안내를 보여줍니다.
/// - 사용자가 다시 시도 버튼을 누르면 다시 true가 되어 로딩을 보여줍니다.
bool _isFirstLoad(AsyncValue<Object?> value) =>
    value.isLoading && !value.hasValue && !value.retrying;

/// 보여줄 목록 없이 불러오기에 실패했으면 true입니다.
/// 빈 화면('저장한 항목 없음') 대신 오류 안내와 다시 시도 버튼을 보여줍니다.
bool _loadFailed(AsyncValue<Object?> value) =>
    value.hasError && !value.hasValue && !_isFirstLoad(value);

/// 목록 provider를 불러오지 못하면 '불러오지 못했어요' 토스트를 띄웁니다. Consumer의 build에서 호출하세요.
///
/// 실패가 처음 생길 때 한 번만 띄웁니다. (자동 다시 시도가 이어져도 반복해서 띄우지 않습니다)
/// 같은 provider를 여러 화면이 보고 있어도, 지금 보이는 화면([path])일 때만 띄웁니다.
void _toastOnLoadError(
  BuildContext context,
  WidgetRef ref,
  ProviderListenable<AsyncValue<Object?>> provider, {
  required String path,
  double bottomOffset = 0,
}) {
  ref.listen(provider, (previous, next) {
    if (!next.hasError || (previous?.hasError ?? false)) return;
    if (!context.mounted || !_isShowing(context, path)) return;
    showBitokToast(
      context,
      AppLocalizations.of(context).errorLoadFailed,
      bottomOffset: bottomOffset,
    );
  });
}

/// My Checks 다음 페이지를 불러옵니다. 실패하면 토스트로 알립니다(목록 끝에는 다시 시도 버튼이 생깁니다).
Future<void> _loadMoreMyChecks(
  BuildContext context,
  WidgetRef ref, {
  double bottomOffset = 0,
  bool retry = false,
}) async {
  try {
    await ref.read(myChecksProvider.notifier).loadMore(retry: retry);
  } catch (_) {
    if (!context.mounted) return;
    showBitokToast(
      context,
      AppLocalizations.of(context).errorLoadFailed,
      bottomOffset: bottomOffset,
    );
  }
}

/// 지금 화면에 보이는 경로가 [path]이면 true입니다.
///
/// 스캔 단계에서 요청을 기다린 뒤 다음 화면으로 넘어가기 전에, 사용자가 아직 그 화면에 있는지
/// 확인할 때도 씁니다. 뒤로 가는 중인 화면은 `context.mounted`가 아직 true일 수 있기 때문입니다.
/// (`context.mounted &&`와 함께 쓰세요)
bool _isShowing(BuildContext context, String path) =>
    GoRouter.of(context).routerDelegate.currentConfiguration.uri.path == path;

String? _redirectUnlessInts(GoRouterState state, List<String> keys) =>
    keys.every((key) => int.tryParse(state.pathParameters[key] ?? '') != null)
        ? null
        : AppRoutes.explore;

/// 홈 Recent Checks·Saved Menus 카드의 부제입니다. 예: 'Myeongdong Kyoja · Today'
String _checkSubtitle(MenuCheck check) {
  final day = check.checkedAt.toRelativeDayLabel();
  return check.restaurantName.isEmpty ? day : '${check.restaurantName} · $day';
}
