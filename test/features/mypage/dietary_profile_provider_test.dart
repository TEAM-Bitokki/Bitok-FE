import 'package:bitok/core/models/allergen_item.dart';
import 'package:bitok/core/models/diet_type.dart';
import 'package:bitok/core/network/api_client.dart';
import 'package:bitok/core/network/api_exception.dart';
import 'package:bitok/core/network/device_token_storage.dart';
import 'package:bitok/core/providers/shared_preferences_provider.dart';
import 'package:bitok/features/auth/presentation/providers/account_provider.dart';
import 'package:bitok/features/auth/presentation/providers/login_provider.dart';
import 'package:bitok/features/mypage/presentation/providers/dietary_profile_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_adapter.dart';

const _me = {
  'user_id': 1,
  'nickname': 'Hyunjin',
  'has_profile': true,
  'diet_type': 'vegetarian',
  'allergen_count': 1,
};

const _profile = {
  'allergens': [
    {'ingredient_id': 301, 'name_ko': '새우', 'name_en': 'Shrimp'},
  ],
  'diet_type': 'vegetarian',
  'diet_options': ['eats_egg'],
};

const _egg = AllergenItem(ingredientId: 7, nameKo: '계란', nameEn: 'Egg');

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  /// 로그인까지 마친 컨테이너를 돌려줍니다.
  Future<ProviderContainer> loggedIn(FakeAdapter adapter) async {
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
    return c;
  }

  test('loads the profile from the server after login', () async {
    final c = await loggedIn(
      FakeAdapter({
        'GET /api/auth/me': (200, _me),
        'GET /api/profiles/me': (200, _profile),
      }),
    );
    final profile = await c.read(dietaryProfileProvider.future);

    expect(profile.allergies.single.nameEn, 'Shrimp');
    expect(profile.diet, DietType.vegetarian);
    expect(profile.eatsEggs, isTrue);
  });

  test('no profile yet (404) -> empty profile', () async {
    final c = await loggedIn(
      FakeAdapter({
        'GET /api/auth/me': (200, {..._me, 'has_profile': false}),
        'GET /api/profiles/me': (404, fakeError('NOT_FOUND')),
      }),
    );
    final profile = await c.read(dietaryProfileProvider.future);

    expect(profile.allergies, isEmpty);
    expect(profile.diet, DietType.noParticularDiet);
  });

  test('saveAllergies sends the whole profile with the current diet', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, _me),
      'GET /api/profiles/me': (200, _profile),
      'PUT /api/profiles/me': (
        200,
        {
          ..._profile,
          'allergens': [
            {'ingredient_id': 7, 'name_ko': '계란', 'name_en': 'Egg'},
          ],
        },
      ),
    });
    final c = await loggedIn(adapter);
    await c.read(dietaryProfileProvider.future);

    await c.read(dietaryProfileProvider.notifier).saveAllergies([_egg]);

    expect(adapter.requests.last.data, {
      'allergen_ingredient_ids': [7],
      'diet_type': 'vegetarian',
      'diet_options': ['eats_egg'],
    });
    expect(c.read(dietaryProfileProvider).value!.allergies, [_egg]);
  });

  test(
    'saveDiet keeps allergies and drops options for non-vegetarian',
    () async {
      final adapter = FakeAdapter({
        'GET /api/auth/me': (200, _me),
        'GET /api/profiles/me': (200, _profile),
        'PUT /api/profiles/me': (
          200,
          {..._profile, 'diet_type': 'vegan', 'diet_options': <String>[]},
        ),
      });
      final c = await loggedIn(adapter);
      await c.read(dietaryProfileProvider.future);

      await c
          .read(dietaryProfileProvider.notifier)
          .saveDiet(diet: DietType.vegan, eatsEggs: true, eatsDairy: false);

      expect(adapter.requests.last.data, {
        'allergen_ingredient_ids': [301],
        'diet_type': 'vegan',
        'diet_options': <String>[],
      });
      expect(c.read(dietaryProfileProvider).value!.diet, DietType.vegan);
    },
  );

  test('save failure keeps the previous profile and throws', () async {
    final c = await loggedIn(
      FakeAdapter({
        'GET /api/auth/me': (200, _me),
        'GET /api/profiles/me': (200, _profile),
        'PUT /api/profiles/me': (400, fakeError('VALIDATION_ERROR')),
      }),
    );
    await c.read(dietaryProfileProvider.future);

    await expectLater(
      c.read(dietaryProfileProvider.notifier).saveAllergies([_egg]),
      throwsA(isA<ApiException>()),
    );
    expect(
      c.read(dietaryProfileProvider).value!.allergies.single.nameEn,
      'Shrimp',
    );
  });

  test('after account deletion the old profile is not shown', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, _me),
      'GET /api/profiles/me': (200, _profile),
      'DELETE /api/users/me': (204, null),
    });
    final c = await loggedIn(adapter);
    final sub = c.listen(dietaryProfileProvider, (_, _) {});
    addTearDown(sub.close);
    expect((await c.read(dietaryProfileProvider.future)).allergies, isNotEmpty);

    await c
        .read(accountProvider.notifier)
        .deleteAccount(deleteSavedMenus: false);

    expect((await c.read(dietaryProfileProvider.future)).allergies, isEmpty);
  });
}
