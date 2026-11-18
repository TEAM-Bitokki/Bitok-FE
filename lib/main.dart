import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_sdk/kakao_map_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/design_system/bitok_colors.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/router/app_router.dart';
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

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const BitokApp(),
    ),
  );
}

class BitokApp extends StatelessWidget {
  const BitokApp({super.key});

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
      routerConfig: appRouter,
    );
  }
}