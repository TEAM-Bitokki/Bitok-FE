import 'dart:async';

import 'package:bitok/core/models/allergen_item.dart';
import 'package:bitok/core/models/diet_type.dart';
import 'package:bitok/core/network/api_client.dart';
import 'package:bitok/core/network/api_exception.dart';
import 'package:bitok/core/network/device_token_storage.dart';
import 'package:bitok/core/providers/shared_preferences_provider.dart';
import 'package:bitok/features/auth/presentation/providers/account_provider.dart';
import 'package:bitok/features/auth/presentation/providers/login_provider.dart';
import 'package:bitok/features/mypage/presentation/providers/dietary_profile_provider.dart';
import 'package:bitok/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_adapter.dart';

const _me = {
  'user_id': 1,
  'nickname': null,
  'has_profile': false,
  'diet_type': null,
  'allergen_count': 0,
};

const _savedProfile = {
  'allergens': [
    {'ingredient_id': 7, 'name_ko': '계란', 'name_en': 'Egg'},
  ],
  'diet_type': 'vegetarian',
  'diet_options': ['eats_dairy'],
};

const _egg = AllergenItem(ingredientId: 7, nameKo: '계란', nameEn: 'Egg');

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  /// 로그인하고 온보딩 입력(닉네임·계란 알레르기·채식+유제품)을 마친 컨테이너입니다.
  Future<ProviderContainer> filledIn(FakeAdapter adapter) async {
    final c = ProviderContainer(
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
    addTearDown(c.dispose);
    await c.read(loginProvider.notifier).start();
    c.read(onboardingProvider.notifier)
      ..setNickname(' Hyunjin ')
      ..toggleAllergy(_egg)
      ..selectDiet(DietType.vegetarian)
      ..setEatsDairy(true);
    return c;
  }

  List<String> calls(FakeAdapter adapter) =>
      adapter.requests.map((r) => '${r.method} ${r.path}').toList();

  test('saves nickname, then the whole profile', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, _me),
      'PATCH /api/users/me': (200, {..._me, 'nickname': 'Hyunjin'}),
      'PUT /api/profiles/me': (200, _savedProfile),
    });
    final c = await filledIn(adapter);

    await c.read(onboardingProvider.notifier).submit();

    expect(calls(adapter), [
      'GET /api/auth/me',
      'PATCH /api/users/me',
      'PUT /api/profiles/me',
    ]);
    final [_, patch, put] = adapter.requests;
    expect(patch.data, {'nickname': 'Hyunjin'});
    expect(put.data, {
      'allergen_ingredient_ids': [7],
      'diet_type': 'vegetarian',
      'diet_options': ['eats_dairy'],
    });
    expect(c.read(accountProvider)!.nickname, 'Hyunjin');
  });

  test('nickname failure: throws and does not send the profile', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, _me),
      'PATCH /api/users/me': (422, fakeError('VALIDATION_ERROR')),
    });
    final c = await filledIn(adapter);

    await expectLater(
      c.read(onboardingProvider.notifier).submit(),
      throwsA(isA<ApiException>()),
    );
    expect(calls(adapter), ['GET /api/auth/me', 'PATCH /api/users/me']);
  });

  test('profile failure throws; retry sends both again', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, _me),
      'PATCH /api/users/me': (200, {..._me, 'nickname': 'Hyunjin'}),
      'PUT /api/profiles/me': (500, fakeError('UNKNOWN')),
    });
    final c = await filledIn(adapter);
    final notifier = c.read(onboardingProvider.notifier);

    await expectLater(notifier.submit(), throwsA(isA<ApiException>()));

    adapter.routes['PUT /api/profiles/me'] = (200, _savedProfile);
    await notifier.submit();

    expect(calls(adapter).skip(1), [
      'PATCH /api/users/me',
      'PUT /api/profiles/me',
      'PATCH /api/users/me',
      'PUT /api/profiles/me',
    ]);
  });

  test('already loaded profile is refreshed after submit', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, _me),
      'GET /api/profiles/me': (404, fakeError('NOT_FOUND')),
      'PATCH /api/users/me': (200, {..._me, 'nickname': 'Hyunjin'}),
      'PUT /api/profiles/me': (200, _savedProfile),
    });
    final c = await filledIn(adapter);
    // 마이페이지처럼 프로필을 지켜보는 곳이 있는 경우입니다.
    final sub = c.listen(dietaryProfileProvider, (_, _) {});
    addTearDown(sub.close);
    expect((await c.read(dietaryProfileProvider.future)).allergies, isEmpty);

    adapter.routes['GET /api/profiles/me'] = (200, _savedProfile);
    await c.read(onboardingProvider.notifier).submit();

    final profile = await c.read(dietaryProfileProvider.future);
    expect(profile.allergies, [_egg]);
    expect(profile.eatsDairy, isTrue);
  });

  test('input changed while saving is not sent', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, _me),
      'PATCH /api/users/me': (200, {..._me, 'nickname': 'Hyunjin'}),
      'PUT /api/profiles/me': (200, _savedProfile),
    });
    final c = await filledIn(adapter);
    final gate = Completer<void>();
    adapter.gates['PATCH /api/users/me'] = gate.future;
    final notifier = c.read(onboardingProvider.notifier);

    final submit = notifier.submit();
    await pumpEventQueue();
    notifier.selectDiet(DietType.vegan); // 닉네임 저장을 기다리는 동안 식단을 바꿈
    gate.complete();
    await submit;

    expect((adapter.requests.last.data as Map)['diet_type'], 'vegetarian');
  });
}
