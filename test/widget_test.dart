import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:et/main.dart';
import 'package:et/providers/provider.dart';

void main() {
  testWidgets('ET App renders main screen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ProductionProvider(),
        child: const ET(),
      ),
    );

    expect(find.text('ET'), findsOneWidget);
    expect(find.text('GOOD'), findsOneWidget);
    expect(find.text('REJECT'), findsOneWidget);
    expect(find.text('Q.C'), findsOneWidget);
    expect(find.text('SAMPLE'), findsOneWidget);
  });
}
