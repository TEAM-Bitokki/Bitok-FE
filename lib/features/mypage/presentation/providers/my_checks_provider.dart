import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/bitok_status_chip.dart';
import '../../../auth/presentation/providers/account_provider.dart';
import '../../../explore/presentation/models/menu_verdict.dart';
import '../../data/models/my_check_item.dart';
import '../../data/repositories/my_checks_repository.dart';
import 'dietary_profile_provider.dart';

/// 'Save to My Checks'로 저장한 메뉴 확인 결과 한 건입니다.
///
/// 홈의 Recent Checks와 마이페이지의 Saved Menus가 이 목록을 보여줍니다.
class MenuCheck {
  const MenuCheck({
    required this.id,
    required this.analysisId,
    required this.dishId,
    required this.koreanName,
    required this.englishName,
    required this.restaurantName,
    required this.status,
    required this.checkedAt,
    this.restaurantId,
  });

  factory MenuCheck.fromItem(MyCheckItem item) => MenuCheck(
    id: item.myCheckId,
    analysisId: item.analysisId,
    dishId: item.dishId,
    restaurantId: item.restaurantId,
    koreanName: item.nameKo,
    englishName: item.nameEn,
    restaurantName: item.restaurantName ?? '',
    status: menuStatusOfVerdict(item.verdict),
    // 서버 시각(+09:00)은 UTC로 읽히므로, 'Today' 같은 날짜 표시가 맞도록 기기 시간대로 바꿉니다.
    checkedAt: item.savedAt.toLocal(),
  );

  /// 서버의 my_check_id입니다.
  final int id;

  /// 내 기록의 메뉴 상세(GET /api/analyses/{analysis_id})를 열 때 씁니다.
  final int analysisId;

  final int dishId;
  final int? restaurantId;
  final String koreanName;
  final String englishName;
  final String restaurantName;

  /// 현재 프로필 기준 판정입니다. 알레르기를 바꾸면 저장할 때와 달라질 수 있습니다.
  final BitokMenuStatus status;

  /// 저장한 시각입니다.
  final DateTime checkedAt;
}

/// 지금까지 불러온 My Checks 목록과 다음 페이지 상태입니다.
class MyChecksPage {
  const MyChecksPage({
    this.items = const [],
    this.hasMore = false,
    this.nextCursor,
    this.loadingMore = false,
    this.loadMoreFailed = false,
  });

  /// 지금까지 불러온 항목입니다. 최근에 저장한 것이 앞에 옵니다.
  final List<MenuCheck> items;

  /// 서버에 다음 페이지가 남아 있으면 true입니다.
  final bool hasMore;

  /// 다음 페이지 요청에 넘길 커서입니다. 마지막 페이지면 null입니다.
  final String? nextCursor;

  /// 다음 페이지를 불러오는 중이면 true입니다. 목록 끝에 로딩 표시를 보여줍니다.
  final bool loadingMore;

  /// 다음 페이지를 불러오지 못했으면 true입니다. 스크롤로는 다시 요청하지 않고, 다시 시도 버튼을 보여줍니다.
  final bool loadMoreFailed;

  /// 다음 페이지 요청 상태만 바꿉니다. 목록과 커서를 바꿀 때는 새로 만드세요.
  MyChecksPage copyWith({bool? loadingMore, bool? loadMoreFailed}) {
    return MyChecksPage(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
      loadingMore: loadingMore ?? this.loadingMore,
      loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
    );
  }
}

/// 저장한 메뉴 확인 결과 목록(GET /api/my-checks)입니다. 최근에 저장한 것이 앞에 옵니다.
///
/// 처음에는 첫 페이지만 불러오고, 화면이 목록 끝에 가까워지면 [loadMore]로 다음 페이지를 붙입니다.
///
/// 처음부터 다시 불러오는 경우:
/// - 로그인한 계정(userId)이 바뀔 때
/// - 식단 프로필을 수정했을 때 (서버가 판정을 현재 프로필 기준으로 다시 계산하므로)
/// - 새로 저장한 뒤 (scan_flow_provider가 invalidate합니다)
class MyChecksNotifier extends AsyncNotifier<MyChecksPage> {
  /// 한 페이지 크기입니다(서버 기본값 20, 최대 50).
  static const int _pageSize = 20;

  @override
  Future<MyChecksPage> build() async {
    final userId = ref.watch(accountProvider.select((a) => a?.userId));
    if (userId == null) return const MyChecksPage();

    // watch로 두면 프로필을 (다시) 불러오는 순간마다 목록도 한 번 더 요청합니다.
    // (앱 시작, 계정이 바뀔 때 — 계정 변경은 위의 userId watch가 이미 다시 불러옵니다)
    // 그래서 불러오기가 끝난 프로필이 다른 값으로 바로 바뀔 때, 즉 수정·저장했을 때만 다시 불러옵니다.
    ref.listen(dietaryProfileProvider, (previous, next) {
      if (previous == null || previous.isLoading || next.isLoading) return;
      final before = previous.value;
      final after = next.value;
      if (before != null && after != null && !identical(before, after)) {
        ref.invalidateSelf();
      }
    });

    final response = await ref
        .read(myChecksRepositoryProvider)
        .list(limit: _pageSize);
    return MyChecksPage(
      items: response.items.map(MenuCheck.fromItem).toList(),
      hasMore: response.page.hasMore,
      nextCursor: response.page.nextCursor,
    );
  }

  /// 다음 페이지를 불러와 목록 뒤에 붙입니다.
  ///
  /// 이미 불러오는 중이거나 더 없으면 아무것도 하지 않습니다.
  /// 한 번 실패하면 스크롤로는 다시 요청하지 않고, [retry]가 true일 때(다시 시도 버튼)만 요청합니다.
  /// 실패하면 [MyChecksPage.loadMoreFailed]를 켜고 ApiException을 던집니다. 화면이 안내를 맡습니다.
  Future<void> loadMore({bool retry = false}) async {
    final current = state.value;
    if (current == null || state.isLoading) return;
    final cursor = current.nextCursor;
    if (!current.hasMore || current.loadingMore || cursor == null) return;
    if (current.loadMoreFailed && !retry) return;

    final loading = current.copyWith(loadingMore: true, loadMoreFailed: false);
    state = AsyncData(loading);

    // 기다리는 동안 처음부터 다시 불러왔으면(저장·계정 변경 등) 상태가 바뀌어 있습니다.
    // 그때는 이 요청의 결과를 버립니다. (Riverpod 3는 다시 불러올 때 Notifier를 새로 만들므로,
    // Notifier 필드가 아니라 상태 객체가 그대로인지로 판단합니다)
    bool stillCurrent() =>
        ref.mounted && !state.isLoading && identical(state.value, loading);

    try {
      final response = await ref
          .read(myChecksRepositoryProvider)
          .list(cursor: cursor, limit: _pageSize);
      if (!stillCurrent()) return;
      state = AsyncData(
        MyChecksPage(
          items: [...loading.items, ...response.items.map(MenuCheck.fromItem)],
          hasMore: response.page.hasMore,
          nextCursor: response.page.nextCursor,
        ),
      );
    } catch (_) {
      if (stillCurrent()) {
        state = AsyncData(
          loading.copyWith(loadingMore: false, loadMoreFailed: true),
        );
      }
      rethrow;
    }
  }
}

final myChecksProvider = AsyncNotifierProvider<MyChecksNotifier, MyChecksPage>(
  MyChecksNotifier.new,
);
