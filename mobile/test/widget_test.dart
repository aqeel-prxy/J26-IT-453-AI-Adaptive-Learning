import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_learning_mobile/main.dart';
import 'package:adaptive_learning_mobile/features/authentication/login_screen.dart';

void main() {
  testWidgets('App launches splash screen cleanly', (WidgetTester tester) async {
    await tester.pumpWidget(const AdaptiveLearningApp());
    expect(find.text('AdaptiveMath AI'), findsOneWidget);
    expect(find.text('Grade 10–11 Mathematics • Rural Sri Lanka'), findsOneWidget);
  });

  testWidgets('LoginScreen renders Sign In and Create Account tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Student Login'), findsOneWidget);
    expect(find.text('Sign In to Dashboard'), findsOneWidget);
  });

  testWidgets('LoginScreen switches to Create Account tab and displays registration fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Register New Student Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Grade 10'), findsOneWidget);
    expect(find.text('Grade 11'), findsOneWidget);
    expect(find.text('Create Account & Start Learning'), findsOneWidget);
  });

  testWidgets('LoginScreen renders Continue with Google button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
