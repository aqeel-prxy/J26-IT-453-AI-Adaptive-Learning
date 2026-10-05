import 'package:flutter/material.dart';
import '../../features/authentication/splash_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/mathematics/topics_screen.dart';
import '../../features/mathematics/concept_screen.dart';
import '../../features/mathematics/question_screen.dart';
import '../../features/mathematics/answer_submission_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String topics = '/topics';
  static const String concept = '/concept';
  static const String question = '/question';
  static const String submit = '/submit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case topics:
        return MaterialPageRoute(builder: (_) => const TopicsScreen());
      case concept:
        return MaterialPageRoute(builder: (_) => const ConceptScreen());
      case question:
        return MaterialPageRoute(builder: (_) => const QuestionScreen());
      case submit:
        final solution = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => AnswerSubmissionScreen(submittedSolution: solution),
        );
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
