import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movere_ai/main.dart';

void main() {
  testWidgets('Uygulama splash ile açılıyor ve onboarding\'e geçiyor',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MovereApp()));

    // Splash: marka yazısı görünüyor.
    expect(find.text('MOVERE'), findsOneWidget);

    // 3 sn ilerlet: splash timer'ı dolar, onboarding açılır.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Focus'), findsOneWidget);
  });
}
