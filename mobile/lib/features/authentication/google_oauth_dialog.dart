import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_service.dart';

class GoogleOAuthDialog extends StatefulWidget {
  final Function(AuthUser user) onAuthenticated;

  const GoogleOAuthDialog({
    super.key,
    required this.onAuthenticated,
  });

  static Future<void> show(BuildContext context, {required Function(AuthUser user) onAuthenticated}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: GoogleOAuthDialog(onAuthenticated: onAuthenticated),
      ),
    );
  }

  @override
  State<GoogleOAuthDialog> createState() => _GoogleOAuthDialogState();
}

class _GoogleOAuthDialogState extends State<GoogleOAuthDialog> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController(text: 'googlePass123!');

  int _step = 0; // 0 = Account Picker, 1 = Email Entry, 2 = Password Entry
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _selectedGrade = 11;
  String? _errorMessage;

  List<Map<String, dynamic>> _savedAccounts = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final list = await AuthService.getSavedGoogleAccounts();
    if (mounted) {
      setState(() {
        _savedAccounts = list;
        // If no saved accounts, jump directly to Email Entry
        if (list.isEmpty) _step = 1;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performGoogleLogin({
    required String email,
    required String name,
    required String googleId,
    int gradeLevel = 11,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.loginWithGoogle(
        googleId: googleId,
        email: email,
        fullName: name,
        gradeLevel: gradeLevel,
        preferredGoal: gradeLevel == 10 ? 'COMPREHENSIVE' : 'TERM_TEST',
        avatarId: gradeLevel == 10 ? 'owl_scholar' : 'fox_math',
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onAuthenticated(user);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Authentication error: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _proceedToPassword() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Enter an email or phone number');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Enter a valid email address');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      final part = email.split('@')[0];
      _nameController.text = part.replaceAll('.', ' ').split(' ').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ');
    }

    setState(() {
      _errorMessage = null;
      _step = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Google Linear Progress Bar
          if (_isLoading)
            const LinearProgressIndicator(
              color: Color(0xFF1A73E8),
              backgroundColor: Color(0xFFE8F0FE),
              minHeight: 4,
            )
          else
            const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Google "G" Logo
                Center(child: _buildGoogleLogo(size: 32)),
                const SizedBox(height: 14),

                if (_step == 0) _buildAccountPickerStep(),
                if (_step == 1) _buildEmailEntryStep(),
                if (_step == 2) _buildPasswordEntryStep(),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFD93025), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.roboto(color: const Color(0xFFD93025), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Google Privacy & Terms Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: const Color(0xFFF8F9FA),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'English (United States)',
                  style: GoogleFonts.roboto(fontSize: 11, color: const Color(0xFF5F6368)),
                ),
                Row(
                  children: [
                    Text('Help', style: GoogleFonts.roboto(fontSize: 11, color: const Color(0xFF5F6368))),
                    const SizedBox(width: 14),
                    Text('Privacy', style: GoogleFonts.roboto(fontSize: 11, color: const Color(0xFF5F6368))),
                    const SizedBox(width: 14),
                    Text('Terms', style: GoogleFonts.roboto(fontSize: 11, color: const Color(0xFF5F6368))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STEP 0: GOOGLE ACCOUNT PICKER (Like normal websites)
  // ===========================================================================
  Widget _buildAccountPickerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Choose an account',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF202124),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'to continue to AdaptiveMath AI',
          style: GoogleFonts.roboto(
            fontSize: 13,
            color: const Color(0xFF5F6368),
          ),
        ),
        const SizedBox(height: 20),

        // Accounts List
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDADCE0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              for (int i = 0; i < _savedAccounts.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Color(0xFFDADCE0)),
                _buildAccountTile(_savedAccounts[i]),
              ],
              const Divider(height: 1, color: Color(0xFFDADCE0)),

              // Use another account option
              ListTile(
                dense: true,
                leading: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFF1F3F4),
                  child: Icon(Icons.person_add_alt_outlined, color: Color(0xFF5F6368), size: 18),
                ),
                title: Text(
                  'Use another account',
                  style: GoogleFonts.roboto(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF202124),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _emailController.clear();
                    _step = 1;
                    _errorMessage = null;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTile(Map<String, dynamic> acc) {
    final email = acc['email'] as String? ?? 'user@gmail.com';
    final name = acc['name'] as String? ?? 'Student';
    final googleId = acc['google_id'] as String? ?? 'google_${email.hashCode}';
    final grade = (acc['grade_level'] as num?)?.toInt() ?? 11;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: grade == 10 ? const Color(0xFF34A853) : const Color(0xFF4285F4),
        child: Text(
          initial,
          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      title: Text(
        name,
        style: GoogleFonts.roboto(fontSize: 13.5, fontWeight: FontWeight.w500, color: const Color(0xFF202124)),
      ),
      subtitle: Text(
        '$email • Grade $grade',
        style: GoogleFonts.roboto(fontSize: 11, color: const Color(0xFF5F6368)),
      ),
      onTap: _isLoading
          ? null
          : () => _performGoogleLogin(
                email: email,
                name: name,
                googleId: googleId,
                gradeLevel: grade,
              ),
    );
  }

  // ===========================================================================
  // STEP 1: EMAIL ENTRY STEP (Pixel-perfect Google OAuth)
  // ===========================================================================
  Widget _buildEmailEntryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Sign in',
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF202124),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'with your Google Account to continue to AdaptiveMath AI',
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: const Color(0xFF5F6368),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Email Textfield
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Email or phone',
            hintText: 'e.g. aqeel.student@gmail.com',
            labelStyle: GoogleFonts.roboto(color: const Color(0xFF5F6368), fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFDADCE0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                'Forgot email?',
                style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF1A73E8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Full Name (Optional Google profile sync)
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Display Name (Google Profile)',
            hintText: 'e.g. Aqeel M.I.M',
            labelStyle: GoogleFonts.roboto(color: const Color(0xFF5F6368), fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFDADCE0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
        const SizedBox(height: 14),

        // Grade selector for learning path synchronization
        Text('Curriculum Grade Level:', style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF5F6368))),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Grade 10 (Quadratics)', style: TextStyle(fontSize: 11))),
                selected: _selectedGrade == 10,
                selectedColor: const Color(0xFFE8F0FE),
                onSelected: (val) => setState(() => _selectedGrade = 10),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('Grade 11 (Indices)', style: TextStyle(fontSize: 11))),
                selected: _selectedGrade == 11,
                selectedColor: const Color(0xFFE8F0FE),
                onSelected: (val) => setState(() => _selectedGrade = 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Text(
          'To continue, Google will share your name, email address, and profile picture with AdaptiveMath AI.',
          style: GoogleFonts.roboto(fontSize: 11, color: const Color(0xFF5F6368), height: 1.35),
        ),
        const SizedBox(height: 24),

        // Navigation Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_savedAccounts.isNotEmpty)
              TextButton(
                onPressed: () => setState(() => _step = 0),
                child: Text('Back', style: GoogleFonts.roboto(color: const Color(0xFF1A73E8), fontWeight: FontWeight.w500)),
              )
            else
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: GoogleFonts.roboto(color: const Color(0xFF1A73E8), fontWeight: FontWeight.w500)),
              ),
            ElevatedButton(
              onPressed: _proceedToPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: Text('Next', style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 13.5)),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // STEP 2: PASSWORD ENTRY STEP
  // ===========================================================================
  Widget _buildPasswordEntryStep() {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : email.split('@')[0];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Welcome',
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF202124),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Google User Account Chip
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFDADCE0)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color(0xFF4285F4),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'G',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  email,
                  style: GoogleFonts.roboto(fontSize: 12, color: const Color(0xFF3C4043), fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => setState(() => _step = 1),
                  child: const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF5F6368)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Password Textfield
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Enter your password',
            labelStyle: GoogleFonts.roboto(color: const Color(0xFF5F6368), fontSize: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFDADCE0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            Checkbox(
              value: !_obscurePassword,
              activeColor: const Color(0xFF1A73E8),
              onChanged: (val) => setState(() => _obscurePassword = !val!),
            ),
            Text('Show password', style: GoogleFonts.roboto(fontSize: 12.5, color: const Color(0xFF3C4043))),
          ],
        ),
        const SizedBox(height: 24),

        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => setState(() => _step = 1),
              child: Text('Back', style: GoogleFonts.roboto(color: const Color(0xFF1A73E8), fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () => _performGoogleLogin(
                        email: email,
                        name: name,
                        googleId: 'google_${email.hashCode.abs()}',
                        gradeLevel: _selectedGrade,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Next', style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 13.5)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoogleLogo({double size = 28}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final stroke = w * 0.22;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, w - stroke, h - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Blue (Right quadrant)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.6, 1.2, false, paint);

    // Green (Bottom quadrant)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.6, 1.5, false, paint);

    // Yellow (Bottom-left to top-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.1, 1.4, false, paint);

    // Red (Top quadrant)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.5, 1.5, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(w * 0.44, h * 0.5 - (stroke * 0.48), w * 0.52, stroke * 0.96),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
