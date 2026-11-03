import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_point_ecom/app/app.dart';

void main() {
  testWidgets('Circuit Point Ecom app launch smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CircuitPointEcomApp(),
      ),
    );

    // Initial frame pumps and splash timer resolves
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CircuitPointEcomApp), findsOneWidget);

    // Advance frames safely
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(CircuitPointEcomApp), findsOneWidget);
  });
}
