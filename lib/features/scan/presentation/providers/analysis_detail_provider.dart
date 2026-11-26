import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../explore/presentation/providers/menu_detail_provider.dart';
import '../../../explore/presentation/screens/menu_detail_screen.dart';
import '../../data/repositories/scan_repository.dart';

/// 내 기록의 메뉴 상세(GET /api/analyses/{analysis_id})입니다.
///
/// 스캔 결과(REST-07)·홈 Recent Checks·Saved Menus의 View details가 엽니다.
/// 그 스캔에서 받은 직원 답으로 판정합니다.
final analysisDetailProvider = FutureProvider.autoDispose.family<MenuDetail, int>(
  (ref, analysisId) async {
    final response = await ref
        .watch(scanRepositoryProvider)
        .analysisDetail(analysisId);
    return menuDetailOfResponse(response);
  },
);
