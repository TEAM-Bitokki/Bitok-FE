import 'package:bitok/features/auth/data/models/nickname_request.dart';
import 'package:bitok/features/mypage/presentation/screens/edit_profile_screen.dart';
import 'package:bitok/features/onboarding/presentation/screens/onboarding_nickname_screen.dart';
import 'package:bitok/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _tooLongMessage = 'Nickname must be 20 characters or less';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  group('NicknameRequest.isTooLong', () {
    test('20 characters is allowed, 21 is too long', () {
      expect(NicknameRequest.isTooLong('a' * 20), isFalse);
      expect(NicknameRequest.isTooLong('a' * 21), isTrue);
    });

    test('Korean counts one per character', () {
      expect(NicknameRequest.isTooLong('가' * 20), isFalse);
      expect(NicknameRequest.isTooLong('가' * 21), isTrue);
    });

    test('emoji counts as one, like the server', () {
      // '😀'.length == 2 in Dart, but the server counts it as 1.
      expect(NicknameRequest.isTooLong('😀' * 20), isFalse);
      expect(NicknameRequest.isTooLong('😀' * 21), isTrue);
    });

    test('surrounding spaces are not counted', () {
      expect(NicknameRequest.isTooLong('  ${'a' * 20}  '), isFalse);
    });
  });

  testWidgets('edit profile: too long -> snackbar, onSave not called', (
    tester,
  ) async {
    var saved = 0;
    await tester.pumpWidget(
      _app(
        EditProfileScreen(initialNickname: '', onSave: (_) async => saved++),
      ),
    );

    await tester.enterText(find.byType(TextField), 'a' * 21);
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text(_tooLongMessage), findsOneWidget);
    expect(saved, 0);

    await tester.enterText(find.byType(TextField), 'a' * 20);
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(saved, 1);
  });

  testWidgets('onboarding: too long -> snackbar, stays on the nickname step', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const OnboardingNicknameScreen()),
        GoRoute(
          path: '/onboarding/allergies',
          builder: (_, _) => const Text('allergies step'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'a' * 21);
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text(_tooLongMessage), findsOneWidget);
    expect(find.text('allergies step'), findsNothing);

    // 스낵바가 하단 Next 버튼을 덮고 있으므로 닫힐 때까지 기다립니다.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'a' * 20);
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('allergies step'), findsOneWidget);
  });
}
