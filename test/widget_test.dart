import 'package:flutter_test/flutter_test.dart';
import 'package:automation_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AutomationApp());

    // Verify that the app builds without crashing
    expect(find.byType(AutomationApp), findsOneWidget);
  });
}
