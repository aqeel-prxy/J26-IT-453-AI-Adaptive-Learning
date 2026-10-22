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
    expect(find.text('Adaptive Engine Telemetry & System Analytics'), findsOneWidget);
    expect(find.text('ML Readiness F1'), findsOneWidget);
    expect(find.text('Prereq Integrity'), findsOneWidget);
    expect(find.text('Comparative Baseline Evaluation (REQ-C1-08)'), findsOneWidget);
  });

  testWidgets('LearningGoalScreen allows toggling between Grade 10 and Grade 11', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(const LearningGoalScreen()));
    await tester.pumpAndSettle();

    expect(find.text('1. Select Grade Level'), findsOneWidget);
    expect(find.text('Grade 10'), findsOneWidget);
    expect(find.text('Grade 11'), findsOneWidget);
    expect(find.text('Indices and Logarithms'), findsOneWidget);

    // Tap Grade 10
    await tester.tap(find.text('Grade 10'));
    await tester.pumpAndSettle();

    expect(find.text('Quadratic Equations'), findsOneWidget);
    expect(find.textContaining('වර්ගජ සමීකරණ'), findsWidgets);
    expect(find.textContaining('4 Core Concepts in DAG'), findsOneWidget);
  });

  testWidgets('LessonUnitScreen renders Grade 10 Quadratic Equations theory and formulas', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      const LessonUnitScreen(conceptId: 'c1111111-1111-1111-1111-111111111111'),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Solving Quadratic Equations by Factorization'), findsOneWidget);
    expect(find.text('📖 Theory & Formulas'), findsOneWidget);
    expect(find.text('Zero-Product Rule'), findsOneWidget);
  });

  testWidgets('LessonUnitScreen renders Prerequisite Bridge and pedagogical mode badge', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      const LessonUnitScreen(
        conceptId: '10000000-0000-0000-0000-000000000001',
        goalType: 'TERM_TEST',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('⚡ Term-Test Cramming'), findsOneWidget);
    expect(find.text('Prerequisite Bridge (Linking Prior Knowledge)'), findsOneWidget);
    expect(find.text('Competency 11.1'), findsOneWidget);
    expect(find.text('Intuitive Analogy'), findsOneWidget);
    expect(find.text('O/L Exam Trap Warning'), findsOneWidget);
  });

  testWidgets('LessonUnitScreen dynamically switches pedagogical content when goal button is tapped', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(
      const LessonUnitScreen(
        conceptId: '10000000-0000-0000-0000-000000000001',
        goalType: 'TERM_TEST',
      ),
    ));
    await tester.pumpAndSettle();

    // Verify initial Term-Test state
    expect(find.text('⚡ Term-Test Cramming'), findsOneWidget);
    expect(find.textContaining('EXAM CRAMMING STRATEGY'), findsOneWidget);

    // Tap Comprehensive button
    await tester.tap(find.text('Comprehensive'));
    await tester.pumpAndSettle();

    // Verify dynamic re-synthesis to Comprehensive mode!
    expect(find.text('🎯 Comprehensive Mastery'), findsOneWidget);
    expect(find.textContaining('CONCEPTUAL FOUNDATION'), findsOneWidget);
  });
}
