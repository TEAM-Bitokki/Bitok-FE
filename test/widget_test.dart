import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bitok/core/providers/shared_preferences_provider.dart';
import 'package:bitok/main.dart';

void main() {
  testWidgets('BitokApp renders the title image on launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const BitokApp(),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
