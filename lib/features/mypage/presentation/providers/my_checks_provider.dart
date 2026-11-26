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

/// 저장한 메뉴 확인 결과 목록(GET /api/my-checks)입니다. 최근에 저장한 것이 앞에 옵니다.
///
/// 다시 불러오는 경우:
/// - 로그인한 계정(userId)이 바뀔 때
/// - 식단 프로필을 수정했을 때 (서버가 판정을 현재 프로필 기준으로 다시 계산하므로)
/// - 새로 저장한 뒤 (scan_flow_provider가 invalidate합니다)
class MyChecksNotifier extends AsyncNotifier<List<MenuCheck>> {
  /// 한 번에 불러오는 개수입니다(서버 최대값).
  // TODO: Saved Menus에 무한 스크롤이 필요해지면 page.nextCursor로 다음 페이지를 불러옵니다.
  static const int _limit = 50;

  @override
  Future<List<MenuCheck>> build() async {
    final userId = ref.watch(accountProvider.select((a) => a?.userId));
    if (userId == null) return const [];

    // watch로 두면 앱 시작 때 프로필이 처음 불러와지는 순간에도 목록을 한 번 더 요청합니다.
    // 그래서 이미 불러온 프로필이 다른 값으로 바뀔 때(수정·저장)만 다시 불러옵니다.
    ref.listen(dietaryProfileProvider, (previous, next) {
      final before = previous?.value;
      final after = next.value;
      if (before != null && after != null && !identical(before, after)) {
        ref.invalidateSelf();
      }
    });

    final response = await ref
        .read(myChecksRepositoryProvider)
        .list(limit: _limit);
    return response.items.map(MenuCheck.fromItem).toList();
  }
}

final myChecksProvider =
    AsyncNotifierProvider<MyChecksNotifier, List<MenuCheck>>(
      MyChecksNotifier.new,
    );
