import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// core/providers: 여러 feature가 함께 참조하는 전역 Riverpod provider를 모아둡니다.
// 예: MY-03 언어 설정처럼 여러 화면에서 SharedPreferences를 읽고 써야 할 때,
// 아래 provider 하나를 공유해서 사용합니다.
//
// main()에서 아래처럼 override 해야 실제 인스턴스가 주입됩니다:
//   final prefs = await SharedPreferences.getInstance();
//   runApp(ProviderScope(
//     overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
//     child: const BitokApp(),
//   ));
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'main()에서 sharedPreferencesProvider.overrideWithValue(...)로 주입하세요.',
  );
});
