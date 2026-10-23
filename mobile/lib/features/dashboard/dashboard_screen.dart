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
  bool _isLoading = true;

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
        _isLoading = false;
      });
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) return; // already on dashboard
    setState(() => _currentNavIndex = index);

    if (index == 1) {
      Navigator.pushNamed(context, AppRouter.learningPath).then((_) => _fetchDashboardState());
    } else if (index == 2) {
      Navigator.pushNamed(context, AppRouter.diagnostic).then((_) => _fetchDashboardState());
    } else if (index == 3) {
      Navigator.pushNamed(context, AppRouter.telemetry);
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
              child: const Icon(Icons.calculate, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Learning Hub',
                  style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                Text(
                  'Grade 11 Mathematics • Rural LK',
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
          const SizedBox(width: 8),

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
              // 1. Hero AI Learning Path Card (Aqeel's Component 1)
              _buildHeroLearningPathCard(
                goalType: goalType,
                recTitle: recTitle,
                recType: recType,
                recRationale: recRationale,
                conceptId: recConceptId,
                readinessScore: readinessScore,
              ),
              const SizedBox(height: 18),

              // 2. AI Learner Mastery & Knowledge Tracing Card (Jayasinghe's Component 2)
              _buildLearnerMasteryCard(),
              const SizedBox(height: 18),

              // 2. Virtual Pet & Engagement Card (Component 3)
              _buildVirtualPetCard(),
              const SizedBox(height: 24),

              // 3. Featured Topics Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Curriculum Topics',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRouter.topics),
                    child: const Text('View All (3)'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildTopicCard(
                title: 'Indices & Logarithms',
                grade: 'Grade 11',
                conceptsCount: 7,
                badge: 'AI Prerequisite DAG Active',
                badgeColor: AppTheme.primaryBlue,
                icon: Icons.functions,
                isHighlighted: true,
                onTap: () => Navigator.pushNamed(context, AppRouter.learningPath),
              ),
              const SizedBox(height: 12),

              _buildTopicCard(
                title: 'Quadratic Equations',
                grade: 'Grade 10',
                conceptsCount: 4,
                badge: 'Error Diagnosis Enabled',
                badgeColor: AppTheme.accentTeal,
                icon: Icons.linear_scale,
                isHighlighted: false,
                onTap: () => Navigator.pushNamed(context, AppRouter.concept),
              ),
              const SizedBox(height: 12),

              _buildTopicCard(
                title: 'Perimeter and Area of Plane Figures',
                grade: 'Grade 10',
                conceptsCount: 3,
                badge: 'Multi-Modal Geometry',
                badgeColor: AppTheme.successGreen,
                icon: Icons.crop_square,
                isHighlighted: false,
                onTap: () => Navigator.pushNamed(context, AppRouter.topics),
              ),
              const SizedBox(height: 24),

              // 4. Diagnostic Assessment Quick Card
              _buildDiagnosticQuickCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavIndex,
        onDestinationSelected: _onBottomNavTapped,
        backgroundColor: Colors.white,
        elevation: 6,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.alt_route_outlined),
            selectedIcon: Icon(Icons.alt_route),
            label: 'AI Path',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Diagnostic',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Telemetry',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroLearningPathCard({
    required String goalType,
    required String recTitle,
    required String recType,
    required String recRationale,
    required String conceptId,
    required double readinessScore,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppTheme.accentTeal, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'AI Learning Path Engine (Aqeel)',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: goalType == 'TERM_TEST' ? AppTheme.warningAmber : AppTheme.accentTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  goalType == 'TERM_TEST' ? '⚡ Term-Test Blitz' : '🎓 Comprehensive',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended Next Action:',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recRationale,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Readiness Gauge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentTeal, width: 2.5),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(readinessScore * 100).toInt()}%',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Readiness',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.lessonUnit,
                      arguments: conceptId,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.darkSlate,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.play_circle_fill, color: AppTheme.primaryBlue, size: 20),
                  label: Text(
                    'Continue Lesson Unit',
                    style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.learningPath);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  minimumSize: const Size(90, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Full DAG',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearnerMasteryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 14,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology, color: AppTheme.primaryBlue, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'AI Knowledge Tracing & Learner Profiling',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.successBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, color: AppTheme.successGreen, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'AUC 0.9722',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.successGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.model_training, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Concept Mastery: 74%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'BKT Engine with Ebbinghaus Memory Decay & Hesitation Multi-modal Weights',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMiniMetricChip('Decay Model', 'R = e^(-Δt/S)', Colors.indigo),
              const SizedBox(width: 8),
              _buildMiniMetricChip('Inference', '12.4 ms', Colors.teal),
              const SizedBox(width: 8),
              _buildMiniMetricChip('Pilot Logs', '800 Items', Colors.purple),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRouter.learnerProfile),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
              icon: const Icon(Icons.insights, size: 18),
              label: Text(
                'View Real-Time Mastery & Trained Model Specs',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetricChip(String label, String value, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.shade200),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                color: color.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: color.shade900,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVirtualPetCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.pets, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MathPaws (Level 2)',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Health: 95/100 💚',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.95,
                    minHeight: 6,
                    backgroundColor: Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Daily Streak: 4 Days 🔥 • 240 Gamification XP',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
                    color: AppTheme.primaryBlue.withOpacity(0.08),
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
                          color: badgeColor.withOpacity(0.12),
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

  Widget _buildDiagnosticQuickCard() {
    return Container(
      padding: const EdgeInsets.all(18),
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
                  'Diagnostic Calibration',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Test readiness & recalibrate your ML pathway.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.diagnostic),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(70, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Start', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
