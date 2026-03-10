import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:namikibun/app.dart';
import 'package:namikibun/providers/theme_provider.dart';

void main() {
  testWidgets('App starts and shows bottom navigation', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const NamikibunApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('ホーム'), findsWidgets);
    expect(find.text('カレンダー'), findsOneWidget);
    expect(find.text('統計'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });
}
