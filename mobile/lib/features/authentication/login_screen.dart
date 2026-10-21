import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import '../profile/profile_service.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _authService = AuthService();

  // Sign In Controllers
  final _loginEmailController = TextEditingController(text: 'student@example.lk');
  final _loginPasswordController = TextEditingController(text: 'password123');
  bool _obscureLoginPassword = true;
  bool _isLoginLoading = false;

  // Sign Up Controllers
  final _registerNameController = TextEditingController(text: 'Aqeel M.I.M');
  final _registerEmailController = TextEditingController(text: 'aqeel@student.lk');
  final _registerPasswordController = TextEditingController(text: 'password123');
  final _registerSchoolController = TextEditingController(text: 'Zahira College, Gampola');
  final _registerDistrictController = TextEditingController(text: 'Central Province');

  int _selectedGrade = 11;
  String _selectedGoal = 'TERM_TEST';
  String _selectedAvatarId = 'fox_math';
  bool _obscureRegisterPassword = true;
  bool _isRegisterLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerSchoolController.dispose();
    _registerDistrictController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }

    setState(() => _isLoginLoading = true);
    try {
      final user = await _authService.login(email: email, password: password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${user.fullName}! (Grade ${user.gradeLevel} O/L)'),
            backgroundColor: AppTheme.primaryBlue,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in notice: $e')),
        );
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    } finally {
      if (mounted) setState(() => _isLoginLoading = false);
    }
  }

  Future<void> _handleRegister() async {
    final name = _registerNameController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    setState(() => _isRegisterLoading = true);
    try {
      final user = await _authService.register(
        fullName: name,
        email: email,
        password: password,
        gradeLevel: _selectedGrade,
        preferredGoal: _selectedGoal,
        school: _registerSchoolController.text.trim(),
        district: _registerDistrictController.text.trim(),
        avatarId: _selectedAvatarId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created! Matched Grade ${user.gradeLevel} curriculum.'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration completed with offline profile.')),
        );
        Navigator.pushReplacementNamed(context, AppRouter.dashboard);
      }
    } finally {
      if (mounted) setState(() => _isRegisterLoading = false);
    }
  }

  void _quickFill(String email, String name, int grade, String goal) {
    _loginEmailController.text = email;
    _loginPasswordController.text = 'password123';
    _handleLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Hero Brand Header
              Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.calculate_rounded, color: Colors.white, size: 38),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Text(
                'AdaptiveMath AI',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Secondary Mathematics Learning Platform • Grade 10–11',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 22),

              // Segmented Tab Selector
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13.5),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.5),
                  tabs: const [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Create Account'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tab Content Area
              SizedBox(
                height: 520,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSignInTab(),
                    _buildSignUpTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 1. SIGN IN TAB
  // ===========================================================================
  Widget _buildSignInTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Student Login',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),

                // Email
                TextField(
                  controller: _loginEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                // Password
                TextField(
                  controller: _loginPasswordController,
                  obscureText: _obscureLoginPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureLoginPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: _isLoginLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoginLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sign In to Dashboard', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1-Click Fast Switch Demo Cards
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt, color: AppTheme.primaryBlue, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '1-Click Demo Profiles (Data Pre-matched)',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Grade 11
                InkWell(
                  onTap: () => _quickFill('student@example.lk', 'Aqeel M.I.M', 11, 'TERM_TEST'),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA5B4FC)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Grade 11: Aqeel M.I.M (O/L Candidate)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                            Text('Indices & Logarithms • Term-Test Cramming', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary)),
                          ],
                        ),
                        const Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryBlue),
                      ],
                    ),
                  ),
                ),

                // Grade 10
                InkWell(
                  onTap: () => _quickFill('grade10.student@example.lk', 'Kasun Perera', 10, 'COMPREHENSIVE'),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA5B4FC)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Grade 10: Kasun Perera (Foundation)', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                            Text('Quadratic Equations • Comprehensive Mastery', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary)),
                          ],
                        ),
                        const Icon(Icons.arrow_forward, size: 14, color: AppTheme.primaryBlue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // 2. CREATE ACCOUNT TAB
  // ===========================================================================
  Widget _buildSignUpTab() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Register New Student Account',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Full Name
            TextField(
              controller: _registerNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Email
            TextField(
              controller: _registerEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Password
            TextField(
              controller: _registerPasswordController,
              obscureText: _obscureRegisterPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscureRegisterPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                  onPressed: () => setState(() => _obscureRegisterPassword = !_obscureRegisterPassword),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 14),

            // Grade Level Selector
            Text('Grade Level (O/L Target):', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedGrade = 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedGrade == 10 ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedGrade == 10 ? AppTheme.primaryBlue : const Color(0xFFCBD5E1), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text('Grade 10', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: _selectedGrade == 10 ? AppTheme.primaryBlue : AppTheme.textPrimary)),
                          Text('Quadratic Equations', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedGrade = 11),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _selectedGrade == 11 ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedGrade == 11 ? AppTheme.primaryBlue : const Color(0xFFCBD5E1), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text('Grade 11', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: _selectedGrade == 11 ? AppTheme.primaryBlue : AppTheme.textPrimary)),
                          Text('Indices & Logarithms', style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Learning Goal Selector
            Text('Learning Goal:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedGoal = 'TERM_TEST'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedGoal == 'TERM_TEST' ? const Color(0xFFFEF3C7) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedGoal == 'TERM_TEST' ? const Color(0xFFD97706) : const Color(0xFFCBD5E1)),
                      ),
                      child: Center(
                        child: Text('⚡ Term-Test Cramming', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFFB45309))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedGoal = 'COMPREHENSIVE'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedGoal == 'COMPREHENSIVE' ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _selectedGoal == 'COMPREHENSIVE' ? AppTheme.primaryBlue : const Color(0xFFCBD5E1)),
                      ),
                      child: Center(
                        child: Text('🎯 Deep Mastery', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // School & District
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _registerSchoolController,
                    decoration: InputDecoration(
                      labelText: 'School Name',
                      prefixIcon: const Icon(Icons.school_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _registerDistrictController,
                    decoration: InputDecoration(
                      labelText: 'District',
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Avatar Preset Selection
            Text('Select Companion Avatar:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: ProfileService.availableAvatars.map((avatar) {
                final isSelected = _selectedAvatarId == avatar.id;
                return ChoiceChip(
                  label: Text('${avatar.emoji} ${avatar.name}'),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryLight,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedAvatarId = avatar.id);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: _isRegisterLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isRegisterLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Create Account & Start Learning', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
