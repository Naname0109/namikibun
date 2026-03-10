import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:namikibun/app.dart';

void main() {
  testWidgets('App starts and shows bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NamikibunApp(),
      ),
    );

    expect(find.text('ホーム'), findsWidgets);
    expect(find.text('カレンダー'), findsOneWidget);
    expect(find.text('統計'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });
}
