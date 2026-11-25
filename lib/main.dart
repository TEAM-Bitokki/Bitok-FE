import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/design_system/bitok_colors.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/providers/account_provider.dart';
import 'l10n/generated/app_localizations.dart';

const _kakaoNativeKey = String.fromEnvironment('KAKAO_NATIVE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  assert(
    _kakaoNativeKey.isNotEmpty,
    'dart_defines.json에 KAKAO_NATIVE_KEY를 설정하세요. '
    '(실행 설정의 Additional run args: --dart-define-from-file=dart_defines.json)',
  );
  AppConfig.validate();
  await KakaoMapSdk.instance.initialize(_kakaoNativeKey);
  final sharedPreferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );
  final initialLocation = await _resolveInitialLocation(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: BitokApp(initialLocation: initialLocation),
    ),
  );
}

/// 이미 가입하고 온보딩까지 마친 기기면 로그인 화면을 건너뛰고 홈에서 시작합니다.
///
/// 확인하는 동안에는 네이티브 스플래시가 유지됩니다. 오래 걸리거나 실패하면
/// 로그인 화면에서 시작해 Get Started로 다시 시도할 수 있게 합니다.
Future<String> _resolveInitialLocation(ProviderContainer container) async {
  final me = await container
      .read(authRepositoryProvider)
      .restoreSession()
      .timeout(const Duration(seconds: 5), onTimeout: () => null);
  if (me == null || !me.hasProfile) return AppRoutes.login;

  container.read(accountProvider.notifier).setFromMe(me);
  return AppRoutes.home;
}

class BitokApp extends StatefulWidget {
  const BitokApp({super.key, this.initialLocation = AppRoutes.login});

  final String initialLocation;

  @override
  State<BitokApp> createState() => _BitokAppState();
}

class _BitokAppState extends State<BitokApp> {
  late final GoRouter _router = createAppRouter(
    initialLocation: widget.initialLocation,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bitok',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: BitokColors.primary),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _router,
    );
  }
}
