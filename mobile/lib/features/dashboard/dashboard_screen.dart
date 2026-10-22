import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import '../learning_path/learning_path_service.dart';
import '../profile/profile_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = LearningPathService();
  int _currentNavIndex = 0;
  Map<String, dynamic>? _activePlan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboardState();
  }

  Future<void> _fetchDashboardState() async {
    setState(() => _isLoading = true);
    final plan = await _service.getActivePlan();
    if (mounted) {
      setState(() {
        _activePlan = plan;
        _isLoading = false;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == _currentNavIndex) return;

    if (index == 0) {
      setState(() => _currentNavIndex = 0);
    } else if (index == 1) {
      Navigator.pushNamed(context, AppRouter.learningPath).then((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
        _fetchDashboardState();
      });
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRouter.gamification).then((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
      });
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRouter.profile).then((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
        _fetchDashboardState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rec = _activePlan?['recommended_activity'] as Map<String, dynamic>? ?? {};
    final recTitle = rec['concept_title'] as String? ?? 'Fractional and Negative Indices';
    final recType = rec['activity_type'] as String? ?? 'WORKED_EXAMPLE';
    final recRationale = rec['rationale'] as String? ?? 'Prerequisite grounding verified. Proceed with worked derivation.';
    final recConceptId = rec['concept_id'] as String? ?? '10000000-0000-0000-0000-000000000002';
    final goalType = _activePlan?['goal_type'] as String? ?? 'TERM_TEST';
    final readinessScore = (_activePlan?['overall_readiness_score'] as num?)?.toDouble() ?? 0.74;
    final gradeLevel = _activePlan?['grade_level'] as int? ?? 11;
    final topicCategory = _activePlan?['topic_category'] as String? ?? 'Indices and Logarithms';
    final isG10 = gradeLevel == 10 || topicCategory.toLowerCase().contains('quad');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'AdaptiveMath AI',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Grade $gradeLevel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Secondary Mathematics Platform',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Active streak chip
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.warningBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 15),
                const SizedBox(width: 3),
                Text(
                  '4 Days',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Profile avatar
          IconButton(
            tooltip: 'Profile & Settings',
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.primaryLight,
              child: Text(
                ProfileService.availableAvatars.firstWhere(
                  (a) => a.id == ProfileService.cachedProfile.avatarId,
                  orElse: () => ProfileService.availableAvatars.first,
                ).emoji,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            onPressed: () => Navigator.pushNamed(context, AppRouter.profile).then((_) => _fetchDashboardState()),
          ),
          const SizedBox(width: 4),

          // Logout
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, size: 19, color: AppTheme.textSecondary),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.login),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardState,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Personalized Greeting Hero Banner
              _buildGreetingHeroBanner(gradeLevel: gradeLevel, goalType: goalType),
              const SizedBox(height: 18),

              // 2. Component 1 Showcase: Active AI Learning Pathway
              _buildActivePathwayHeroCard(
                goalType: goalType,
                recTitle: recTitle,
                recType: recType,
                recRationale: recRationale,
                recConceptId: recConceptId,
                readinessScore: readinessScore,
                gradeLevel: gradeLevel,
                topicCategory: topicCategory,
                isG10: isG10,
              ),
              const SizedBox(height: 20),

              // 3. Curriculum Tracks Switcher (Grade 10 vs Grade 11)
              _buildCurriculumTrackSelector(isG10: isG10, goalType: goalType),
              const SizedBox(height: 20),

              // 4. Core Integrated AI Research Suite (4 Clean Cards)
              _buildIntegratedComponentsSection(),
              const SizedBox(height: 16),

              // 5. Multiplayer Speed Challenge Card
              _buildMultiplayerArenaBanner(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: _onBottomNavTapped,
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: AppTheme.primaryLight,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route_outlined),
            selectedIcon: Icon(Icons.alt_route_rounded, color: AppTheme.primaryBlue),
            label: 'Pathway',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded, color: Color(0xFFD97706)),
            label: 'MathPaws',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. GREETING HERO BANNER
  // =========================================================================
  Widget _buildGreetingHeroBanner({required int gradeLevel, required String goalType}) {
    final isCramming = goalType == 'TERM_TEST';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.2),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Welcome, Student! 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4ADE80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF4ADE80), size: 6),
                    const SizedBox(width: 4),
                    Text(
                      'AI Active',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Personalized Prerequisite Learning Roadmap • Grade $gradeLevel O/L',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),

          // Responsive Feature Pills
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildMiniPill(
                isCramming ? '⚡ Term-Test Blitz' : '🎯 Comprehensive',
                isCramming ? const Color(0xFFF59E0B) : const Color(0xFF38BDF8),
              ),
              _buildMiniPill('⏱️ 30m / day target', const Color(0xFF94A3B8)),
              _buildMiniPill('🔒 100% DAG Invariant Guardrail', const Color(0xFF4ADE80)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // =========================================================================
  // 2. ACTIVE AI LEARNING PATHWAY HERO CARD (Component 1)
  // =========================================================================
  Widget _buildActivePathwayHeroCard({
    required String goalType,
    required String recTitle,
    required String recType,
    required String recRationale,
    required String recConceptId,
    required double readinessScore,
    required int gradeLevel,
    required String topicCategory,
    required bool isG10,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.35), width: 1.6),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI LEARNING PATHWAY',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  topicCategory,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Recommended Concept Spotlight
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                // Circular Readiness Meter
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryBlue, width: 2),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(readinessScore * 100).toInt()}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        Text(
                          'Ready',
                          style: GoogleFonts.plusJakartaSans(fontSize: 7.5, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RECOMMENDED NEXT ACTIVITY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.accentTeal,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        recTitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        recRationale,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Primary Launch Action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.learningPath).then((_) => _fetchDashboardState());
              },
              icon: const Icon(Icons.play_circle_fill, size: 20),
              label: Text(
                'Continue Learning Pathway',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.learningGoal).then((_) => _fetchDashboardState()),
                  icon: const Icon(Icons.tune, size: 14),
                  label: const Text('Goal & Time', style: TextStyle(fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.diagnostic).then((_) => _fetchDashboardState()),
                  icon: const Icon(Icons.quiz_outlined, size: 14),
                  label: const Text('Pre-Test', style: TextStyle(fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppRouter.telemetry),
                  icon: const Icon(Icons.analytics_outlined, size: 14),
                  label: const Text('Telemetry', style: TextStyle(fontSize: 11.5)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. CURRICULUM TRACK SELECTOR (GRADE 10 VS GRADE 11)
  // =========================================================================
  Widget _buildCurriculumTrackSelector({required bool isG10, required String goalType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Curriculum Tracks',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            // Track 1: Grade 11
            Expanded(
              child: _buildTrackCard(
                title: 'Indices & Logarithms',
                grade: 'Grade 11 (O/L)',
                conceptsCount: 7,
                isSelected: !isG10,
                color: AppTheme.primaryBlue,
                icon: Icons.functions,
                onTap: () async {
                  await _service.createPlan(
                    studentId: LearningPathService.demoStudentId,
                    topicCategory: "Indices and Logarithms",
                    gradeLevel: 11,
                    goalType: goalType,
                  );
                  _fetchDashboardState();
                },
              ),
            ),
            const SizedBox(width: 10),

            // Track 2: Grade 10
            Expanded(
              child: _buildTrackCard(
                title: 'Quadratic Equations',
                grade: 'Grade 10 Algebra',
                conceptsCount: 4,
                isSelected: isG10,
                color: AppTheme.accentTeal,
                icon: Icons.linear_scale,
                onTap: () async {
                  await _service.createPlan(
                    studentId: LearningPathService.demoStudentId,
                    topicCategory: "Quadratic Equations",
                    gradeLevel: 10,
                    goalType: goalType,
                  );
                  _fetchDashboardState();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackCard({
    required String title,
    required String grade,
    required int conceptsCount,
    required bool isSelected,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '$grade • $conceptsCount concepts',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 4. INTEGRATED AI RESEARCH SUITE (4 Clean, Responsive Cards)
  // =========================================================================
  Widget _buildIntegratedComponentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Integrated AI Research Suite',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Four specialized research engines collaborating in real time',
          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 12),

        // Grid of 4 components (2x2 layout, responsive)
        Row(
          children: [
            Expanded(
              child: _buildSuiteCard(
                icon: Icons.alt_route_rounded,
                iconColor: AppTheme.primaryBlue,
                tag: 'COMPONENT 1',
                title: 'Adaptive Pathway',
                desc: 'DAG Invariants & ML Planning',
                onTap: () => Navigator.pushNamed(context, AppRouter.learningPath),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSuiteCard(
                icon: Icons.psychology_rounded,
                iconColor: const Color(0xFF7C3AED),
                tag: 'COMPONENT 2',
                title: 'Knowledge Tracing',
                desc: 'BKT & Memory Decay',
                onTap: () => Navigator.pushNamed(context, AppRouter.learnerProfiling),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _buildSuiteCard(
                icon: Icons.pets_rounded,
                iconColor: const Color(0xFFD97706),
                tag: 'COMPONENT 3',
                title: 'MathPaws Companion',
                desc: 'Pet Health & Milestones',
                onTap: () => Navigator.pushNamed(context, AppRouter.gamification),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildSuiteCard(
                icon: Icons.fact_check_rounded,
                iconColor: const Color(0xFF0284C7),
                tag: 'COMPONENT 4',
                title: 'Error Diagnosis',
                desc: '8-Category Misconceptions',
                onTap: () => Navigator.pushNamed(context, AppRouter.submit),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuiteCard({
    required IconData icon,
    required Color iconColor,
    required String tag,
    required String title,
    required String desc,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                Text(
                  tag,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 5. MULTIPLAYER QUIZ ARENA BANNER
  // =========================================================================
  Widget _buildMultiplayerArenaBanner() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRouter.multiplayer),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4338CA).withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.sports_esports_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Multiplayer Speed Arena',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Real-time peer calculation battle with room codes',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}
