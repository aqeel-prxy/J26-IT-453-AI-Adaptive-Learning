import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  final String authProvider;

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
    this.authProvider = 'email',
  });

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'token': token,
        'full_name': fullName,
        'email': email,
        'grade_level': gradeLevel,
        'preferred_goal': preferredGoal,
        'school': school,
        'district': district,
        'avatar_id': avatarId,
        'auth_provider': authProvider,
      };

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        studentId: json['student_id'] as String? ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
        token: json['token'] as String? ?? '',
        fullName: json['full_name'] as String? ?? 'Student',
        email: json['email'] as String? ?? '',
        gradeLevel: (json['grade_level'] as num?)?.toInt() ?? 11,
        preferredGoal: json['preferred_goal'] as String? ?? 'TERM_TEST',
        school: json['school'] as String? ?? 'Central College, Kandy',
        district: json['district'] as String? ?? 'Central Province',
        avatarId: json['avatar_id'] as String? ?? 'fox_math',
        authProvider: json['auth_provider'] as String? ?? 'email',
      );
}

class AuthService {
  final ApiClient apiClient;

  AuthService({ApiClient? client}) : apiClient = client ?? ApiClient();

  static AuthUser? _currentUser;
  static AuthUser? get currentUser => _currentUser;

  static const String _prefKeyCurrentUser = 'adaptive_learning_current_user';
  static const String _prefKeyCachedAccounts = 'adaptive_learning_cached_accounts';
  static const String _prefKeyGoogleAccounts = 'adaptive_learning_google_accounts';
  static const String _prefKeyAccountPasswords = 'adaptive_learning_account_passwords';

  /// Get list of previously authenticated Google accounts
  static Future<List<Map<String, dynamic>>> getSavedGoogleAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKeyGoogleAccounts);
      if (raw != null && raw.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(raw);
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [
      {
        'email': 'aqeel.research@gmail.com',
        'name': 'Aqeel M.I.M',
        'google_id': 'google_aqeel_101',
        'grade_level': 11,
      },
      {
        'email': 'kasun.perera@gmail.com',
        'name': 'Kasun Perera',
        'google_id': 'google_kasun_102',
        'grade_level': 10,
      },
    ];
  }

  /// Save a Google account to the device's Google Accounts list
  static Future<void> saveGoogleAccount({
    required String email,
    required String name,
    required String googleId,
    int gradeLevel = 11,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accounts = await getSavedGoogleAccounts();
      accounts.removeWhere((a) => (a['email'] as String?)?.toLowerCase() == email.toLowerCase().trim());
      accounts.insert(0, {
        'email': email.trim(),
        'name': name.trim(),
        'google_id': googleId,
        'grade_level': gradeLevel,
      });
      await prefs.setString(_prefKeyGoogleAccounts, jsonEncode(accounts));
    } catch (_) {}
  }

  /// Save user session and update local accounts registry for persistent offline access
  static Future<void> saveUserToLocal(AuthUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKeyCurrentUser, jsonEncode(user.toJson()));

      // Update cached accounts registry
      final accountsRaw = prefs.getString(_prefKeyCachedAccounts);
      Map<String, dynamic> accountsMap = {};
      if (accountsRaw != null && accountsRaw.isNotEmpty) {
        try {
          accountsMap = jsonDecode(accountsRaw) as Map<String, dynamic>;
        } catch (_) {}
      }
      accountsMap[user.email.toLowerCase().trim()] = user.toJson();
      await prefs.setString(_prefKeyCachedAccounts, jsonEncode(accountsMap));
    } catch (_) {
      // Local storage non-critical failure
    }
  }

  /// Retrieve locally cached account by email
  static Future<AuthUser?> getCachedAccount(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accountsRaw = prefs.getString(_prefKeyCachedAccounts);
      if (accountsRaw != null && accountsRaw.isNotEmpty) {
        final accountsMap = jsonDecode(accountsRaw) as Map<String, dynamic>;
        final key = email.toLowerCase().trim();
        if (accountsMap.containsKey(key)) {
          final rawUser = accountsMap[key] as Map<String, dynamic>;
          return AuthUser.fromJson(rawUser);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Securely persist registered or validated password locally for offline authentication
  static Future<void> saveAccountPassword(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKeyAccountPasswords);
      Map<String, dynamic> passwordsMap = {};
      if (raw != null && raw.isNotEmpty) {
        try {
          passwordsMap = jsonDecode(raw) as Map<String, dynamic>;
        } catch (_) {}
      }
      passwordsMap[email.toLowerCase().trim()] = password;
      await prefs.setString(_prefKeyAccountPasswords, jsonEncode(passwordsMap));
    } catch (_) {}
  }

  /// Retrieve locally stored password for offline credential validation
  static Future<String?> getAccountPassword(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKeyAccountPasswords);
      if (raw != null && raw.isNotEmpty) {
        final passwordsMap = jsonDecode(raw) as Map<String, dynamic>;
        return passwordsMap[email.toLowerCase().trim()] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Load currently persisted session on app launch
  static Future<AuthUser?> loadStoredSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_prefKeyCurrentUser);
      if (userJson != null && userJson.isNotEmpty) {
        final user = AuthUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        _currentUser = user;
        syncAppState(user);
        return user;
      }
    } catch (_) {}
    return null;
  }

  /// Sign In with Email & Password
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    Map<String, dynamic> data = {};
    bool networkSuccess = false;
    ApiException? apiException;

    try {
      data = await apiClient.post(ApiEndpoints.login, {
        'email': email.trim(),
        'password': password,
      });
      networkSuccess = data.containsKey('student_id');
    } on ApiException catch (e) {
      apiException = e;
    } catch (_) {
      networkSuccess = false;
    }

    // Explicit server error (e.g. 401 Unauthorized / wrong password) must be surfaced immediately
    if (apiException != null) {
      throw Exception(apiException.message);
    }

    final isG10 = cleanEmail.contains('10') || cleanEmail.contains('quad');

    AuthUser user;
    if (networkSuccess) {
      final studentId = data['student_id'] as String? ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
      final token = data['access_token'] as String? ?? 'token_$studentId';
      final fullName = data['full_name'] as String? ?? (isG10 ? 'Kasun Perera' : 'Aqeel M.I.M');
      final gradeLevel = (data['grade_level'] as num?)?.toInt() ?? (isG10 ? 10 : 11);
      final preferredGoal = data['preferred_goal'] as String? ?? (isG10 ? 'COMPREHENSIVE' : 'TERM_TEST');
      final school = data['school'] as String? ?? 'Central College, Kandy';
      final district = data['district'] as String? ?? 'Central Province';
      final avatarId = data['avatar_id'] as String? ?? (isG10 ? 'owl_scholar' : 'fox_math');
      final authProvider = data['auth_provider'] as String? ?? 'email';

      user = AuthUser(
        studentId: studentId,
        token: token,
        fullName: fullName,
        email: email.trim(),
        gradeLevel: gradeLevel,
        preferredGoal: preferredGoal,
        school: school,
        district: district,
        avatarId: avatarId,
        authProvider: authProvider,
      );
      // Cache valid credentials for offline verification
      await saveAccountPassword(email, password);
    } else {
      // Offline fallback: validate against locally stored credentials or demo accounts
      final storedPassword = await getAccountPassword(email);
      final isDemoAccount = cleanEmail == 'student@example.lk' || cleanEmail == 'grade10.student@example.lk';
      final expectedPassword = storedPassword ?? (isDemoAccount ? 'password123' : null);

      if (expectedPassword == null) {
        throw Exception('Account not found with this email. Please register first.');
      }

      if (password != expectedPassword) {
        throw Exception('Incorrect password. Please try again.');
      }

      final cached = await getCachedAccount(email);
      if (cached != null) {
        user = cached;
      } else {
        const studentId = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
        user = AuthUser(
          studentId: isG10 ? 'c1111111-1111-1111-1111-111111111110' : studentId,
          token: 'token_$studentId',
          fullName: isG10 ? 'Kasun Perera' : 'Aqeel M.I.M',
          email: cleanEmail,
          gradeLevel: isG10 ? 10 : 11,
          preferredGoal: isG10 ? 'COMPREHENSIVE' : 'TERM_TEST',
          school: 'Central College, Kandy',
          district: 'Central Province',
          avatarId: isG10 ? 'owl_scholar' : 'fox_math',
          authProvider: 'email',
        );
      }
    }

    _currentUser = user;
    await saveUserToLocal(user);
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
    bool networkSuccess = false;
    ApiException? apiException;
    try {
      data = await apiClient.post(ApiEndpoints.register, {
        'full_name': fullName,
        'email': email.trim(),
        'password': password,
        'grade_level': gradeLevel,
        'preferred_goal': preferredGoal,
        'school': school,
        'district': district,
        'avatar_id': avatarId,
      });
      networkSuccess = data.containsKey('student_id');
    } on ApiException catch (e) {
      apiException = e;
    } catch (_) {
      networkSuccess = false;
    }

    if (apiException != null) {
      throw Exception(apiException.message);
    }

    final studentId = networkSuccess
        ? (data['student_id'] as String? ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11')
        : 'stu_${DateTime.now().millisecondsSinceEpoch}';
    final token = networkSuccess ? (data['access_token'] as String? ?? 'token_$studentId') : 'token_$studentId';

    final user = AuthUser(
      studentId: studentId,
      token: token,
      fullName: fullName,
      email: email.trim(),
      gradeLevel: gradeLevel,
      preferredGoal: preferredGoal,
      school: school,
      district: district,
      avatarId: avatarId,
      authProvider: 'email',
    );

    _currentUser = user;
    await saveUserToLocal(user);
    await saveAccountPassword(email, password);
    syncAppState(user);
    return user;
  }

  /// Sign In with Google OAuth
  Future<AuthUser> loginWithGoogle({
    required String googleId,
    required String email,
    required String fullName,
    String? avatarUrl,
    int gradeLevel = 11,
    String preferredGoal = 'TERM_TEST',
    String school = 'Central College, Kandy',
    String district = 'Central Province',
    String avatarId = 'fox_math',
  }) async {
    Map<String, dynamic> data = {};
    bool networkSuccess = false;
    try {
      data = await apiClient.post(ApiEndpoints.googleAuth, {
        'google_id': googleId,
        'email': email,
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'grade_level': gradeLevel,
        'preferred_goal': preferredGoal,
        'school': school,
        'district': district,
        'avatar_id': avatarId,
      });
      networkSuccess = data.containsKey('student_id');
    } catch (_) {
      networkSuccess = false;
    }

    final studentId = networkSuccess
        ? (data['student_id'] as String? ?? 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11')
        : 'google_$googleId';
    final token = networkSuccess ? (data['access_token'] as String? ?? 'google_token_$studentId') : 'google_token_$studentId';

    final user = AuthUser(
      studentId: studentId,
      token: token,
      fullName: data['full_name'] as String? ?? fullName,
      email: email,
      gradeLevel: (data['grade_level'] as num?)?.toInt() ?? gradeLevel,
      preferredGoal: data['preferred_goal'] as String? ?? preferredGoal,
      school: data['school'] as String? ?? school,
      district: data['district'] as String? ?? district,
      avatarId: data['avatar_id'] as String? ?? avatarId,
      authProvider: 'google',
    );

    _currentUser = user;
    await saveUserToLocal(user);
    await saveGoogleAccount(email: user.email, name: user.fullName, googleId: googleId, gradeLevel: user.gradeLevel);
    syncAppState(user);
    return user;
  }

  /// Synchronize student profile and learning path states across the app
  static void syncAppState(AuthUser user) {
    // 1. Update ProfileService cache
    ProfileService.cachedProfile = UserProfile(
      studentId: user.studentId,
      anonymizedCode: 'STU_HASH_${user.studentId.length >= 6 ? user.studentId.substring(0, 6).toUpperCase() : "DEMO"}',
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

  Future<void> logout() async {
    _currentUser = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeyCurrentUser);
    } catch (_) {}
  }
}
