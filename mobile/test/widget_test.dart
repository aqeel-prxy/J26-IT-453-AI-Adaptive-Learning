import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_learning_mobile/main.dart';

void main() {
  testWidgets('App launches splash screen cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveLearningApp());
    expect(find.text('AdaptiveMath AI'), findsOneWidget);
    expect(find.text('Grade 10–11 Mathematics • Rural Sri Lanka'), findsOneWidget);
  });
}
