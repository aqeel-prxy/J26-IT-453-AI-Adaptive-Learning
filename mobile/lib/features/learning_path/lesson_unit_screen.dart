import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import 'learning_path_service.dart';

class LessonUnitScreen extends StatefulWidget {
  final String conceptId;
  final String? goalType;
  final int? gradeLevel;

  const LessonUnitScreen({
    super.key,
    required this.conceptId,
    this.goalType,
    this.gradeLevel,
  });

  @override
  State<LessonUnitScreen> createState() => _LessonUnitScreenState();
}

class _LessonUnitScreenState extends State<LessonUnitScreen> with SingleTickerProviderStateMixin {
  final _service = LearningPathService();
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _lesson;

  // Quiz state
  int? _selectedQuizIndex;
  bool _quizSubmitted = false;
  bool _isSubmitting = false;
  DateTime _startTime = DateTime.now();

  // Guided Practice hint state
  bool _showHint = false;

  late String _activeGoalType;

  @override
  void initState() {
    super.initState();
    _activeGoalType = widget.goalType ?? "TERM_TEST";
    _tabController = TabController(length: 4, vsync: this);
    _loadLesson();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchGoal(String newGoal) {
    if (_activeGoalType == newGoal) return;
    setState(() {
      _activeGoalType = newGoal;
    });
    _loadLesson();
  }

  Future<void> _loadLesson() async {
    setState(() => _isLoading = true);
    final data = await _service.getLesson(
      widget.conceptId,
      goalType: _activeGoalType,
      gradeLevel: widget.gradeLevel ?? 11,
    );
    if (mounted) {
      setState(() {
        _lesson = data;
        _isLoading = false;
        _startTime = DateTime.now();
      });
    }
  }

  void _onQuizSubmit() async {
    if (_selectedQuizIndex == null || _quizSubmitted) return;

    final quiz = _lesson!["quiz"] as Map<String, dynamic>? ?? {};
    final correctIdx = quiz["correct_index"] as int? ?? 0;
    final isCorrect = _selectedQuizIndex == correctIdx;
    final elapsedSecs = DateTime.now().difference(_startTime).inSeconds;

    setState(() {
      _isSubmitting = true;
      _quizSubmitted = true;
    });

    // Call dynamic pathway revision API (REQ-C1-07)
    final revision = await _service.completeActivity(
      studentId: LearningPathService.demoStudentId,
      conceptId: widget.conceptId,
      activityType: "QUIZ",
      isSuccessful: isCorrect,
      score: isCorrect ? 1.0 : 0.4,
      durationSeconds: elapsedSecs,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    _showRevisionSuccessModal(isCorrect, revision);
  }

  void _showRevisionSuccessModal(bool isCorrect, Map<String, dynamic> revision) {
    final nextRec = revision["next_recommended_activity"] as Map<String, dynamic>? ?? {};
    final nextTitle = nextRec["concept_title"] as String? ?? "Next Concept";
    final rationale = nextRec["rationale"] as String? ?? "Pathway dynamically updated.";

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect ? AppTheme.successBg : AppTheme.warningBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCorrect ? Icons.check_circle : Icons.warning_amber_rounded,
                color: isCorrect ? AppTheme.successGreen : AppTheme.warningAmber,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCorrect ? 'Concept Mastered!' : 'Reinforcement Scheduled',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Next Step: $nextTitle 🔄',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),

            const SizedBox(height: 14),
            Text(
              rationale,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, AppRouter.learningPath);
              },
              child: const Text('Return to Learning Pathway'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lesson Unit')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final title = _lesson!["title"] as String? ?? "Curriculum Lesson";
    final code = _lesson!["code"] as String? ?? "";
    final textbook = _lesson!["textbook_ref"] as String? ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryBlue,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
          tabs: const [
            Tab(text: '📖 Theory & Formulas'),
            Tab(text: '💡 Worked Example'),
            Tab(text: '✍️ Guided Practice'),
            Tab(text: '🎯 Concept Quiz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTheoryTab(code, textbook),
          _buildWorkedExampleTab(),
          _buildGuidedPracticeTab(),
          _buildQuizTab(),
        ],
      ),
    );
  }

  Widget _buildTheoryTab(String code, String textbook) {
    final theory = _lesson!["theory"] as String? ?? "";
    final formulas = (_lesson!["formulas"] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final competency = _lesson!["curriculum_competency"] as String? ?? "";
    final descriptor = _lesson!["competency_descriptor"] as String? ?? "";
    final pedMode = _lesson!["pedagogical_mode"] as Map<String, dynamic>?;
    final prereqBridge = _lesson!["prerequisite_bridge"] as Map<String, dynamic>?;
    final analogy = _lesson!["conceptual_analogy"] as String?;
    final pitfall = _lesson!["exam_pitfall_warning"] as String?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 0. Interactive Pedagogical Goal Mode Switcher
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _switchGoal("TERM_TEST"),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeGoalType == "TERM_TEST" ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeGoalType == "TERM_TEST"
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flash_on, size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          Text(
                            'Term-Test Cramming',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _activeGoalType == "TERM_TEST"
                                  ? const Color(0xFFD97706)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _switchGoal("COMPREHENSIVE"),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _activeGoalType == "COMPREHENSIVE" ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: _activeGoalType == "COMPREHENSIVE"
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.psychology, size: 16, color: AppTheme.primaryBlue),
                          const SizedBox(width: 6),
                          Text(
                            'Comprehensive',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _activeGoalType == "COMPREHENSIVE"
                                  ? AppTheme.primaryBlue
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pedagogical Mode & Competency Banner
          if (pedMode != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _lesson!["goal_type"] == "TERM_TEST"
                      ? [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)]
                      : [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _lesson!["goal_type"] == "TERM_TEST"
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFBFDBFE),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _lesson!["goal_type"] == "TERM_TEST"
                          ? const Color(0xFFD97706)
                          : AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pedMode["badge"] ?? "⚡ Goal-Adaptive Mode",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      pedMode["focus"] ?? "",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Curriculum Code & NIE Descriptor Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  code,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              if (competency.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Text(
                    competency,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  textbook,
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (descriptor.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              descriptor,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),

          // Prerequisite Bridge Card
          if (prereqBridge != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hub_outlined, color: AppTheme.primaryBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Prerequisite Bridge (Linking Prior Knowledge)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Text(
                          prereqBridge["source_concept"] ?? "Foundational Concept",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward, size: 14, color: AppTheme.textSecondary),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          prereqBridge["target_concept"] ?? "Target Lesson",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    prereqBridge["explanation"] ?? "",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: const Color(0xFF334155),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          Text(
            'Conceptual Theory',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Text(
              theory,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Conceptual Analogy Card
          if (analogy != null && analogy.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE047)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, color: Color(0xFFCA8A04), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Intuitive Analogy',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF854D0E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          analogy,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF713F12),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Exam Pitfall Alert Card
          if (pitfall != null && pitfall.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'O/L Exam Trap Warning',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF9F1239),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pitfall,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: const Color(0xFF881337),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          Text(
            'Authoritative Laws & Formulas',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          ...formulas.map((f) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.functions, color: AppTheme.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f["name"] ?? "",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          f["rule"] ?? "",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWorkedExampleTab() {
    final worked = _lesson!["worked_example"] as Map<String, dynamic>? ?? {};
    final problem = worked["problem"] as String? ?? "";
    final goalFocus = worked["goal_focus"] as String? ?? "";
    final steps = (worked["steps"] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final finalAnswer = worked["final_answer"] as String? ?? "";
    final verification = worked["verification_check"] as String? ?? "";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.successGreen, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Worked Example Problem',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    if (goalFocus.isNotEmpty) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(
                          goalFocus,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  problem,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Step-by-Step Pedagogical Working:',
            style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          ...steps.map((st) {
            final num = st["step_number"] ?? 1;
            final desc = st["action"] ?? st["description"] ?? "";
            final working = st["working"] ?? "";
            final rationale = st["pedagogical_rationale"] as String?;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.primaryLight,
                        child: Text(
                          '$num',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          desc,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Text(
                      working,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                  if (rationale != null && rationale.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.psychology, size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Pedagogical Rationale: ',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF92400E),
                                    ),
                                  ),
                                  TextSpan(
                                    text: rationale,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      color: const Color(0xFF78350F),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, color: AppTheme.primaryBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Final Simplified Result',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                      Text(
                        finalAnswer,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (verification.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified, size: 20, color: Color(0xFF16A34A)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Curriculum Verification Check',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          verification,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: const Color(0xFF166534),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuidedPracticeTab() {
    final practice = _lesson!["guided_practice"] as Map<String, dynamic>? ?? {};
    final problem = practice["problem"] as String? ?? "";
    final hint = practice["hint"] as String? ?? "";
    final solution = practice["solution"] as String? ?? "";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Guided Practice Problem',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Try solving this independently before revealing hints or checking the quiz.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Text(
              problem,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: () => setState(() => _showHint = !_showHint),
            icon: Icon(_showHint ? Icons.visibility_off : Icons.lightbulb, size: 18),
            label: Text(_showHint ? 'Hide Pedagogical Hint' : 'Show Pedagogical Hint'),
          ),

          if (_showHint) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.warningBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.help_outline, color: AppTheme.warningAmber, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Hint:',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.warningAmber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hint,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.black87),
                  ),
                  const Divider(height: 20),
                  Text(
                    'Step Solution: $solution',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: () => _tabController.animateTo(3),
            child: const Text('Proceed to Quick Quiz Check'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizTab() {
    final quiz = _lesson!["quiz"] as Map<String, dynamic>? ?? {};
    final question = quiz["question"] as String? ?? "Check your understanding:";
    final options = (quiz["options"] as List?)?.cast<String>() ?? [];
    final correctIdx = quiz["correct_index"] as int? ?? 0;
    final explanation = quiz["explanation"] as String? ?? "";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Dynamic Revision Check 🎯',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(options.length, (idx) {
            final opt = options[idx];
            final isSelected = _selectedQuizIndex == idx;
            final isCorrect = idx == correctIdx;

            Color borderColor = AppTheme.borderLight;
            Color bgColor = Colors.white;

            if (_quizSubmitted) {
              if (isCorrect) {
                borderColor = AppTheme.successGreen;
                bgColor = AppTheme.successBg;
              } else if (isSelected) {
                borderColor = AppTheme.errorRed;
                bgColor = AppTheme.errorBg;
              }
            } else if (isSelected) {
              borderColor = AppTheme.primaryBlue;
              bgColor = AppTheme.primaryLight;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: _quizSubmitted ? null : () => setState(() => _selectedQuizIndex = idx),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isSelected ? AppTheme.primaryBlue : const Color(0xFFF1F5F9),
                        child: Text(
                          String.fromCharCode(65 + idx),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          opt,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          if (!_quizSubmitted)
            ElevatedButton(
              onPressed: _selectedQuizIndex != null && !_isSubmitting ? _onQuizSubmit : null,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Submit Quiz to Dynamic Pathway Revision'),
            ),

          if (_quizSubmitted) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedagogical Rationale:',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    explanation,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRouter.learningPath);
              },
              child: const Text('Back to Pathway Roadmap'),
            ),
          ],
        ],
      ),
    );
  }
}
