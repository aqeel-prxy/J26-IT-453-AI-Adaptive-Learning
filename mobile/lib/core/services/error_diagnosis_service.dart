import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ErrorDiagnosisService {
  /// Platform-aware API Base URL
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    } else {
      return 'http://127.0.0.1:8000/api/v1';
    }
  }

  /// 1. Extract mathematical question from image using OCR
  static Future<Map<String, dynamic>> extractQuestionFromOCR(String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/error/ocr'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_base64': base64Image}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'error_message': 'OCR server returned status ${response.statusCode}. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error_message': 'Could not connect to OCR service ($e). Please check backend connection or type manually.',
      };
    }
  }

  /// 2. Solves question automatically and returns verified step-by-step derivation
  static Future<Map<String, dynamic>> solveQuestion(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/error/solve'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'supported': false,
          'error_message': 'Solver service returned status ${response.statusCode}.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'supported': false,
        'error_message': 'Connection to solver backend failed ($e). Ensure backend is running.',
      };
    }
  }

  /// 3. Evaluates student's own working derivation ("Check My Working")
  static Future<Map<String, dynamic>> checkWorking({
    required String question,
    required String solutionSteps,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/error/check-working'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'solution_steps': solutionSteps,
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}

    return {
      'is_correct': false,
      'question': question,
      'explanation_text': 'Unable to connect to diagnostic service. Please verify your internet/backend connection.',
      'error_category': 'Connection Error',
    };
  }

  /// 4. Retrieves a similar practice question for retry
  static Future<Map<String, dynamic>> getSimilarQuestion(String currentQuestion) async {
    try {
      final uri = Uri.parse('$baseUrl/error/similar-question').replace(
        queryParameters: {'current_question': currentQuestion},
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}

    return {
      'concept_id': 'MATH-G10-QUAD-01',
      'topic': 'Quadratic Equations',
      'question': 'x² - 5x + 6 = 0',
      'difficulty': 'Medium',
      'expected_answer': 'x = 2 or x = 3',
    };
  }

  /// 5. Persist attempt into existing database via mathematics/attempts/submit
  static Future<bool> recordAttempt({
    required String studentId,
    required String questionId,
    required String studentSolution,
    required int responseTimeMs,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mathematics/attempts/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': studentId,
          'question_id': questionId,
          'student_solution': studentSolution,
          'response_time_ms': responseTimeMs,
        }),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // Backwards compatibility method
  static Future<Map<String, dynamic>> solveAndDiagnose({
    required String question,
    required String solution,
  }) async {
    return checkWorking(question: question, solutionSteps: solution);
  }
}
