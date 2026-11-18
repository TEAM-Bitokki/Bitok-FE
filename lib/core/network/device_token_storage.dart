import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../providers/shared_preferences_provider.dart';

// 서버 계정을 식별하는 deviceToken(UUID v4)을 만들고 보관합니다.
// 처음 호출할 때 생성해서 저장하고, 이후에는 같은 값을 돌려줍니다.
// 앱을 지우면 값이 사라지므로 다시 가입(POST /api/auth/sign-up)해야 합니다.
class DeviceTokenStorage {
  DeviceTokenStorage(this._prefs);

  static const _key = 'device_token';

  final SharedPreferences _prefs;

  String get token {
    final saved = _prefs.getString(_key);
    if (saved != null && saved.isNotEmpty) return saved;

    final created = const Uuid().v4();
    _prefs.setString(_key, created);
    return created;
  }

  /// 회원 탈퇴 후 새 계정으로 시작할 때 사용합니다.
  Future<void> clear() => _prefs.remove(_key);
}

final deviceTokenStorageProvider = Provider<DeviceTokenStorage>((ref) {
  return DeviceTokenStorage(ref.watch(sharedPreferencesProvider));
});
