import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'models/user_profile.dart';
import 'models/engagement_feedback.dart';
import 'profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();

  UserProfile? _profile;
  EngagementFeedback? _feedback;
  bool _isLoading = true;
  String _selectedSimulatedState = 'FRUSTRATED';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData({String? overrideState}) async {
    setState(() => _isLoading = true);
    final profile = await _profileService.getUserProfile();
    final feedback = await _profileService.getEngagementFeedback(
      overrideState: overrideState ?? _selectedSimulatedState,
    );

    if (mounted) {
      setState(() {
        _profile = profile;
        _feedback = feedback;
        _isLoading = false;
      });
    }
  }

  void _onStateSimulated(String state) {
    setState(() {
      _selectedSimulatedState = state;
    });
    _loadProfileData(overrideState: state);
  }

  AvatarPreset _getCurrentAvatarPreset() {
    final avatarId = _profile?.avatarId ?? 'fox_math';
    return ProfileService.availableAvatars.firstWhere(
      (a) => a.id == avatarId,
      orElse: () => ProfileService.availableAvatars.first,
    );
  }

  void _showAvatarPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currentAvatarId = _profile?.avatarId ?? 'fox_math';
            return Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Choose Profile Character',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Text(
                      'Select an avatar that represents your math journey.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: ProfileService.availableAvatars.length,
                      itemBuilder: (context, index) {
                        final avatar = ProfileService.availableAvatars[index];
                        final isSelected = avatar.id == currentAvatarId;

                        return InkWell(
                          onTap: () async {
                            final nav = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final updated = _profile!.copyWith(avatarId: avatar.id);
                            await _profileService.updateProfile(updated);
                            if (mounted) {
                              setState(() => _profile = updated);
                              nav.pop();
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text('Avatar updated to ${avatar.name}!'),
                                  backgroundColor: AppTheme.primaryBlue,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(avatar.primaryColorValue).withOpacity(0.12)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Color(avatar.primaryColorValue)
                                    : const Color(0xFFE2E8F0),
                                width: isSelected ? 2.5 : 1.2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: Color(avatar.primaryColorValue).withOpacity(0.18),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      avatar.emoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  avatar.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected
                                        ? Color(avatar.primaryColorValue)
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProfileDialog() {
    if (_profile == null) return;

    final nameController = TextEditingController(text: _profile!.fullName);
    final emailController = TextEditingController(text: _profile!.email);
    final schoolController = TextEditingController(text: _profile!.school);
    final districtController = TextEditingController(text: _profile!.district);
    int selectedGrade = _profile!.gradeLevel;
    String selectedArchetype = _profile!.motivationalArchetype;
    String selectedGoal = _profile!.preferredGoal;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_note, color: AppTheme.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Edit Student Profile',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Full Name',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                          hintText: 'Enter student name',
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'Email Address',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                          hintText: 'Enter student email',
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Grade Level',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<int>(
                                  value: selectedGrade,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 10, child: Text('Grade 10')),
                                    DropdownMenuItem(value: 11, child: Text('Grade 11')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => selectedGrade = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Learning Goal',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                DropdownButtonFormField<String>(
                                  value: selectedGoal,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'TERM_TEST', child: Text('Term Test')),
                                    DropdownMenuItem(value: 'COMPREHENSIVE', child: Text('Full Mastery')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) setDialogState(() => selectedGoal = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'School / College',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: schoolController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.school_outlined, size: 20),
                          hintText: 'e.g. Central College, Kandy',
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'District / Region',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: districtController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                          hintText: 'e.g. Central Province',
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'Motivational Archetype (Hexad User Type)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: selectedArchetype,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Achiever', child: Text('Achiever (Mastery & Skill)')),
                          DropdownMenuItem(value: 'Player', child: Text('Player (Rewards & Streaks)')),
                          DropdownMenuItem(value: 'Free Spirit', child: Text('Free Spirit (Exploration)')),
                          DropdownMenuItem(value: 'Philanthropist', child: Text('Philanthropist (Social)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedArchetype = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final updated = _profile!.copyWith(
                      fullName: nameController.text.trim(),
                      email: emailController.text.trim(),
                      school: schoolController.text.trim(),
                      district: districtController.text.trim(),
                      gradeLevel: selectedGrade,
                      preferredGoal: selectedGoal,
                      motivationalArchetype: selectedArchetype,
                    );
                    await _profileService.updateProfile(updated);
                    if (mounted) {
                      setState(() => _profile = updated);
                      nav.pop();
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Profile details updated successfully!'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    minimumSize: const Size(110, 42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleScaffoldingAction(ScaffoldingAction action) {
    if (action.actionType == 'STEP_HINT') {
      _showStepHintModal();
    } else if (action.actionType == 'RESET_CHALLENGE') {
      _showQuickResetPuzzleModal();
    } else if (action.actionType == 'STREAK_SHIELD') {
      _showStreakProtectionModal();
    } else {
      _showCurriculumAdaptModal();
    }
  }

  void _showStepHintModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.lightbulb_outline, color: AppTheme.accentTeal, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Step-by-Step Guided Hint',
                  style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Problem: x² + 5x + 6 = 0',
                style: GoogleFonts.firaCode(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 12),
              _buildHintStepTile('1', 'Identify product a×c and sum b', 'a=1, c=6 → product is 6, sum is 5.'),
              const SizedBox(height: 8),
              _buildHintStepTile('2', 'Find factor pairs of 6', 'Factors that add to 5 are 2 and 3 (2×3=6, 2+3=5).'),
              const SizedBox(height: 8),
              _buildHintStepTile('3', 'Deconstruct into binomial factors', '(x + 2)(x + 3) = 0 → Roots are x = -2, -3.'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(100, 38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Got it! Continue'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHintStepTile(String stepNumber, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppTheme.primaryLight,
            child: Text(
              stepNumber,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickResetPuzzleModal() {
    int answer = -1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setPuzzleState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.warningAmber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.bolt, color: AppTheme.warningAmber, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '60s Quick Reset Puzzle',
                    style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wake up your analytical reflex! What is the missing number?',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '3,  7,  15,  31,  [ ? ]',
                        style: GoogleFonts.firaCode(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [47, 63, 64].map((choice) {
                      final isChosen = answer == choice;
                      return ChoiceChip(
                        label: Text('$choice'),
                        selected: isChosen,
                        selectedColor: choice == 63 ? AppTheme.successGreen : AppTheme.errorRed,
                        onSelected: (selected) {
                          setPuzzleState(() => answer = choice);
                        },
                      );
                    }).toList(),
                  ),
                  if (answer == 63) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.successBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Correct! Rule is (n × 2) + 1. Brain reset completed!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.successGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    minimumSize: const Size(100, 38),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Back to Profile'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStreakProtectionModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.security, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 10),
              Text(
                'Streak Protection Engine',
                style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How Component 3 protects your motivation:',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              _buildFeatureBullet(
                '🛡️ Safe Practice Zone',
                'When you attempt hard questions, failure does not reset your 4-day streak. The ML engine differentiates genuine cognitive struggle from abandonment.',
              ),
              const SizedBox(height: 8),
              _buildFeatureBullet(
                '❄️ 2 Streak Freeze Shields',
                'You currently hold 2 auto-deployable freeze tokens to protect against missed daily sessions.',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(100, 38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Awesome'),
            ),
          ],
        );
      },
    );
  }

  void _showCurriculumAdaptModal() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.alt_route, color: AppTheme.primaryBlue, size: 24),
              ),
              const SizedBox(width: 10),
              Text(
                'Curriculum Signal Dispatched',
                style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Text(
            'Component 3 (Engagement) transmitted your cognitive state vector to Member 4 (Ranathunga) and Member 1 (Aqeel). The next recommended lesson will include intermediate scaffolding before advancing.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(100, 38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Understood'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeatureBullet(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(desc, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.3)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _getCurrentAvatarPreset();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Student Profile & AI Feedback',
          style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Telemetry',
            icon: const Icon(Icons.refresh, size: 20),
            onPressed: () => _loadProfileData(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _loadProfileData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Profile Picture & Header Card
                    _buildProfileHeaderCard(avatar),
                    const SizedBox(height: 18),

                    // 2. ML Engagement & Affective Feedback Section (Component 3 Core)
                    _buildMlFeedbackSection(),
                    const SizedBox(height: 20),

                    // 3. User Details Card (Editable)
                    _buildUserDetailsCard(),
                    const SizedBox(height: 20),

                    // 4. Gamification & Virtual Pet Status (Component 3)
                    _buildGamificationPetCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeaderCard(AvatarPreset avatar) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with Edit Badge
              Stack(
                children: [
                  InkWell(
                    onTap: _showAvatarPickerModal,
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color(avatar.primaryColorValue).withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Color(avatar.primaryColorValue).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          avatar.emoji,
                          style: const TextStyle(fontSize: 42),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showAvatarPickerModal,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentTeal,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Name and Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _profile?.fullName ?? 'Student',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profile?.email ?? 'student@example.lk',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // Grade Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Grade ${_profile?.gradeLevel ?? 10}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Hexad Archetype Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.warningAmber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '🏆 ${_profile?.motivationalArchetype ?? "Achiever"}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.badge_outlined, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Code: ${_profile?.anonymizedCode ?? "STU_HASH"}',
                    style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: _showEditProfileDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.edit, size: 14),
                label: Text(
                  'Edit Details',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMlFeedbackSection() {
    final feedback = _feedback;
    if (feedback == null) return const SizedBox.shrink();

    Color stateColor;
    IconData stateIcon;

    switch (feedback.affectiveState) {
      case 'FOCUSED':
        stateColor = AppTheme.successGreen;
        stateIcon = Icons.psychology;
        break;
      case 'BORED':
        stateColor = AppTheme.warningAmber;
        stateIcon = Icons.hourglass_bottom;
        break;
      case 'AT_RISK':
        stateColor = AppTheme.errorRed;
        stateIcon = Icons.warning_amber_rounded;
        break;
      case 'FRUSTRATED':
      default:
        stateColor = const Color(0xFFEF4444);
        stateIcon = Icons.sentiment_dissatisfied_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: stateColor.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: stateColor.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: stateColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(stateIcon, color: stateColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Behavioral & Affective Feedback',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Component 3 • Real-Time Telemetry Inference',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stateColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(feedback.confidenceScore * 100).toInt()}% Confidence',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: stateColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Current Situation Pill & Explanation Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: stateColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: stateColor.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: stateColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'CURRENT SITUATION: ${feedback.stateLabel.toUpperCase()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: stateColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  feedback.situationExplanation,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),

                // Telemetry Sensor Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildTelemetryPill(
                      Icons.timer_outlined,
                      '${feedback.telemetry.timePerProblemSec.toInt()}s latency',
                    ),
                    _buildTelemetryPill(
                      Icons.pause_circle_outline,
                      '${(feedback.telemetry.hesitationScore * 100).toInt()}% hesitation',
                    ),
                    _buildTelemetryPill(
                      Icons.shuffle,
                      '${(feedback.telemetry.blindGuessingProbability * 100).toInt()}% guess risk',
                    ),
                    _buildTelemetryPill(
                      Icons.error_outline,
                      '${feedback.telemetry.consecutiveErrors} errors',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. What You Should Do Next (Scaffolding Actions)
          Text(
            'What You Should Do Next (AI Interventions):',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          ...feedback.scaffoldingActions.map((action) {
            return _buildScaffoldingCard(action);
          }),
          const SizedBox(height: 14),

          // 3. Telemetry State Simulator (For Evaluation & Demo)
          _buildTelemetrySimulator(),
        ],
      ),
    );
  }

  Widget _buildTelemetryPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffoldingCard(ScaffoldingAction action) {
    Color cardAccent;
    IconData icon;

    switch (action.actionType) {
      case 'STREAK_SHIELD':
        cardAccent = Colors.orange;
        icon = Icons.security_rounded;
        break;
      case 'STEP_HINT':
        cardAccent = AppTheme.primaryBlue;
        icon = Icons.lightbulb;
        break;
      case 'RESET_CHALLENGE':
        cardAccent = AppTheme.accentTeal;
        icon = Icons.bolt;
        break;
      case 'CURRICULUM_ADAPT':
      default:
        cardAccent = AppTheme.accentViolet;
        icon = Icons.alt_route;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cardAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        action.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: cardAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        action.badgeText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: cardAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  action.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => _handleScaffoldingAction(action),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Take Action',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: cardAccent,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(Icons.chevron_right, size: 16, color: cardAccent),
                        ],
                      ),
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

  Widget _buildTelemetrySimulator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 16, color: AppTheme.primaryBlue),
              const SizedBox(width: 6),
              Text(
                'Simulate Behavioral State (Research Testing)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildSimChip('FRUSTRATED', 'Stuck / Frustrated', Colors.red),
              _buildSimChip('FOCUSED', 'Focused / Flow', Colors.green),
              _buildSimChip('BORED', 'Boredom', Colors.amber[800]!),
              _buildSimChip('AT_RISK', 'At-Risk / Fatigue', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimChip(String stateKey, String label, Color color) {
    final isSelected = _selectedSimulatedState == stateKey;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.18),
      backgroundColor: Colors.white,
      labelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
        color: isSelected ? color : AppTheme.textSecondary,
      ),
      onSelected: (_) => _onStateSimulated(stateKey),
    );
  }

  Widget _buildUserDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Student Information',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              InkWell(
                onTap: _showEditProfileDialog,
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 14, color: AppTheme.primaryBlue),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _buildDetailRow(Icons.school_outlined, 'Institution', _profile?.school ?? 'Central College, Kandy'),
          const Divider(height: 18),
          _buildDetailRow(Icons.location_on_outlined, 'Region / District', _profile?.district ?? 'Central Province'),
          const Divider(height: 18),
          _buildDetailRow(
            Icons.flag_outlined,
            'Curriculum Goal',
            _profile?.preferredGoal == 'TERM_TEST' ? 'G.C.E. O/L Term-Test Blitz' : 'Comprehensive Curriculum Mastery',
          ),
          const Divider(height: 18),
          _buildDetailRow(
            Icons.psychology_outlined,
            'Motivational Persona',
            '${_profile?.motivationalArchetype ?? "Achiever"} • Hexad Gamification Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGamificationPetCard() {
    final pet = _feedback?.virtualPet ?? {'name': 'MathPaws', 'level': 2, 'health': 95};
    final streak = _feedback?.streakDays ?? 4;
    final shields = _feedback?.streakFreezeShields ?? 2;
    final xp = _feedback?.totalGamificationPoints ?? 240;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gamification & Virtual Pet (Component 3)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$xp XP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              // Virtual Pet Avatar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pets, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${pet['name']} (Level ${pet['level']})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '${pet['health']}% Health 💚',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (pet['health'] as num).toDouble() / 100.0,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '🔥 $streak Days Streak',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange[800],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '🛡️ $shields Shields Active',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
