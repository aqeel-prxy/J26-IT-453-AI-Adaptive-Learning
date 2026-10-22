import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _imagePicker = ImagePicker();

  UserProfile? _profile;
  EngagementFeedback? _feedback;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    final profile = await _profileService.getUserProfile();
    final feedback = await _profileService.getEngagementFeedback();

    if (mounted) {
      setState(() {
        _profile = profile;
        _feedback = feedback;
        _isLoading = false;
      });
    }
  }

  AvatarPreset _getCurrentAvatarPreset() {
    final avatarId = _profile?.avatarId ?? 'fox_math';
    return ProfileService.availableAvatars.firstWhere(
      (a) => a.id == avatarId,
      orElse: () => ProfileService.availableAvatars.first,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image != null && _profile != null) {
        final updated = _profile!.copyWith(customAvatarUrl: image.path);
        await _profileService.updateProfile(updated);
        if (mounted) {
          setState(() => _profile = updated);
          nav.pop(); // close modal if open
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Unable to select image: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _showImageUrlInputDialog() {
    final urlController = TextEditingController(text: _profile?.customAvatarUrl ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Enter Image URL',
            style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Paste a direct link to any image online (JPG, PNG, WebP):',
                style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  hintText: 'https://example.com/avatar.jpg',
                  prefixIcon: Icon(Icons.link, size: 20),
                ),
              ),
            ],
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
                final url = urlController.text.trim();
                if (url.isNotEmpty && _profile != null) {
                  final updated = _profile!.copyWith(customAvatarUrl: url);
                  await _profileService.updateProfile(updated);
                  if (mounted) {
                    setState(() => _profile = updated);
                    nav.pop(); // close dialog
                    nav.pop(); // close bottom sheet
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Profile picture updated with image URL!'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
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
                        'Change Profile Picture',
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
                    'Upload your own photo or choose a student character avatar.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 1. Own Photo Upload Options
                  Text(
                    'UPLOAD YOUR OWN IMAGE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.photo_library, color: AppTheme.primaryBlue, size: 20),
                          label: Text(
                            'Choose Gallery',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: AppTheme.accentTeal, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.camera_alt, color: AppTheme.accentTeal, size: 20),
                          label: Text(
                            'Take Photo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.accentTeal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _showImageUrlInputDialog,
                          icon: const Icon(Icons.link, size: 18, color: AppTheme.textSecondary),
                          label: Text(
                            'Or Enter Image Web URL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      if (_profile?.customAvatarUrl != null)
                        TextButton.icon(
                          onPressed: () async {
                            final nav = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            final updated = _profile!.copyWith(clearCustomAvatar: true);
                            await _profileService.updateProfile(updated);
                            if (mounted) {
                              setState(() => _profile = updated);
                              nav.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Custom photo removed. Switched to preset character.'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.errorRed),
                          label: Text(
                            'Remove Photo',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.errorRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 10),

                  // 2. Character Presets Alternative
                  Text(
                    'OR CHOOSE A CHARACTER AVATAR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: ProfileService.availableAvatars.length,
                    itemBuilder: (context, index) {
                      final avatar = ProfileService.availableAvatars[index];
                      final isSelected = (_profile?.customAvatarUrl == null || _profile!.customAvatarUrl!.isEmpty) &&
                          avatar.id == (_profile?.avatarId ?? 'fox_math');

                      return InkWell(
                        onTap: () async {
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final updated = _profile!.copyWith(
                            avatarId: avatar.id,
                            clearCustomAvatar: true,
                          );
                          await _profileService.updateProfile(updated);
                          if (mounted) {
                            setState(() => _profile = updated);
                            nav.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Avatar set to ${avatar.name}!'),
                                backgroundColor: AppTheme.primaryBlue,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(8),
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Color(avatar.primaryColorValue).withOpacity(0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    avatar.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                avatar.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
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
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
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

    const gradeItems = <DropdownMenuItem<int>>[
      DropdownMenuItem(value: 10, child: Text('Grade 10')),
      DropdownMenuItem(value: 11, child: Text('Grade 11')),
    ];
    if (!gradeItems.any((item) => item.value == selectedGrade)) {
      selectedGrade = 10;
    }

    final goalItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: 'TERM_TEST', child: Text('Term Test')),
      const DropdownMenuItem(value: 'COMPREHENSIVE', child: Text('Full Mastery')),
    ];
    if (!goalItems.any((item) => item.value == selectedGoal)) {
      if (selectedGoal.isNotEmpty) {
        goalItems.add(DropdownMenuItem(value: selectedGoal, child: Text(selectedGoal)));
      } else {
        selectedGoal = 'TERM_TEST';
      }
    }

    final archetypeItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: 'Mastery Seeker', child: Text('Mastery Seeker (Skill & Mastery)')),
      const DropdownMenuItem(value: 'Strategic Achiever', child: Text('Strategic Achiever (Milestones & Goals)')),
      const DropdownMenuItem(value: 'Achiever', child: Text('Achiever (Mastery & Skill)')),
      const DropdownMenuItem(value: 'Player', child: Text('Player (Rewards & Streaks)')),
      const DropdownMenuItem(value: 'Free Spirit', child: Text('Free Spirit (Exploration)')),
      const DropdownMenuItem(value: 'Philanthropist', child: Text('Philanthropist (Social & Purpose)')),
      const DropdownMenuItem(value: 'Socialiser', child: Text('Socialiser (Community & Collaboration)')),
      const DropdownMenuItem(value: 'Disruptor', child: Text('Disruptor (Change & Innovation)')),
    ];
    if (!archetypeItems.any((item) => item.value == selectedArchetype)) {
      if (selectedArchetype.isNotEmpty) {
        archetypeItems.add(DropdownMenuItem(value: selectedArchetype, child: Text(selectedArchetype)));
      } else {
        selectedArchetype = 'Mastery Seeker';
      }
    }

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

                      Text(
                        'School Name',
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
                        'Region / District',
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
                                  items: gradeItems,
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
                                  items: goalItems,
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
                        'Motivational Archetype (Hexad)',
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
                        items: archetypeItems,
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

  Widget _buildAvatarImage(AvatarPreset avatar) {
    final customUrl = _profile?.customAvatarUrl;

    if (customUrl != null && customUrl.isNotEmpty) {
      if (customUrl.startsWith('http://') || customUrl.startsWith('https://')) {
        return ClipOval(
          child: Image.network(
            customUrl,
            width: 82,
            height: 82,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackEmoji(avatar),
          ),
        );
      } else if (!kIsWeb) {
        return ClipOval(
          child: Image.file(
            File(customUrl),
            width: 82,
            height: 82,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackEmoji(avatar),
          ),
        );
      }
    }

    return _buildFallbackEmoji(avatar);
  }

  Widget _buildFallbackEmoji(AvatarPreset avatar) {
    return Center(
      child: Text(
        avatar.emoji,
        style: const TextStyle(fontSize: 42),
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
          'Student Profile & Feedback',
          style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: _showEditProfileDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfileData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Student Details Area (with Profile Picture, School, Region)
                    _buildTopStudentDetailsCard(avatar),
                    const SizedBox(height: 18),

                    // 2. Minimal AI Adaptive Feedback Card (Clean Dummy Info for ML)
                    _buildMinimalFeedbackCard(),
                    const SizedBox(height: 18),

                    // 3. Gamification & Virtual Pet Status (Component 3)
                    _buildGamificationPetCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopStudentDetailsCard(AvatarPreset avatar) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Primary Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Editable Profile Avatar
              Stack(
                children: [
                  InkWell(
                    onTap: _showAvatarPickerModal,
                    borderRadius: BorderRadius.circular(44),
                    child: Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Color(avatar.primaryColorValue).withOpacity(0.25),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _buildAvatarImage(avatar),
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

              // Name, Code, Email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _profile?.fullName ?? 'Student',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _profile?.email ?? 'student@example.lk',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
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
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.warningAmber,
                            borderRadius: BorderRadius.circular(10),
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
          const SizedBox(height: 14),

          // School & Region Information (Requirement 3: In Top Student Details)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_outlined, color: AppTheme.accentTeal, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SCHOOL / COLLEGE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white60,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            _profile?.school ?? 'Central College, Kandy',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REGION / DISTRICT',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white60,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            _profile?.district ?? 'Central Province',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Footer with Code and Edit Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ${_profile?.anonymizedCode ?? "STU_HASH_9A4F21"}',
                style: GoogleFonts.firaCode(fontSize: 11, color: Colors.white60),
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

  Widget _buildMinimalFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI Adaptive Feedback',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.successBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  'ML Active',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Current Situation (Clean Dummy Info)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights, size: 16, color: AppTheme.primaryBlue),
                    const SizedBox(width: 6),
                    Text(
                      'Current Situation',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Your learning pace is steady and focused. You are currently maintaining good consistency across your practice sessions.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. What They Should Do Next (Clean Dummy Info)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.successGreen),
                    const SizedBox(width: 6),
                    Text(
                      'What You Should Do Next',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete 2 more practice questions in Quadratic Equations to reinforce your understanding and keep your daily streak safe.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: const Color(0xFF15803D),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
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
