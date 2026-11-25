import 'dart:async';

import 'package:bitok/core/network/api_client.dart';
import 'package:bitok/core/providers/shared_preferences_provider.dart';
import 'package:bitok/core/network/api_exception.dart';
import 'package:bitok/core/network/device_token_storage.dart';
import 'package:bitok/features/auth/presentation/providers/account_provider.dart';
import 'package:bitok/features/auth/presentation/providers/login_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late SharedPreferences prefs;
  late DeviceTokenStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = DeviceTokenStorage(prefs);
  });

  ProviderContainer container(FakeAdapter adapter) {
    final c = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        apiClientProvider.overrideWithValue(
          ApiClient(
            deviceTokenStorage: storage,
            dio: Dio()..httpClientAdapter = adapter,
          ),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('null before login, filled from me after login', () async {
    final c = container(FakeAdapter({'GET /api/auth/me': (200, _me)}));
    expect(c.read(accountProvider), isNull);

    await c.read(loginProvider.notifier).start();

    final account = c.read(accountProvider)!;
    expect(account.userId, 1);
    expect(account.nickname, ''); // 온보딩 전이라 닉네임이 없음
  });

  test('saveNickname updates state from the server response', () async {
    final c = container(
      FakeAdapter({
        'GET /api/auth/me': (200, _me),
        'PATCH /api/users/me': (200, {..._me, 'nickname': 'Hyunjin'}),
      }),
    );
    await c.read(loginProvider.notifier).start();

    await c.read(accountProvider.notifier).saveNickname('Hyunjin');

    expect(c.read(accountProvider)!.nickname, 'Hyunjin');
  });

  test('saveNickname failure keeps the previous state and throws', () async {
    final c = container(
      FakeAdapter({
        'GET /api/auth/me': (200, {..._me, 'nickname': 'Old'}),
        'PATCH /api/users/me': (422, fakeError('VALIDATION_ERROR')),
      }),
    );
    await c.read(loginProvider.notifier).start();

    await expectLater(
      c.read(accountProvider.notifier).saveNickname('x' * 21),
      throwsA(isA<ApiException>()),
    );
    expect(c.read(accountProvider)!.nickname, 'Old');
  });

  test(
    'deleteAccount: logs out, and next login signs up with a new token',
    () async {
      final adapter = FakeAdapter({
        'GET /api/auth/me': (200, {..._me, 'nickname': 'Old'}),
        'DELETE /api/users/me': (204, null),
      });
      final c = container(adapter);
      await c.read(loginProvider.notifier).start();
      final oldToken = adapter.requests.single.headers['deviceToken'];

      await c
          .read(accountProvider.notifier)
          .deleteAccount(deleteSavedMenus: true);

      expect(c.read(accountProvider), isNull);
      expect(adapter.requests.last.data, {
        'agree': true,
        'delete_saved_menus': true,
      });

      // 서버에서 계정이 사라졌으므로 새 토큰은 401 → 가입으로 이어집니다.
      adapter.routes['GET /api/auth/me'] = (401, fakeError('UNAUTHORIZED'));
      adapter.routes['POST /api/auth/sign-up'] = (200, {..._me, 'user_id': 2});
      await c.read(loginProvider.notifier).start();

      final signUp = adapter.requests.last;
      expect(signUp.path, '/api/auth/sign-up');
      expect((signUp.data as Map)['device_token'], isNot(oldToken));
      expect(c.read(accountProvider)!.userId, 2);
    },
  );

  test('deleteAccount failure keeps the account and throws', () async {
    final c = container(
      FakeAdapter({
        'GET /api/auth/me': (200, _me),
        'DELETE /api/users/me': (500, fakeError('UNKNOWN')),
      }),
    );
    await c.read(loginProvider.notifier).start();

    await expectLater(
      c.read(accountProvider.notifier).deleteAccount(deleteSavedMenus: false),
      throwsA(isA<ApiException>()),
    );
    expect(c.read(accountProvider)!.userId, 1);
  });

  test(
    'nickname response after account deletion does not log back in',
    () async {
      final adapter = FakeAdapter({
        'GET /api/auth/me': (200, _me),
        'PATCH /api/users/me': (200, {..._me, 'nickname': 'Late'}),
        'DELETE /api/users/me': (204, null),
      });
      final c = container(adapter);
      await c.read(loginProvider.notifier).start();
      final gate = Completer<void>();
      adapter.gates['PATCH /api/users/me'] = gate.future;

      final save = c.read(accountProvider.notifier).saveNickname('Late');
      await pumpEventQueue();
      await c
          .read(accountProvider.notifier)
          .deleteAccount(deleteSavedMenus: false);
      gate.complete();
      await save;

      expect(c.read(accountProvider), isNull);
    },
  );
}
