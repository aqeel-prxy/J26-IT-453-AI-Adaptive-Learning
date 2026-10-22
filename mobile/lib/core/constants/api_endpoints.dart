import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // Base URL pointing to FastAPI server:
  // - 10.0.2.2: Host loopback inside Android Emulator
  // - 127.0.0.1: Windows / macOS / Linux / Web
  // (If presenting on a physical Android phone over Wi-Fi, change host to your laptop's Wi-Fi IP)
  static String get host {
    if (kIsWeb) {
      final browserHost = Uri.base.host;
      if (browserHost.isNotEmpty && browserHost != 'localhost') {
        return browserHost;
      }
      return "127.0.0.1";
    }
    if (Platform.isAndroid) return "10.0.2.2";
    return "127.0.0.1";
  }

  static String get baseUrl => "http://$host:8000/api/v1";

  // Auth
  static String get login => "$baseUrl/auth/login";
  static String get register => "$baseUrl/auth/register";
  static String get googleAuth => "$baseUrl/auth/google";

  // Students
  static String get currentStudent => "$baseUrl/students/me";

  // Mathematics (Core)
  static String get topics => "$baseUrl/mathematics/topics";
  static String get concepts => "$baseUrl/mathematics/concepts";
  static String get submitAttempt => "$baseUrl/mathematics/attempts/submit";

  // Module: Learning Path Planning Engine
  static String get learningPathCurriculum => "$baseUrl/learning-path/curriculum";
  static String get learningPathDiagnosticQuestions => "$baseUrl/learning-path/diagnostic/questions";
  static String get learningPathDiagnosticSubmit => "$baseUrl/learning-path/diagnostic/submit";
  static String get learningPathPlan => "$baseUrl/learning-path/plan";
  static String get learningPathActivityComplete => "$baseUrl/learning-path/activity/complete";
  static String get learningPathLesson => "$baseUrl/learning-path/lesson";
  static String get learningPathTelemetry => "$baseUrl/learning-path/telemetry";
  static String get learningPathBaselines => "$baseUrl/learning-path/baselines/compare";

  // Representation Compatibility Endpoints
  static String get selectRepresentation => "$baseUrl/representation/select";
  static String get recordOutcome => "$baseUrl/representation/outcome";

  // Learner Profiling
  static String get learnerProfile => "$baseUrl/learner/profile";

  // Engagement & Feedback (Component 3: Dharmasena K.C.D)
  static String get studentProfile => "$baseUrl/students/profile";
  static String get engagementDashboard => "$baseUrl/engagement/dashboard";
  static String get engagementFeedback => "$baseUrl/engagement/profile-feedback";
  static String get engagementEvaluateTelemetry => "$baseUrl/engagement/telemetry/evaluate";

  // Multiplayer Quiz Arena (Component 3)
  static String get multiplayerCreate => "$baseUrl/multiplayer/create";
  static String get multiplayerRoom => "$baseUrl/multiplayer/room";
  static String get multiplayerJoin => "$baseUrl/multiplayer/join";
  static String get multiplayerAddBot => "$baseUrl/multiplayer/add-bot";
  static String get multiplayerStart => "$baseUrl/multiplayer/start";
  static String get multiplayerSubmitAnswer => "$baseUrl/multiplayer/submit-answer";
  static String get multiplayerNextQuestion => "$baseUrl/multiplayer/next-question";
  static String get multiplayerAnalytics => "$baseUrl/multiplayer/analytics";
  static String get multiplayerParseCsv => "$baseUrl/multiplayer/parse-csv";
  static String get multiplayerWsBase => "ws://$host:8000/api/v1/multiplayer/ws";

  // Error Diagnosis
  static String get diagnoseError => "$baseUrl/error/diagnose";
}

