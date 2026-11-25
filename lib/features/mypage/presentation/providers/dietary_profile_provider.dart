import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/account_provider.dart';
import '../../../onboarding/presentation/providers/onboarding_state.dart';
import '../../data/models/dietary_profile.dart';
import '../../data/repositories/profile_repository.dart';

// 이 파일을 import하던 곳이 그대로 DietaryProfile을 쓸 수 있도록 다시 내보냅니다.
export '../../data/models/dietary_profile.dart';

/// 서버에 저장된 내 식단 프로필입니다. 마이페이지와 Dietary Profile 화면이 보여줍니다.
///
/// 로그인한 계정(userId)이 바뀌면 다시 불러옵니다. (탈퇴 후 새 계정으로 가입한 경우 등)
/// 프로필을 아직 등록하지 않았으면(404) 빈 프로필입니다.
class DietaryProfileNotifier extends AsyncNotifier<DietaryProfile> {
  @override
  Future<DietaryProfile> build() async {
    final userId = ref.watch(accountProvider.select((a) => a?.userId));
    if (userId == null) return const DietaryProfile();
    final profile = await ref.read(profileRepositoryProvider).getProfile();
    return profile ?? const DietaryProfile();
  }

  /// 알레르기만 바꿔 저장합니다. 식단은 지금 값을 그대로 보냅니다.
  Future<void> saveAllergies(List<AllergenItem> allergies) =>
      _save((current) => current.copyWith(allergies: allergies));

  /// 식단만 바꿔 저장합니다. 알레르기는 지금 값을 그대로 보냅니다.
  Future<void> saveDiet({
    required DietType diet,
    required bool eatsEggs,
    required bool eatsDairy,
  }) => _save(
    (current) =>
        current.copyWith(diet: diet, eatsEggs: eatsEggs, eatsDairy: eatsDairy),
  );

  /// 진행 중인 저장입니다. 다음 저장은 이 저장이 끝난 뒤에 시작합니다.
  Future<void> _lastSave = Future.value();

  // 서버는 프로필을 통째로 덮어쓰므로, 지금 값에 바뀐 부분만 합쳐 전체를 보냅니다.
  // 저장이 겹치면 나중 요청이 앞선 변경을 되돌릴 수 있어서, 한 번에 하나씩 차례로 보냅니다.
  // 각 저장은 앞선 저장이 끝난 뒤의 최신 프로필을 기준으로 합니다.
  // 실패하면 상태를 바꾸지 않고 ApiException을 던집니다. 화면이 안내를 맡습니다.
  Future<void> _save(DietaryProfile Function(DietaryProfile current) update) {
    final save = _lastSave.then((_) => _saveNow(update));
    // 앞선 저장이 실패해도 다음 저장은 진행합니다.
    _lastSave = save.catchError((_) {});
    return save;
  }

  Future<void> _saveNow(
    DietaryProfile Function(DietaryProfile current) update,
  ) async {
    final userId = ref.read(accountProvider)?.userId;
    final current = await future;
    final saved = await ref
        .read(profileRepositoryProvider)
        .saveProfile(update(current));
    // 기다리는 동안 계정이 바뀌었으면(탈퇴 등) 이전 계정의 응답을 반영하지 않습니다.
    if (!ref.mounted || ref.read(accountProvider)?.userId != userId) return;
    state = AsyncData(saved);
  }
}

final dietaryProfileProvider =
    AsyncNotifierProvider<DietaryProfileNotifier, DietaryProfile>(
      DietaryProfileNotifier.new,
    );
