import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/allergen_item.dart';
import '../../../mypage/data/repositories/profile_repository.dart';

/// 검색어별 알레르기 성분 검색 결과입니다. 빈 검색어면 전체 목록입니다.
/// 화면이 바로 선택 상태에 담을 수 있도록 [AllergenItem]으로 바꿔 돌려줍니다.
///
/// 온보딩과 마이페이지의 알레르기 화면이 함께 씁니다. 화면을 벗어나면 결과를 버립니다.
/// 실패하면 자동으로 다시 시도하지 않고 바로 에러를 보여줍니다.
/// 화면의 다시 시도 버튼이 ref.invalidate로 다시 요청합니다.
final allergenSearchProvider = FutureProvider.autoDispose
    .family<List<AllergenItem>, String>((ref, query) async {
      final items = await ref
          .read(profileRepositoryProvider)
          .searchAllergens(query);
      return [for (final item in items) item.toAllergen()];
    }, retry: (_, _) => null);
