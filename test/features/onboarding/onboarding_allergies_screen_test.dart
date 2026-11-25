import 'package:bitok/core/network/api_client.dart';
import 'package:bitok/core/network/device_token_storage.dart';
import 'package:bitok/core/providers/shared_preferences_provider.dart';
import 'package:bitok/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:bitok/features/onboarding/presentation/screens/onboarding_allergies_screen.dart';
import 'package:bitok/l10n/generated/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_adapter.dart';

Map<String, Object?> _item(int id, String ko, String en) => {
  'ingredient_id': id,
  'name_ko': ko,
  'name_en': en,
  'matched_alias': null,
};

final _all = {
  'items': [_item(301, '새우', 'Shrimp'), _item(7, '계란', 'Egg')],
};

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    FakeAdapter adapter,
  ) async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        apiClientProvider.overrideWithValue(
          ApiClient(
            deviceTokenStorage: DeviceTokenStorage(prefs),
            dio: Dio()..httpClientAdapter = adapter,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingAllergiesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  List<Object?> queries(FakeAdapter adapter) =>
      adapter.requests.map((r) => r.queryParameters['q']).toList();

  testWidgets('shows the full list for an empty query', (tester) async {
    final adapter = FakeAdapter({'GET /api/ingredients/search': (200, _all)});
    await pump(tester, adapter);

    expect(queries(adapter), ['']);
    expect(find.text('Shrimp'), findsOneWidget);
    expect(find.text('Egg'), findsOneWidget);
  });

  testWidgets('searches once after typing stops', (tester) async {
    final adapter = FakeAdapter({'GET /api/ingredients/search': (200, _all)});
    await pump(tester, adapter);

    await tester.enterText(find.byType(TextField), 'e');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'egg');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(queries(adapter), ['', 'egg']);
  });

  testWidgets('selecting a result stores it by ingredient id', (tester) async {
    final adapter = FakeAdapter({'GET /api/ingredients/search': (200, _all)});
    final container = await pump(tester, adapter);

    await tester.tap(find.text('Egg'));
    await tester.pump();

    final allergies = container.read(onboardingProvider).allergies;
    expect(allergies.map((a) => a.ingredientId), [7]);
  });

  testWidgets('failure shows retry, which requests again', (tester) async {
    final adapter = FakeAdapter({
      'GET /api/ingredients/search': (500, fakeError('UNKNOWN')),
    });
    await pump(tester, adapter);

    final retry = find.text('Retry');
    expect(retry, findsOneWidget);

    adapter.routes['GET /api/ingredients/search'] = (200, _all);
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(queries(adapter), ['', '']);
    expect(find.text('Shrimp'), findsOneWidget);
  });
}
