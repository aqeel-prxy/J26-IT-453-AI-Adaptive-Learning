import 'package:flutter/material.dart';
import '../../features/authentication/splash_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/learning_path/learning_goal_screen.dart';
import '../../features/learning_path/learning_path_screen.dart';
import '../../features/learning_path/diagnostic_assessment_screen.dart';
import '../../features/learning_path/lesson_unit_screen.dart';
import '../../features/learning_path/research_telemetry_screen.dart';
import '../../features/mathematics/topics_screen.dart';
import '../../features/mathematics/concept_screen.dart';
import '../../features/mathematics/question_screen.dart';
import '../../features/mathematics/answer_submission_screen.dart';
import '../../features/learner_profiling/learner_profiling_screen.dart';
import '../../features/gamification/gamification_hub_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String learningGoal = '/learning-goal';
  static const String learningPath = '/learning-path';
  static const String diagnostic = '/diagnostic';
  static const String lessonUnit = '/lesson-unit';
  static const String telemetry = '/telemetry';
  static const String topics = '/topics';
  static const String concept = '/concept';
  static const String question = '/question';
  static const String submit = '/submit';
  static const String learnerProfiling = '/learner-profiling';
  static const String gamification = '/gamification';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case learningGoal:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => LearningGoalScreen(
            initialGrade: args?['grade'] as int?,
            initialTopic: args?['topic'] as String?,
          ),
        );
      case learningPath:
        return MaterialPageRoute(builder: (_) => const LearningPathScreen());
      case diagnostic:
        return MaterialPageRoute(builder: (_) => const DiagnosticAssessmentScreen());
      case lessonUnit:
        final conceptId = settings.arguments as String? ?? '10000000-0000-0000-0000-000000000002';
        return MaterialPageRoute(
          builder: (_) => LessonUnitScreen(conceptId: conceptId),
        );
      case telemetry:
        return MaterialPageRoute(builder: (_) => const ResearchTelemetryScreen());
      case topics:
        return MaterialPageRoute(builder: (_) => const TopicsScreen());
      case concept:
        return MaterialPageRoute(builder: (_) => const ConceptScreen());
      case question:
        return MaterialPageRoute(builder: (_) => const QuestionScreen());
      case submit:
        final args = settings.arguments;
        String solution = '';
        String question = 'Custom Problem';
        String mode = 'solve';
        Map<String, dynamic>? initialData;

        if (args is Map<String, dynamic>) {
          solution = args['solution'] as String? ?? '';
          question = args['question'] as String? ?? 'Custom Problem';
          mode = args['mode'] as String? ?? 'solve';
          initialData = args['solveResult'] as Map<String, dynamic>? ??
              args['checkResult'] as Map<String, dynamic>?;
        } else if (args is String) {
          solution = args;
        }
        return MaterialPageRoute(
          builder: (_) => AnswerSubmissionScreen(
            mode: mode,
            submittedSolution: solution,
            questionTitle: question,
            initialData: initialData,
          ),
        );
      case learnerProfiling:
        return MaterialPageRoute(builder: (_) => const LearnerProfilingScreen());
      case gamification:
        return MaterialPageRoute(builder: (_) => const GamificationHubScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
