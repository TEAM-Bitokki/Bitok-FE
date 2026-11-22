import 'package:bitok/core/models/allergen_item.dart';
import 'package:bitok/core/models/diet_option.dart';
import 'package:bitok/core/models/diet_type.dart';
import 'package:bitok/core/network/api_client.dart';
import 'package:bitok/core/network/api_exception.dart';
import 'package:bitok/core/network/device_token_storage.dart';
import 'package:bitok/core/network/error_code.dart';
import 'package:bitok/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bitok/features/auth/data/models/delete_account_request.dart';
import 'package:bitok/features/auth/data/models/nickname_request.dart';
import 'package:bitok/features/mypage/data/datasources/profile_remote_data_source.dart';
import 'package:bitok/features/mypage/data/models/profile_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_adapter.dart';

const _profile = {
  'allergens': [
    {'ingredient_id': 301, 'name_ko': '새우', 'name_en': 'Shrimp'},
  ],
  'diet_type': 'vegetarian',
  'diet_options': ['eats_egg', 'eats_dairy'],
};

const _me = {
  'user_id': 1,
  'nickname': 'Hyunjin',
  'has_profile': true,
  'diet_type': 'vegetarian',
  'allergen_count': 1,
};

void main() {
  late DeviceTokenStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = DeviceTokenStorage(await SharedPreferences.getInstance());
  });

  ApiClient api(FakeAdapter adapter) => ApiClient(
    deviceTokenStorage: storage,
    dio: Dio()..httpClientAdapter = adapter,
  );

  group('ProfileRemoteDataSource', () {
    test('getProfile parses allergens, diet type and options', () async {
      final adapter = FakeAdapter({'GET /api/profiles/me': (200, _profile)});
      final profile = await ProfileRemoteDataSource(api(adapter)).getProfile();

      expect(profile.allergens, [
        const AllergenItem(ingredientId: 301, nameKo: '새우', nameEn: 'Shrimp'),
      ]);
      expect(profile.allergens.single.nameEn, 'Shrimp');
      expect(profile.dietType, DietType.vegetarian);
      expect(profile.dietOptions, [DietOption.eatsEgg, DietOption.eatsDairy]);
      expect(adapter.requests.single.headers['deviceToken'], storage.token);
    });

    test('getProfile: missing diet_options and unknown diet_type', () async {
      final adapter = FakeAdapter({
        'GET /api/profiles/me': (
          200,
          {'allergens': <Object>[], 'diet_type': 'keto'},
        ),
      });
      final profile = await ProfileRemoteDataSource(api(adapter)).getProfile();

      expect(profile.dietType, isNull);
      expect(profile.dietOptions, isEmpty);
    });

    test('getProfile: no profile -> ApiException(notFound)', () async {
      final adapter = FakeAdapter({
        'GET /api/profiles/me': (404, fakeError('NOT_FOUND')),
      });
      await expectLater(
        ProfileRemoteDataSource(api(adapter)).getProfile(),
        throwsA(
          isA<ApiException>().having((e) => e.code, 'code', ErrorCode.notFound),
        ),
      );
    });

    test('putProfile sends snake_case body with server enum values', () async {
      final adapter = FakeAdapter({'PUT /api/profiles/me': (200, _profile)});
      await ProfileRemoteDataSource(api(adapter)).putProfile(
        const ProfileRequest(
          allergenIngredientIds: [301, 305],
          dietType: DietType.vegetarian,
          dietOptions: [DietOption.eatsEgg],
        ),
      );

      expect(adapter.requests.single.data, {
        'allergen_ingredient_ids': [301, 305],
        'diet_type': 'vegetarian',
        'diet_options': ['eats_egg'],
      });
    });

    test('putProfile: no particular diet is sent as "none"', () async {
      final adapter = FakeAdapter({'PUT /api/profiles/me': (200, _profile)});
      await ProfileRemoteDataSource(api(adapter)).putProfile(
        const ProfileRequest(
          allergenIngredientIds: [],
          dietType: DietType.noParticularDiet,
        ),
      );

      expect(adapter.requests.single.data, {
        'allergen_ingredient_ids': <int>[],
        'diet_type': 'none',
        'diet_options': <String>[],
      });
    });

    test('searchIngredients sends q and limit, parses matched_alias', () async {
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
      final result = await ProfileRemoteDataSource(
        api(adapter),
      ).searchIngredients(query: ' 달걀 ', limit: 10);

      expect(adapter.requests.single.queryParameters, {'q': '달걀', 'limit': 10});
      final item = result.items.single;
      expect(item.matchedAlias, '달걀');
      expect(
        item.toAllergen(),
        const AllergenItem(ingredientId: 7, nameKo: '계란', nameEn: 'Egg'),
      );
    });

    test('searchIngredients: empty query, limit omitted', () async {
      final adapter = FakeAdapter({
        'GET /api/ingredients/search': (200, {'items': <Object>[]}),
      });
      await ProfileRemoteDataSource(api(adapter)).searchIngredients();

      expect(adapter.requests.single.queryParameters, {'q': ''});
    });
  });

  group('AuthRemoteDataSource account APIs', () {
    test('updateNickname sends PATCH and returns me', () async {
      final adapter = FakeAdapter({'PATCH /api/users/me': (200, _me)});
      final me = await AuthRemoteDataSource(
        api(adapter),
      ).updateNickname(const NicknameRequest(nickname: 'Hyunjin'));

      expect(me.nickname, 'Hyunjin');
      expect(adapter.requests.single.data, {'nickname': 'Hyunjin'});
    });

    test('deleteAccount sends DELETE with body and accepts 204', () async {
      final adapter = FakeAdapter({'DELETE /api/users/me': (204, null)});
      await AuthRemoteDataSource(api(adapter)).deleteAccount(
        const DeleteAccountRequest(agree: true, deleteSavedMenus: true),
      );

      final request = adapter.requests.single;
      expect(request.data, {'agree': true, 'delete_saved_menus': true});
      expect(request.headers['deviceToken'], storage.token);
    });
  });
}
