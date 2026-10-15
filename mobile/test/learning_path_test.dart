import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_learning_mobile/core/theme/app_theme.dart';
import 'package:adaptive_learning_mobile/features/learning_path/learning_goal_screen.dart';
import 'package:adaptive_learning_mobile/features/learning_path/learning_path_screen.dart';
import 'package:adaptive_learning_mobile/features/learning_path/diagnostic_assessment_screen.dart';
import 'package:adaptive_learning_mobile/features/learning_path/lesson_unit_screen.dart';
import 'package:adaptive_learning_mobile/features/learning_path/research_telemetry_screen.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: child,
    );
  }

  testWidgets('LearningGoalScreen renders goal selection and study options', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const LearningGoalScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Goal-Aware Planning'), findsOneWidget);
    expect(find.text('Term-Test Preparation (High-Yield)'), findsOneWidget);
    expect(find.text('Comprehensive Mastery'), findsOneWidget);
    expect(find.text('Generate AI Learning Pathway'), findsOneWidget);
  });

  testWidgets('LearningPathScreen renders curriculum DAG roadmap and recommendation', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const LearningPathScreen()));
    await tester.pumpAndSettle();

    expect(find.text('AI Learning Pathway'), findsOneWidget);
    expect(find.text('Curriculum Prerequisite DAG'), findsOneWidget);
    expect(find.textContaining('Indices & Logarithms'), findsWidgets);
    expect(find.text('AI RECOMMENDED NEXT STEP'), findsOneWidget);
    expect(find.text('Start Recommended Activity'), findsOneWidget);
  });

  testWidgets('DiagnosticAssessmentScreen renders questions and options', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const DiagnosticAssessmentScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Curriculum Diagnostic'), findsOneWidget);
    expect(find.textContaining('Question 1 of'), findsOneWidget);
    expect(find.text('Select the Correct Answer:'), findsOneWidget);
  });

  testWidgets('LessonUnitScreen renders tabs and structured theory', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      const LessonUnitScreen(conceptId: '10000000-0000-0000-0000-000000000002'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('📖 Theory & Formulas'), findsOneWidget);
    expect(find.text('💡 Worked Example'), findsOneWidget);
    expect(find.text('✍️ Guided Practice'), findsOneWidget);
    expect(find.text('🎯 Concept Quiz'), findsOneWidget);
    expect(find.text('Conceptual Theory'), findsOneWidget);
  });

  testWidgets('ResearchTelemetryScreen renders empirical baselines comparison', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const ResearchTelemetryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Research Telemetry & Baselines'), findsOneWidget);
    expect(find.text('Component 1 Research Telemetry'), findsOneWidget);
    expect(find.text('ML Readiness F1'), findsOneWidget);
    expect(find.text('Prereq Integrity'), findsOneWidget);
    expect(find.text('Comparative Baseline Evaluation (REQ-C1-08)'), findsOneWidget);
  });
}
