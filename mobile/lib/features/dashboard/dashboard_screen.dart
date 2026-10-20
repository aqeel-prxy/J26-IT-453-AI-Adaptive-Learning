import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import '../learning_path/learning_path_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = LearningPathService();
  int _currentNavIndex = 0;
  Map<String, dynamic>? _activePlan;

  @override
  void initState() {
    super.initState();
    _fetchDashboardState();
  }

  Future<void> _fetchDashboardState() async {
    final plan = await _service.getActivePlan();
    if (mounted) {
      setState(() {
        _activePlan = plan;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) return; // already on home
    setState(() => _currentNavIndex = index);

    if (index == 1) {
      Navigator.pushNamed(context, AppRouter.learningPath).then((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
        _fetchDashboardState();
      });
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRouter.learnerProfiling).then((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
      });
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRouter.gamification).then((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
      });
    } else if (index == 4) {
      Navigator.pushNamed(context, AppRouter.question).then((_) {
        if (mounted) setState(() => _currentNavIndex = 0);
        _fetchDashboardState();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final rec = _activePlan?['recommended_activity'] as Map<String, dynamic>? ?? {};
    final recTitle = rec['concept_title'] as String? ?? 'Fractional and Negative Indices';
    final recType = rec['activity_type'] as String? ?? 'PRACTICE';
    final recRationale = rec['rationale'] as String? ?? 'High predicted readiness. Proceed directly to practice.';
    final recConceptId = rec['concept_id'] as String? ?? '10000000-0000-0000-0000-000000000002';
    final goalType = _activePlan?['goal_type'] as String? ?? 'TERM_TEST';
    final readinessScore = (_activePlan?['overall_readiness_score'] as num?)?.toDouble() ?? 0.74;
    final gradeLevel = _activePlan?['grade_level'] as int? ?? 11;
    final topicCategory = _activePlan?['topic_category'] as String? ?? 'Indices and Logarithms';
    final isG10 = gradeLevel == 10 || topicCategory.toLowerCase().contains('quad');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AdaptiveMath AI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Grade $gradeLevel O/L',
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
                  'Secondary Mathematics Learning Platform',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Active streak pill
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.warningBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  '4 Days',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout, size: 20),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRouter.login),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardState,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Platform Banner
              _buildProjectHeroBanner(gradeLevel: gradeLevel, isG10: isG10),
              const SizedBox(height: 22),

              // 2. The 4 Distinct Learning Modules
              _buildLearningModulesSection(
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
              const SizedBox(height: 24),

              // 3. Multi-Engine Architecture & Data Flow
              _buildSystemArchitectureCard(),
              const SizedBox(height: 24),

              // 4. Curriculum Tracks Switcher (Grade 10 vs Grade 11)
              _buildCurriculumTopicsSection(isG10: isG10, goalType: goalType),
              const SizedBox(height: 24),

              // 5. Diagnostic Quick Calibration Card
              _buildDiagnosticQuickCard(),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: _onBottomNavTapped,
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route_outlined),
            selectedIcon: Icon(Icons.alt_route),
            label: 'Pathway',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'Mastery',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'MathPaws',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Diagnostics',
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 1. HERO PLATFORM BANNER
  // =========================================================================
  Widget _buildProjectHeroBanner({required int gradeLevel, required bool isG10}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.5)),
                ),
                child: Text(
                  'AI-POWERED ADAPTIVE LEARNING',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF93C5FD),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4ADE80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF4ADE80), size: 7),
                    const SizedBox(width: 5),
                    Text(
                      'All Systems Active',
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
          const SizedBox(height: 14),
          Text(
            'Intelligent Mathematics Learning Ecosystem',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Personalized Prerequisite Pathways • Grade 10 & 11 G.C.E. (O/L)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildFeaturePill('Offline SQLite Sync', Icons.offline_pin_outlined),
              _buildFeaturePill('Curriculum DAG Guardrail', Icons.account_tree_outlined),
              _buildFeaturePill('Cost-Sensitive ML (tau=0.59)', Icons.tune_outlined),
              _buildFeaturePill('Cognitive Tracing', Icons.psychology_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF38BDF8)),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. THE FOUR DISTINCT LEARNING MODULES
  // =========================================================================
  Widget _buildLearningModulesSection({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Core Learning Suite',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Comprehensive intelligent tools for mastering secondary mathematics',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                '4 Modules',
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

        // --- MODULE 1: Adaptive Learning Pathway (Your Fully Operational Engine) ---
        _buildAdaptivePathwayCard(
          goalType: goalType,
          recTitle: recTitle,
          recType: recType,
          recRationale: recRationale,
          conceptId: recConceptId,
          readinessScore: readinessScore,
          gradeLevel: gradeLevel,
          topicCategory: topicCategory,
          isG10: isG10,
        ),
        const SizedBox(height: 14),

        // --- MODULE 2: Knowledge Mastery & Memory Retention ---
        _buildMasteryCard(),
        const SizedBox(height: 14),

        // --- MODULE 3: MathPaws Learning Companion ---
        _buildCompanionCard(),
        const SizedBox(height: 14),

        // --- MODULE 4: Step-by-Step Math Diagnostics ---
        _buildDiagnosticsCard(),
      ],
    );
  }

  // --- MODULE 1: ADAPTIVE LEARNING PATHWAY ---
  Widget _buildAdaptivePathwayCard({
    required String goalType,
    required String recTitle,
    required String recType,
    required String recRationale,
    required String conceptId,
    required double readinessScore,
    required int gradeLevel,
    required String topicCategory,
    required bool isG10,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.6), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.alt_route, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PATHWAY ENGINE',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFBFDBFE),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'Adaptive Learning Pathway',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'AI ACTIVE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal-Aware & Prerequisite-Adaptive Path Planning',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Topological DAG guardrail sequencing with cost-sensitive readiness prediction. Dynamically adapts your learning trajectory to ensure foundational prerequisites are satisfied.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary, height: 1.35),
                ),
                const SizedBox(height: 14),

                // Live Active Track Status Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
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
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              Text(
                                'Readiness',
                                style: GoogleFonts.plusJakartaSans(fontSize: 8, color: AppTheme.textSecondary),
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
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    goalType == 'TERM_TEST' ? '⚡ Term-Test Cramming' : '🎯 Comprehensive Mastery',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Grade $gradeLevel',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recTitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
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

                // Primary Launch Button
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
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Quick Action Sub-buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.learningGoal).then((_) => _fetchDashboardState()),
                      icon: const Icon(Icons.tune, size: 14),
                      label: const Text('Set Goal & Grade', style: TextStyle(fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.diagnostic).then((_) => _fetchDashboardState()),
                      icon: const Icon(Icons.quiz_outlined, size: 14),
                      label: const Text('Diagnostic Quiz', style: TextStyle(fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.telemetry),
                      icon: const Icon(Icons.analytics_outlined, size: 14),
                      label: const Text('Engine Analytics', style: TextStyle(fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.lessonUnit, arguments: conceptId),
                      icon: const Icon(Icons.menu_book_outlined, size: 14),
                      label: const Text('Lesson Unit', style: TextStyle(fontSize: 11.5)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: const Size(0, 32),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- MODULE 2: KNOWLEDGE MASTERY & MEMORY RETENTION ---
  Widget _buildMasteryCard() {
    return _buildFeatureCardTemplate(
      badgeText: 'COGNITIVE TRACING',
      badgeColor: const Color(0xFF7C3AED),
      badgeBgColor: const Color(0xFFF3E8FF),
      title: 'Knowledge Mastery & Memory Retention',
      subtitle: 'Cognitive Tracing & Spaced Forgetting Curve',
      description: 'Ebbinghaus memory decay modeling R(t)=exp(-t/S), latent concept mastery tracking, and response latency distribution.',
      icon: Icons.psychology_outlined,
      iconColor: const Color(0xFF7C3AED),
      metricPreview: 'Mastery P(Kc) = 74.2% • Retention S = 14d • Mean Latency = 28.4s',
      onPrimaryTap: () => Navigator.pushNamed(context, AppRouter.learnerProfiling),
      primaryButtonLabel: 'View Mastery & Retention Insights',
      onInfoTap: () => _showMasteryModal(context),
    );
  }

  // --- MODULE 3: MATHPAWS LEARNING COMPANION ---
  Widget _buildCompanionCard() {
    return _buildFeatureCardTemplate(
      badgeText: 'DAILY MOTIVATION',
      badgeColor: const Color(0xFFD97706),
      badgeBgColor: const Color(0xFFFEF3C7),
      title: 'MathPaws Learning Companion',
      subtitle: 'Gamified Motivation & Continuous Retention',
      description: 'Interactive companion pet dynamics, 4-day streak multipliers (1.5x XP), and contextual encouragement to maintain study habits.',
      icon: Icons.pets_outlined,
      iconColor: const Color(0xFFD97706),
      metricPreview: 'MathPaws Level 2 • Health: 95/100 💚 • 4 Days Streak 🔥 (240 XP)',
      onPrimaryTap: () => Navigator.pushNamed(context, AppRouter.gamification),
      primaryButtonLabel: 'Visit MathPaws Companion Hub',
      onInfoTap: () => _showCompanionModal(context),
    );
  }

  // --- MODULE 4: STEP-BY-STEP MATH DIAGNOSTICS ---
  Widget _buildDiagnosticsCard() {
    return _buildFeatureCardTemplate(
      badgeText: 'SOLUTION ANALYSIS',
      badgeColor: const Color(0xFF0284C7),
      badgeBgColor: const Color(0xFFE0F2FE),
      title: 'Step-by-Step Math Diagnostics',
      subtitle: 'Mathematical Solution Analysis & Error Detection',
      description: '8-category mathematical error taxonomy, multi-line algebraic misconception parsing, and step-by-step remediation.',
      icon: Icons.fact_check_outlined,
      iconColor: const Color(0xFF0284C7),
      metricPreview: 'Step 3 Transformation Analysis • Sign Inversion Type 2 • Remedial Tip',
      onPrimaryTap: () => Navigator.pushNamed(context, AppRouter.question),
      primaryButtonLabel: 'Open Problem Solving Workspace',
    );
  }

  // Reusable Feature Card Template
  Widget _buildFeatureCardTemplate({
    required String badgeText,
    required Color badgeColor,
    required Color badgeBgColor,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String metricPreview,
    required VoidCallback onPrimaryTap,
    required String primaryButtonLabel,
    VoidCallback? onInfoTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badgeText,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        if (onInfoTap != null)
                          GestureDetector(
                            onTap: onInfoTap,
                            child: const Icon(Icons.info_outline, size: 18, color: AppTheme.textMuted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary, height: 1.35),
          ),
          const SizedBox(height: 10),

          // Metric Preview Chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.insights, size: 14, color: badgeColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    metricPreview,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Primary Navigation Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPrimaryTap,
              icon: Icon(Icons.arrow_forward, size: 16, color: badgeColor),
              label: Text(
                primaryButtonLabel,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: AppTheme.textPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: badgeBgColor,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: badgeColor.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. MULTI-ENGINE ARCHITECTURE & DATA FLOW
  // =========================================================================
  Widget _buildSystemArchitectureCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sync_alt, color: AppTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Integrated Multi-Engine Architecture',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'How the platform components collaborate seamlessly behind the scenes:',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),

          _buildDataFlowStep(
            '1. Inputs',
            'Cognitive Profiling (Mastery Vectors P(Kc)) + Solution Diagnostics (Error Misconceptions)',
            Icons.input,
            const Color(0xFF7C3AED),
          ),
          const SizedBox(height: 8),
          _buildDataFlowStep(
            '2. Pathway',
            'Adaptive Pathway Engine: Cost-Sensitive ML (tau*=0.59) + DAG Topological Invariant Guardrail',
            Icons.auto_awesome,
            AppTheme.primaryBlue,
          ),
          const SizedBox(height: 8),
          _buildDataFlowStep(
            '3. Retention',
            'MathPaws Companion: Pet Health & Daily Streak Multipliers awarded upon prerequisite mastery',
            Icons.pets,
            const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }

  Widget _buildDataFlowStep(String phase, String text, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textPrimary),
              children: [
                TextSpan(text: '$phase: ', style: const TextStyle(fontWeight: FontWeight.w800)),
                TextSpan(text: text),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 4. CURRICULUM TOPICS SWITCHER (GRADE 10 VS GRADE 11)
  // =========================================================================
  Widget _buildCurriculumTopicsSection({required bool isG10, required String goalType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Curriculum Tracks (Grade 10 & 11)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.learningGoal).then((_) => _fetchDashboardState()),
              child: const Text('Change Goal / Time'),
            ),
          ],
        ),
        const SizedBox(height: 10),

        _buildTopicCard(
          title: 'Indices & Logarithms',
          grade: 'Grade 11 G.C.E. (O/L)',
          conceptsCount: 7,
          badge: isG10 ? 'Available in G11' : 'Active Prerequisite DAG',
          badgeColor: AppTheme.primaryBlue,
          icon: Icons.functions,
          isHighlighted: !isG10,
          onTap: () async {
            await _service.createPlan(
              studentId: LearningPathService.demoStudentId,
              topicCategory: "Indices and Logarithms",
              gradeLevel: 11,
              goalType: goalType,
            );
            if (mounted) {
              Navigator.pushNamed(context, AppRouter.learningPath).then((_) => _fetchDashboardState());
            }
          },
        ),
        const SizedBox(height: 10),

        _buildTopicCard(
          title: 'Quadratic Equations',
          grade: 'Grade 10 Foundational Algebra',
          conceptsCount: 4,
          badge: isG10 ? 'Active Prerequisite DAG' : 'Available in G10',
          badgeColor: AppTheme.accentTeal,
          icon: Icons.linear_scale,
          isHighlighted: isG10,
          onTap: () async {
            await _service.createPlan(
              studentId: LearningPathService.demoStudentId,
              topicCategory: "Quadratic Equations",
              gradeLevel: 10,
              goalType: goalType,
            );
            if (mounted) {
              Navigator.pushNamed(context, AppRouter.learningPath).then((_) => _fetchDashboardState());
            }
          },
        ),
      ],
    );
  }

  Widget _buildTopicCard({
    required String title,
    required String grade,
    required int conceptsCount,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted ? AppTheme.primaryBlue : AppTheme.borderLight,
            width: isHighlighted ? 1.8 : 1.0,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isHighlighted ? AppTheme.primaryLight : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isHighlighted ? AppTheme.primaryBlue : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '$grade • $conceptsCount Concepts',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 5. DIAGNOSTIC QUICK CALIBRATION CARD
  // =========================================================================
  Widget _buildDiagnosticQuickCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.quiz_rounded, color: AppTheme.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diagnostic Calibration Quiz',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Calibrate readiness & trigger path adaptation.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.diagnostic).then((_) => _fetchDashboardState()),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(68, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Start', style: TextStyle(fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // MODALS FOR QUICK PREVIEW
  // =========================================================================
  void _showMasteryModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Cognitive Profiling',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: const Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Multi-Modal & Time-Aware Knowledge Tracing',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Text(
                'Continuous Concept Mastery & Retention Tracking',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildModalMetricRow('Concept Mastery Vector P(Kc)', '74.2% (Grade 10-11)', Icons.check_circle_outline, AppTheme.successGreen),
                    const Divider(height: 16),
                    _buildModalMetricRow('Ebbinghaus Retention Index', '88.4% (Decay S = 14 Days)', Icons.timelapse, const Color(0xFF7C3AED)),
                    const Divider(height: 16),
                    _buildModalMetricRow('Response Latency Profile', 'Mean: 28.4s (Log-Normal)', Icons.speed, Colors.blue),
                    const Divider(height: 16),
                    _buildModalMetricRow('Guess / Slip Estimate', 'P(Guess)=0.12 • P(Slip)=0.08', Icons.psychology, Colors.orange),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '🔗 Integration Note: This mastery vector P(Kc) feeds directly into the Adaptive Pathway Engine to calculate prerequisite readiness and optimize learning sequences.',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRouter.learnerProfiling);
                      },
                      child: const Text('Full Module'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCompanionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Learning Companion',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Adaptive Engagement & Gamification',
                style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              Text(
                'MathPaws Virtual Companion & Retention Ecosystem',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildModalMetricRow('MathPaws Virtual Pet', 'Level 2 • Health: 95/100 💚', Icons.pets, const Color(0xFF0D9488)),
                    const Divider(height: 16),
                    _buildModalMetricRow('Meaningful Daily Streak', '4 Days Active 🔥 (Milestone)', Icons.local_fire_department, Colors.orange),
                    const Divider(height: 16),
                    _buildModalMetricRow('Gamification XP Points', '240 XP (Prerequisite Unlocks)', Icons.stars_rounded, Colors.amber),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '🔗 Integration Note: Virtual-pet health and streaks only progress when the student completes prerequisite learning units verified by the Pathway Engine.',
                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRouter.gamification);
                      },
                      child: const Text('Full Module'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalMetricRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary)),
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
