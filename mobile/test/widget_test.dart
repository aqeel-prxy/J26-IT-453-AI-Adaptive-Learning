import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_learning_mobile/main.dart';

void main() {
  testWidgets('App launches and displays title text', (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveLearningApp());
    expect(find.text('Grade 10–11 Mathematics'), findsOneWidget);
    expect(find.text('Login to Dashboard'), findsOneWidget);
  });
}
