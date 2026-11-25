import 'package:bitok/core/models/allergen_item.dart';
import 'package:bitok/core/models/diet_type.dart';
import 'package:bitok/core/network/api_client.dart';
import 'package:bitok/core/network/api_exception.dart';
import 'package:bitok/core/network/device_token_storage.dart';
import 'package:bitok/core/network/error_code.dart';
import 'package:bitok/features/mypage/data/datasources/profile_remote_data_source.dart';
import 'package:bitok/features/mypage/data/models/dietary_profile.dart';
import 'package:bitok/features/mypage/data/repositories/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_adapter.dart';

const _shrimp = AllergenItem(ingredientId: 301, nameKo: '새우', nameEn: 'Shrimp');

Map<String, Object?> _profileJson({
  String dietType = 'vegetarian',
  List<String> dietOptions = const [],
}) => {
  'allergens': [
    {'ingredient_id': 301, 'name_ko': '새우', 'name_en': 'Shrimp'},
  ],
  'diet_type': dietType,
  'diet_options': dietOptions,
};

void main() {
  late DeviceTokenStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = DeviceTokenStorage(await SharedPreferences.getInstance());
  });

  ProfileRepository repo(FakeAdapter adapter) => ProfileRepository(
    ProfileRemoteDataSource(
      ApiClient(
        deviceTokenStorage: storage,
        dio: Dio()..httpClientAdapter = adapter,
      ),
    ),
  );

  group('getProfile', () {
    test('converts diet_options to eatsEggs/eatsDairy', () async {
      final adapter = FakeAdapter({
        'GET /api/profiles/me': (200, _profileJson(dietOptions: ['eats_egg'])),
      });
      final profile = await repo(adapter).getProfile();

      expect(profile!.allergies, [_shrimp]);
      expect(profile.diet, DietType.vegetarian);
      expect(profile.eatsEggs, isTrue);
      expect(profile.eatsDairy, isFalse);
    });

    test('ignores diet_options when not vegetarian', () async {
      final adapter = FakeAdapter({
        'GET /api/profiles/me': (
          200,
          _profileJson(dietType: 'vegan', dietOptions: ['eats_egg']),
        ),
      });
      final profile = await repo(adapter).getProfile();

      expect(profile!.diet, DietType.vegan);
      expect(profile.eatsEggs, isFalse);
    });

    test('404 -> null (no profile yet)', () async {
      final adapter = FakeAdapter({
        'GET /api/profiles/me': (404, fakeError('NOT_FOUND')),
      });
      expect(await repo(adapter).getProfile(), isNull);
    });

    test(
      'unknown diet_type -> invalidResponse instead of defaulting',
      () async {
        final adapter = FakeAdapter({
          'GET /api/profiles/me': (200, _profileJson(dietType: 'keto')),
        });
        await expectLater(
          repo(adapter).getProfile(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.code,
              'code',
              ErrorCode.invalidResponse,
            ),
          ),
        );
      },
    );

    test('other errors are rethrown', () async {
      final adapter = FakeAdapter({
        'GET /api/profiles/me': (401, fakeError('UNAUTHORIZED')),
      });
      await expectLater(
        repo(adapter).getProfile(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ErrorCode.unauthorized,
          ),
        ),
      );
    });
  });

  group('saveProfile', () {
    test('vegetarian: sends ids and diet_options, returns saved', () async {
      final adapter = FakeAdapter({
        'PUT /api/profiles/me': (
          200,
          _profileJson(dietOptions: ['eats_egg', 'eats_dairy']),
        ),
      });
      final saved = await repo(adapter).saveProfile(
        const DietaryProfile(
          allergies: [_shrimp],
          diet: DietType.vegetarian,
          eatsEggs: true,
          eatsDairy: true,
        ),
      );

      expect(adapter.requests.single.data, {
        'allergen_ingredient_ids': [301],
        'diet_type': 'vegetarian',
        'diet_options': ['eats_egg', 'eats_dairy'],
      });
      expect(saved.eatsEggs && saved.eatsDairy, isTrue);
    });

    test('not vegetarian: diet_options are not sent', () async {
      final adapter = FakeAdapter({
        'PUT /api/profiles/me': (200, _profileJson(dietType: 'pescatarian')),
      });
      await repo(adapter).saveProfile(
        const DietaryProfile(
          diet: DietType.pescatarian,
          eatsEggs: true,
          eatsDairy: true,
        ),
      );

      expect(adapter.requests.single.data, {
        'allergen_ingredient_ids': <int>[],
        'diet_type': 'pescatarian',
        'diet_options': <String>[],
      });
    });
  });

  test('searchAllergens returns items with alias', () async {
    final adapter = FakeAdapter({
      'GET /api/ingredients/search': (
        200,
        {
          'items': [
            {
              'ingredient_id': 7,
              'name_ko': '계란',
              'name_en': 'Egg',
              'matched_alias': '달걀',
            },
          ],
        },
      ),
    });
    final items = await repo(adapter).searchAllergens('달걀');

    expect(items.single.matchedAlias, '달걀');
    expect(adapter.requests.single.queryParameters, {'q': '달걀'});
  });
}
