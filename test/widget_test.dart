import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:movere_ai/main.dart';

void main() {
  testWidgets('Uygulama açılıyor ve showcase ekranı görünüyor',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MovereApp()));

    expect(find.text('Movere AI'), findsOneWidget);
    expect(find.text('Butonlar'), findsOneWidget);
  });
}
