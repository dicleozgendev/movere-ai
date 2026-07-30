import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movere_ai/main.dart';

void main() {
  testWidgets('App starts with splash and transitions to onboarding',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MovereApp()));

    // Splash: the brand text is visible.
    expect(find.text('MOVERE'), findsOneWidget);

    // Advance 5s: the splash timer (4s) elapses, onboarding opens.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Focus'), findsOneWidget);
  });
}
