import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../common/widgets/saving_state_mixin.dart';
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
                      // 처음 불러오는 동안 로딩 표시, 실패하면 빈 목록(No checks yet)을 보여줍니다.
                      // 저장 후 다시 불러올 때는 이전 목록을 그대로 보여줍니다.
                      isLoading: _isFirstLoad(ref.watch(myChecksProvider)),
                      recentChecks: [
                        for (final check
                            in ref.watch(myChecksProvider).value ?? const [])
                          RecentCheck(
                            analysisId: check.analysisId,
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
                        AppRoutes.analysisDetailOf(check.analysisId),
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
                      savedIds: ref.watch(savedRestaurantIdsProvider),
                      onProfileTap: () => context.push(AppRoutes.myPage),
                      // 북마크는 바로 바뀌고, 서버 저장에 실패하면 되돌린 뒤 안내합니다.
                      onToggleSaved: (restaurant) => ref
                          .read(savedRestaurantsProvider.notifier)
                          .toggle(restaurant.toBrief())
                          .catchError((Object _) {
                            if (context.mounted) {
                              showMessageSnackBar(
                                context,
                                AppLocalizations.of(context).errorTryAgain,
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
          // 처음 불러오는 동안 로딩 표시, 실패하면 빈 목록을 보여줍니다.
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => SavedRestaurantsScreen(
              isLoading: _isFirstLoad(ref.watch(savedRestaurantsProvider)),
              restaurants: [
                for (final restaurant
                    in ref.watch(savedRestaurantsProvider).value ?? const [])
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
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.savedMenus,
          // 홈 Recent Checks와 같은 My Checks 목록을 보여줍니다.
          builder: (context, state) => Consumer(
            builder: (context, ref, _) => SavedMenusScreen(
              isLoading: _isFirstLoad(ref.watch(myChecksProvider)),
              menus: [
                for (final check
                    in ref.watch(myChecksProvider).value ?? const [])
                  SavedMenu(
                    analysisId: check.analysisId,
                    koreanName: check.koreanName,
                    englishName: check.englishName,
                    subtitle: _checkSubtitle(check),
                    status: check.status,
                  ),
              ],
              onBack: () => context.pop(),
              onMenuTap: (menu) =>
                  context.push(AppRoutes.analysisDetailOf(menu.analysisId)),
            ),
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
                    AppRoutes.restaurantMenuDetailOf(
                      restaurantId,
                      menu.dishId,
                    ),
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
            // 인식에 실패하면 예외가 화면까지 올라가 안내 스낵바가 뜹니다.
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
            // 분석에 실패하면 예외가 화면까지 올라가 안내 스낵바가 뜹니다.
            onNext: () async {
              final container = ProviderScope.containerOf(context);
              final scan = container.read(scanFlowProvider.notifier);
              await scan.analyze();
              if (!context.mounted) return;
              if (container.read(scanFlowProvider).questions.isEmpty) {
                // 직원에게 확인할 질문이 없으면 REST-06을 건너뛰고 바로 최종 결과를 받습니다.
                await scan.loadResult();
                if (context.mounted) context.push(AppRoutes.scanResult);
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
              if (context.mounted) context.push(AppRoutes.scanResult);
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
              if (context.mounted) context.push(AppRoutes.scanSaved);
            },
            onFinish: () => context.go(AppRoutes.home),
            // 이 스캔의 직원 답으로 판정한 내 기록의 메뉴 상세를 엽니다.
            onViewDetails: (menu) =>
                context.push(AppRoutes.analysisDetailOf(menu.analysisId)),
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
    title: 'Menu Detail',
    onBack: () => context.pop(),
    onRetry: onRetry,
  ),
  _ => ExploreLoadingScreen(title: 'Menu Detail', onBack: () => context.pop()),
};

/// 아직 한 번도 값을 받지 못한 채 불러오는 중이면 true입니다.
/// 다시 불러오는 중(invalidate 뒤)에는 이전 값이 있으므로 false입니다.
bool _isFirstLoad(AsyncValue<Object?> value) =>
    value.isLoading && !value.hasValue;

String? _redirectUnlessInts(GoRouterState state, List<String> keys) =>
    keys.every((key) => int.tryParse(state.pathParameters[key] ?? '') != null)
        ? null
        : AppRoutes.explore;

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