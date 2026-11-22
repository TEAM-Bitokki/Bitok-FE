import 'package:bitok/core/network/api_client.dart';
import 'package:bitok/core/network/api_exception.dart';
import 'package:bitok/core/network/device_token_storage.dart';
import 'package:bitok/core/network/error_code.dart';
import 'package:bitok/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bitok/features/auth/data/repositories/auth_repository.dart';
import 'package:bitok/core/models/diet_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_adapter.dart';

const _me = {
  'user_id': 1,
  'nickname': null,
  'has_profile': false,
  'diet_type': 'none',
  'allergen_count': 0,
};

void main() {
  late DeviceTokenStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = DeviceTokenStorage(await SharedPreferences.getInstance());
  });

  AuthRepository repo(FakeAdapter adapter) {
    final api = ApiClient(deviceTokenStorage: storage, dio: Dio()..httpClientAdapter = adapter);
    return AuthRepository(AuthRemoteDataSource(api), storage);
  }

  test('registered device: returns me without sign-up', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, {..._me, 'has_profile': true, 'diet_type': 'vegan'}),
    });
    final me = await repo(adapter).signInOrSignUp();
    expect(me.hasProfile, isTrue);
    expect(me.dietType, DietType.vegan);
    expect(adapter.requests.map((r) => r.path), ['/api/auth/me']);
    expect(adapter.requests.single.headers['deviceToken'], storage.token);
  });

  test('unregistered device: 401 -> sign-up with token in body, no header', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (401, fakeError('UNAUTHORIZED')),
      'POST /api/auth/sign-up': (200, _me),
    });
    final me = await repo(adapter).signInOrSignUp();
    expect(me.userId, 1);
    expect(me.hasProfile, isFalse);
    expect(me.dietType, DietType.noParticularDiet);

    expect(adapter.requests.map((r) => '${r.method} ${r.path}'), [
      'GET /api/auth/me',
      'POST /api/auth/sign-up',
    ]);
    final [me0, signUp] = adapter.requests;
    expect(signUp.headers.containsKey('deviceToken'), isFalse);
    expect(signUp.data, {'device_token': me0.headers['deviceToken']});
    expect(signUp.data, {'device_token': storage.token});
  });

  test('unknown diet_type does not crash', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, {..._me, 'diet_type': 'keto'}),
    });
    expect((await repo(adapter).signInOrSignUp()).dietType, isNull);
  });

  test('malformed 200 body -> ApiException(invalidResponse), no sign-up', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (200, {'user_id': 1}), // has_profile 누락
    });
    await expectLater(repo(adapter).signInOrSignUp(),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', ErrorCode.invalidResponse)));
    expect(adapter.requests, hasLength(1));
  });

  test('non-string error code/message falls back safely', () async {
    final adapter = FakeAdapter({
      'GET /api/auth/me': (500, {'error': {'code': 123, 'message': null}}),
    });
    await expectLater(repo(adapter).signInOrSignUp(),
        throwsA(isA<ApiException>()
            .having((e) => e.code, 'code', ErrorCode.unknown)
            .having((e) => e.message, 'message', '')
            .having((e) => e.statusCode, 'status', 500)));
  });

  test('other errors are rethrown without sign-up', () async {
    final adapter = FakeAdapter({'GET /api/auth/me': (502, fakeError('MAP_UNAVAILABLE'))});
    await expectLater(repo(adapter).signInOrSignUp(),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', ErrorCode.mapUnavailable)));
    expect(adapter.requests, hasLength(1));
  });

  test('updateNickname trims and sends PATCH', () async {
    final adapter = FakeAdapter({
      'PATCH /api/users/me': (200, {..._me, 'nickname': 'Hyunjin'}),
    });
    final me = await repo(adapter).updateNickname('  Hyunjin ');
    expect(me.nickname, 'Hyunjin');
    expect(adapter.requests.single.data, {'nickname': 'Hyunjin'});
  });

  test('deleteAccount: clears token so next start signs up again', () async {
    final adapter = FakeAdapter({'DELETE /api/users/me': (204, null)});
    final oldToken = storage.token;

    await repo(adapter).deleteAccount(deleteSavedMenus: false);

    expect(adapter.requests.single.data, {'agree': true, 'delete_saved_menus': false});
    expect(adapter.requests.single.headers['deviceToken'], oldToken);
    expect(storage.token, isNot(oldToken));
  });

  test('deleteAccount failure keeps the token', () async {
    final adapter = FakeAdapter({'DELETE /api/users/me': (401, fakeError('UNAUTHORIZED'))});
    final oldToken = storage.token;

    await expectLater(repo(adapter).deleteAccount(deleteSavedMenus: true),
        throwsA(isA<ApiException>().having((e) => e.code, 'code', ErrorCode.unauthorized)));
    expect(storage.token, oldToken);
  });
}
