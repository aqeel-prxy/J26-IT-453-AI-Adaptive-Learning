import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_learning_mobile/main.dart';

void main() {
  testWidgets('App launches splash screen cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveLearningApp());
    expect(find.text('J26-IT-453 Adaptive Learning'), findsOneWidget);
    expect(find.text('Grade 10–11 Mathematics • Rural Sri Lanka'), findsOneWidget);
  });
}
