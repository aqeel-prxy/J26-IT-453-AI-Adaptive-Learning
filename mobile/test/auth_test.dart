import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_learning_mobile/core/network/api_client.dart';
import 'package:adaptive_learning_mobile/features/authentication/auth_service.dart';
import 'package:adaptive_learning_mobile/features/authentication/login_screen.dart';
import 'package:adaptive_learning_mobile/features/authentication/google_oauth_dialog.dart';
import 'package:adaptive_learning_mobile/core/routing/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Online AuthService Password Validation Tests', () {
    late ApiClient mockOnlineClient;

    setUp(() {
      final mockHttp = MockClient((request) async {
        if (request.url.path.endsWith('/auth/login')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          final email = body['email'] as String? ?? '';
          final password = body['password'] as String? ?? '';

          if (email == 'student@example.lk' && password == 'password123') {
            return http.Response(
              jsonEncode({
                'student_id': 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
                'access_token': 'token_demo_valid',
                'full_name': 'Aqeel M.I.M',
                'email': 'student@example.lk',
                'grade_level': 11,
                'preferred_goal': 'TERM_TEST',
                'school': 'Central College, Kandy',
                'district': 'Central Province',
                'avatar_id': 'fox_math',
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          } else if (email == 'student@example.lk') {
            return http.Response(
              jsonEncode({'detail': 'Incorrect password. Please try again.'}),
              401,
              headers: {'content-type': 'application/json'},
            );
          } else {
            return http.Response(
              jsonEncode({'detail': 'Account not found with this email. Please register first.'}),
              401,
              headers: {'content-type': 'application/json'},
            );
          }
        }
        return http.Response('Not Found', 404);
      });

      mockOnlineClient = ApiClient(client: mockHttp);
    });

    test('login with incorrect password rejects user with 401 detail error', () async {
      final authService = AuthService(client: mockOnlineClient);
      expect(
        () => authService.login(
          email: 'student@example.lk',
          password: 'wrongPassword999',
        ),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Incorrect password. Please try again.'))),
      );
    });

    test('login with unregistered email rejects user with account not found error', () async {
      final authService = AuthService(client: mockOnlineClient);
      expect(
        () => authService.login(
          email: 'stranger@example.lk',
          password: 'anyPassword',
        ),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Account not found with this email'))),
      );
    });

    test('login with valid password returns authenticated AuthUser and syncs profile', () async {
      final authService = AuthService(client: mockOnlineClient);
      final user = await authService.login(
        email: 'student@example.lk',
        password: 'password123',
      );
      expect(user.studentId, 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11');
      expect(user.email, 'student@example.lk');
      expect(user.fullName, 'Aqeel M.I.M');
      expect(user.gradeLevel, 11);
    });
  });

  group('Offline Fallback Password Validation Tests', () {
    late ApiClient offlineClient;

    setUp(() {
      final mockHttp = MockClient((request) async {
        throw http.ClientException('Network unreachable');
      });
      offlineClient = ApiClient(client: mockHttp);
    });

    test('offline demo login with incorrect password throws exception', () async {
      final authService = AuthService(client: offlineClient);
      expect(
        () => authService.login(
          email: 'student@example.lk',
          password: 'wrongDemoPassword',
        ),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Incorrect password. Please try again.'))),
      );
    });

    test('offline demo login with correct password succeeds', () async {
      final authService = AuthService(client: offlineClient);
      final user = await authService.login(
        email: 'student@example.lk',
        password: 'password123',
      );
      expect(user.email, 'student@example.lk');
      expect(user.gradeLevel, 11);
    });

    test('offline newly registered account verifies password strictly', () async {
      final authService = AuthService(client: offlineClient);
      final registered = await authService.register(
        fullName: 'Kasun Bandara',
        email: 'kasun@bandara.lk',
        password: 'mySecretPassword99',
        gradeLevel: 10,
        preferredGoal: 'COMPREHENSIVE',
      );
      expect(registered.email, 'kasun@bandara.lk');

      // Wrong password fails
      expect(
        () => authService.login(
          email: 'kasun@bandara.lk',
          password: 'wrongPassword',
        ),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Incorrect password. Please try again.'))),
      );

      // Correct password succeeds
      final loggedIn = await authService.login(
        email: 'kasun@bandara.lk',
        password: 'mySecretPassword99',
      );
      expect(loggedIn.fullName, 'Kasun Bandara');
    });
  });

  group('LoginScreen Password Validation Widget Tests', () {
    testWidgets('entering incorrect password displays error banner and does not navigate', (WidgetTester tester) async {
      bool navigatedToDashboard = false;

      final mockHttp = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Incorrect password. Please try again.'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });
      final mockClient = ApiClient(client: mockHttp);
      final testAuthService = AuthService(client: mockClient);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            AppRouter.dashboard: (context) {
              navigatedToDashboard = true;
              return const Scaffold(body: Text('Dashboard View'));
            },
          },
          home: LoginScreen(authService: testAuthService),
        ),
      );

      // Find the email and password text fields
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);

      // First TextField is email, second is password
      final emailFinder = textFields.at(0);
      final passwordFinder = textFields.at(1);

      await tester.enterText(emailFinder, 'student@example.lk');
      await tester.enterText(passwordFinder, 'invalidPassword');
      await tester.pump();

      // Tap Sign In to Dashboard button
      final signInButton = find.text('Sign In to Dashboard');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Ensure error banner is displayed
      expect(find.text('Incorrect password. Please try again.'), findsOneWidget);

      // Verify user did NOT navigate to Dashboard
      expect(navigatedToDashboard, isFalse);
      expect(find.text('Student Login'), findsOneWidget);
    });
  });

  group('GoogleOAuthDialog Widget Tests', () {
    testWidgets('displays account picker and transitions to email entry without overlapping', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => GoogleOAuthDialog.show(context, onAuthenticated: (_) {}),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Account Picker step is visible
      expect(find.text('Choose an account'), findsOneWidget);
      expect(find.text('Use another account'), findsOneWidget);

      // Tap 'Use another account'
      await tester.tap(find.text('Use another account'));
      await tester.pumpAndSettle();

      // Email entry step is cleanly rendered
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('with your Google Account to continue to AdaptiveMath AI'), findsOneWidget);
      expect(find.text('Email or phone'), findsOneWidget);
      expect(find.text('Display Name (Google Profile)'), findsOneWidget);
      expect(find.text('Grade 10'), findsOneWidget);
      expect(find.text('Grade 11'), findsOneWidget);
      expect(find.text('Quadratic Equations'), findsOneWidget);
      expect(find.text('Indices & Logarithms'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);

      // Enter email and tap Next
      final emailField = find.widgetWithText(TextField, 'Email or phone');
      await tester.enterText(emailField, 'test.student@gmail.com');
      await tester.ensureVisible(find.text('Next'));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Password step is visible
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Tap Back to return to Email Entry
      await tester.ensureVisible(find.text('Back'));
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Sign in'), findsOneWidget);
    });
  });
}
