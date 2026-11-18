import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../providers/shared_preferences_provider.dart';

// 서버 계정을 식별하는 deviceToken(UUID v4)을 만들고 보관합니다.
// 처음 호출할 때 생성해서 저장하고, 이후에는 같은 값을 돌려줍니다.
//
// SharedPreferences는 Android Auto Backup / iOS 백업 대상이라, 재설치·기기 이전 후
// 백업이 복원되면 같은 토큰(= 같은 계정)으로 이어집니다. 백업이 없으면 새 토큰이
// 만들어지고, 처음 요청에서 401 → 자동 가입됩니다.
// 복원을 막아야 한다면 AndroidManifest의 allowBackup / dataExtractionRules로 제외하세요.
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
