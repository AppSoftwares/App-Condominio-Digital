import 'package:flutter_test/flutter_test.dart';
import 'package:condominio_app/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App loads test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: CondominioApp()));

    // El test simplemente verifica que la app carga sin crashear inmediatamente
    expect(find.byType(CondominioApp), findsOneWidget);
  });
}
