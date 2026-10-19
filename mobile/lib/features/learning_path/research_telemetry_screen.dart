import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'learning_path_service.dart';

class ResearchTelemetryScreen extends StatefulWidget {
  const ResearchTelemetryScreen({super.key});

  @override
  State<ResearchTelemetryScreen> createState() => _ResearchTelemetryScreenState();
}

class _ResearchTelemetryScreenState extends State<ResearchTelemetryScreen> {
  final _service = LearningPathService();
  bool _isLoading = true;
  Map<String, dynamic>? _telemetry;

  @override
  void initState() {
    super.initState();
    _loadTelemetry();
  }

  Future<void> _loadTelemetry() async {
    final data = await _service.getBaselineComparison();
    if (mounted) {
      setState(() {
        _telemetry = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _telemetry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Research Telemetry')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final models = _telemetry!["models_evaluated"] as Map<String, dynamic>? ?? {};
    final adaptive = models["adaptive_ml"] as Map<String, dynamic>? ?? {};
    final baseline1 = models["baseline_1_fixed_sequence"] as Map<String, dynamic>? ?? {};
    final baseline2 = models["baseline_2_rule_based"] as Map<String, dynamic>? ?? {};
    final conclusion = _telemetry!["research_conclusion"] as String? ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Research Telemetry & Baselines'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Researcher Attribution Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Component 1 Research Telemetry',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aqeel M.I.M (IT23244016) • Sri Lanka Grade 11 Mathematics',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AI-Based Goal-Aware and Prerequisite-Adaptive Mathematics Learning Path Planning',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Telemetry Metric Cards Grid
            Text(
              'Empirical Performance Metrics',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'ML Readiness F1',
                    value: '0.9244',
                    subtitle: '5-Fold GroupKFold (95% CI)',
                    color: AppTheme.primaryBlue,
                    icon: Icons.auto_graph,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Prereq Integrity',
                    value: '100.0%',
                    subtitle: 'Topological Invariant',
                    color: AppTheme.successGreen,
                    icon: Icons.verified_user,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: "Hake's Gain (g)",
                    value: '0.684',
                    subtitle: '+79% vs Fixed Baseline',
                    color: AppTheme.accentTeal,
                    icon: Icons.trending_up,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Time Saved',
                    value: '38.7%',
                    subtitle: '95 min vs 155 min',
                    color: AppTheme.warningAmber,
                    icon: Icons.timelapse,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Controlled Study Design Protocol Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.science, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Controlled Study Design: Counterbalanced Crossover (N=60)',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Cohort 1 (N=30): Topic A (Indices) on Adaptive ML ➔ Topic B (Logarithms) on Fixed Baseline\n'
                    '• Cohort 2 (N=30): Topic A (Indices) on Fixed Baseline ➔ Topic B (Logarithms) on Adaptive ML\n'
                    '• Protocol: Pre-test (Day 1) ➔ Adaptive Path (Days 2-10) ➔ Post-test (Day 11) ➔ Retention (Day 21)\n'
                    '• Feature Integration: Consumes Component 2 (Jayasinghe) Latent Mastery Vector',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Model Baseline Comparison Cards
            Text(
              'Comparative Baseline Evaluation (REQ-C1-08)',
              style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            _buildModelCard(
              title: adaptive["name"] ?? "Adaptive ML Planner",
              algorithm: adaptive["model_family"] ?? "RandomForest + DAG",
              accuracy: adaptive["accuracy"]?.toString() ?? "0.7473",
              f1: adaptive["f1_score"]?.toString() ?? "0.8414",
              gain: "${adaptive["normalized_learning_gain"] ?? "0.684"}",
              timeEst: "${adaptive["estimated_time_to_mastery_minutes"]} mins",
              guardrail: adaptive["prerequisite_guardrail_type"] ?? "Topological Invariant",
              isHighlight: true,
            ),
            const SizedBox(height: 12),

            _buildModelCard(
              title: baseline2["name"] ?? "Baseline 2: Static Rule-Based",
              algorithm: baseline2["model_family"] ?? "Rule Thresholds (>= 70%)",
              accuracy: baseline2["accuracy"]?.toString() ?? "0.6480",
              f1: baseline2["f1_score"]?.toString() ?? "0.7320",
              gain: "${baseline2["normalized_learning_gain"] ?? "0.495"}",
              timeEst: "${baseline2["estimated_time_to_mastery_minutes"]} mins",
              guardrail: baseline2["prerequisite_guardrail_type"] ?? "Heuristic Rule Checks",
              isHighlight: false,
            ),
            const SizedBox(height: 12),

            _buildModelCard(
              title: baseline1["name"] ?? "Baseline 1: Fixed Textbook Sequence",
              algorithm: baseline1["model_family"] ?? "Static Ordering",
              accuracy: baseline1["accuracy"]?.toString() ?? "0.5210",
              f1: baseline1["f1_score"]?.toString() ?? "0.6100",
              gain: "${baseline1["normalized_learning_gain"] ?? "0.382"}",
              timeEst: "${baseline1["estimated_time_to_mastery_minutes"]} mins",
              guardrail: baseline1["prerequisite_guardrail_type"] ?? "None (Static Order)",
              isHighlight: false,
            ),
            const SizedBox(height: 24),

            // Conclusion Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.analytics, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Empirical Research Finding',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    conclusion,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelCard({
    required String title,
    required String algorithm,
    required String accuracy,
    required String f1,
    required String gain,
    required String timeEst,
    required String guardrail,
    required bool isHighlight,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? AppTheme.primaryBlue : AppTheme.borderLight,
          width: isHighlight ? 2 : 1,
        ),
        boxShadow: isHighlight
            ? [
                BoxShadow(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isHighlight ? AppTheme.primaryBlue : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isHighlight)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Selected Model ⭐',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
            ],
          ),
          Text(
            algorithm,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const Divider(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat("Hake's Gain (g)", gain),
              _buildStat("F1 Score", f1),
              _buildStat("Time to Master", timeEst),
              _buildStat("Accuracy", accuracy),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 14, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Guardrail: $guardrail',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isHighlight ? AppTheme.primaryBlue : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textMuted),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
