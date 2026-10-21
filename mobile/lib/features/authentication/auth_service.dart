import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../learning_path/learning_path_service.dart';
import '../profile/models/user_profile.dart';
import '../profile/profile_service.dart';

class AuthUser {
  final String studentId;
  final String token;
  final String fullName;
  final String email;
  final int gradeLevel;
  final String preferredGoal;
  final String school;
  final String district;
  final String avatarId;

  const AuthUser({
    required this.studentId,
    required this.token,
    required this.fullName,
    required this.email,
    required this.gradeLevel,
    required this.preferredGoal,
    required this.school,
    required this.district,
    required this.avatarId,
  });
}

class AuthService {
  final ApiClient apiClient;

  AuthService({ApiClient? client}) : apiClient = client ?? ApiClient();

  static AuthUser? _currentUser;
  static AuthUser? get currentUser => _currentUser;

  /// Sign In with Email & Password
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> data = {};
    try {
      data = await apiClient.post(ApiEndpoints.login, {
        'email': email,
        'password': password,
      });
    } catch (_) {
      // Offline fallback
    }

    final studentId = data['student_id'] as String? ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
    final token = data['access_token'] as String? ?? 'dev_token_$studentId';
    final isG10 = email.toLowerCase().contains('10') || email.toLowerCase().contains('quad');

    final fullName = data['full_name'] as String? ?? (isG10 ? 'Kasun Perera' : 'Aqeel M.I.M');
    final gradeLevel = (data['grade_level'] as num?)?.toInt() ?? (isG10 ? 10 : 11);
    final preferredGoal = data['preferred_goal'] as String? ?? (isG10 ? 'COMPREHENSIVE' : 'TERM_TEST');
    final school = data['school'] as String? ?? 'Central College, Kandy';
    final district = data['district'] as String? ?? 'Central Province';
    final avatarId = data['avatar_id'] as String? ?? (isG10 ? 'owl_scholar' : 'fox_math');

    final user = AuthUser(
      studentId: studentId,
      token: token,
      fullName: fullName,
      email: email,
      gradeLevel: gradeLevel,
      preferredGoal: preferredGoal,
      school: school,
      district: district,
      avatarId: avatarId,
    );

    _currentUser = user;
    syncAppState(user);
    return user;
  }

  /// Sign Up / Register new Student Account
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
    required int gradeLevel,
    required String preferredGoal,
    String school = 'Central College, Kandy',
    String district = 'Central Province',
    String avatarId = 'fox_math',
  }) async {
    Map<String, dynamic> data = {};
    try {
      data = await apiClient.post(ApiEndpoints.register, {
        'full_name': fullName,
        'email': email,
        'password': password,
        'grade_level': gradeLevel,
        'preferred_goal': preferredGoal,
        'school': school,
        'district': district,
        'avatar_id': avatarId,
      });
    } catch (_) {
      // Offline fallback
    }

    final studentId = data['student_id'] as String? ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
    final token = data['access_token'] as String? ?? 'dev_token_$studentId';

    final user = AuthUser(
      studentId: studentId,
      token: token,
      fullName: fullName,
      email: email,
      gradeLevel: gradeLevel,
      preferredGoal: preferredGoal,
      school: school,
      district: district,
      avatarId: avatarId,
    );

    _currentUser = user;
    syncAppState(user);
    return user;
  }

  /// Synchronize student profile and learning path states across the app
  static void syncAppState(AuthUser user) {
    // 1. Update ProfileService cache
    ProfileService.cachedProfile = UserProfile(
      studentId: user.studentId,
      anonymizedCode: 'STU_HASH_${user.studentId.substring(0, 6).toUpperCase()}',
      fullName: user.fullName,
      email: user.email,
      gradeLevel: user.gradeLevel,
      school: user.school,
      district: user.district,
      avatarId: user.avatarId,
      motivationalArchetype: user.gradeLevel == 11 ? 'Mastery Seeker' : 'Strategic Achiever',
      preferredGoal: user.preferredGoal,
    );

    // 2. Initialize LearningPathService activePlanCache with matching curriculum
    final isG10 = user.gradeLevel == 10;
    LearningPathService.activePlanCache = {
      'plan_id': 'plan-${user.studentId.length >= 8 ? user.studentId.substring(0, 8) : "demo"}',
      'student_id': user.studentId,
      'grade_level': user.gradeLevel,
      'topic_category': isG10 ? 'Quadratic Equations' : 'Indices and Logarithms',
      'goal_type': user.preferredGoal,
      'overall_readiness_score': isG10 ? 0.68 : 0.74,
      'current_concept_id': isG10
          ? 'c1111111-1111-1111-1111-111111111111'
          : '10000000-0000-0000-0000-000000000002',
      'recommended_activity': {
        'concept_id': isG10
            ? 'c1111111-1111-1111-1111-111111111111'
            : '10000000-0000-0000-0000-000000000002',
        'concept_title': isG10
            ? 'Factorization of Quadratic Expressions'
            : 'Fractional and Negative Indices',
        'activity_type': 'PRACTICE',
        'rationale': isG10
            ? 'Foundational algebraic factorization required for G.C.E. O/L Paper II.'
            : 'High predicted readiness. Proceed directly to practice.',
      },
      'pathway_nodes': isG10
          ? [
              {
                'concept_id': 'c1111111-1111-1111-1111-111111111111',
                'title': 'Factorization of Quadratic Expressions',
                'code': 'MATH-G10-QUAD-01',
                'status': 'RECOMMENDED_NEXT',
                'readiness_probability': 0.75,
              },
              {
                'concept_id': 'c1111111-1111-1111-1111-111111111112',
                'title': 'Solving Quadratic Equations by Factorization',
                'code': 'MATH-G10-QUAD-02',
                'status': 'LOCKED',
                'readiness_probability': 0.60,
              },
              {
                'concept_id': 'c1111111-1111-1111-1111-111111111113',
                'title': 'Completing the Square Method',
                'code': 'MATH-G10-QUAD-03',
                'status': 'LOCKED',
                'readiness_probability': 0.40,
              },
              {
                'concept_id': 'c1111111-1111-1111-1111-111111111114',
                'title': 'The Universal Quadratic Formula',
                'code': 'MATH-G10-QUAD-04',
                'status': 'LOCKED',
                'readiness_probability': 0.30,
              },
            ]
          : [
              {
                'concept_id': '10000000-0000-0000-0000-000000000001',
                'title': 'Laws of Positive Integral Indices',
                'code': 'MATH-G11-IND-01',
                'status': 'MASTERED',
                'readiness_probability': 0.95,
              },
              {
                'concept_id': '10000000-0000-0000-0000-000000000002',
                'title': 'Fractional and Negative Indices',
                'code': 'MATH-G11-IND-02',
                'status': 'RECOMMENDED_NEXT',
                'readiness_probability': 0.74,
              },
              {
                'concept_id': '10000000-0000-0000-0000-000000000004',
                'title': 'Logarithmic Notation and Base Rules',
                'code': 'MATH-G11-LOG-02',
                'status': 'LOCKED',
                'readiness_probability': 0.45,
              },
            ],
    };
  }

  void logout() {
    _currentUser = null;
  }
}
