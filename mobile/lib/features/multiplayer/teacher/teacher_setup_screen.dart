import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/multiplayer_models.dart';
import '../services/multiplayer_service.dart';
import 'teacher_lobby_screen.dart';

class TeacherSetupScreen extends StatefulWidget {
  const TeacherSetupScreen({super.key});

  @override
  State<TeacherSetupScreen> createState() => _TeacherSetupScreenState();
}

class _TeacherSetupScreenState extends State<TeacherSetupScreen> {
  final MultiplayerService _service = MultiplayerService();

  // Step 1: Quiz Source
  String _quizSource = 'AUTO_GENERATE'; // 'AUTO_GENERATE' or 'CUSTOM_UPLOAD'
  String _selectedSubject = 'Mathematics';
  int _selectedGrade = 10;
  String _selectedTopic = 'Quadratic Equations';
  int _questionCount = 5;

  // Custom / CSV text controller
  final _csvController = TextEditingController(
    text: "Solve: 2x + 6 = 14, 2, 4, 6, 8, 1, 2x = 8 so x = 4\n"
        "Simplify: 3² × 3³, 3⁵, 3⁶, 9⁵, 27, 0, Product rule adds powers\n"
        "Factorize: x² - 9, (x-3)(x+3), (x-9)(x+1), (x-3)², x(x-9), 0, Difference of two squares",
  );

  // Step 2: Game Settings
  int _timePerQuestion = 30;
  bool _mlInsightsEnabled = true;
  bool _isLoading = false;

  late final TextEditingController _questionCountController;
  late final TextEditingController _timePerQuestionController;

  final List<String> _topics = [
    'Quadratic Equations',
    'Indices & Logarithms',
    'Perimeter & Area of Plane Figures',
    'Linear Equations',
  ];

  @override
  void initState() {
    super.initState();
    _questionCountController = TextEditingController(text: '$_questionCount');
    _timePerQuestionController = TextEditingController(text: '$_timePerQuestion');
  }

  @override
  void dispose() {
    _questionCountController.dispose();
    _timePerQuestionController.dispose();
    _csvController.dispose();
    super.dispose();
  }

  Future<void> _launchTeacherLobby() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final enteredCount = int.tryParse(_questionCountController.text.trim()) ?? _questionCount;
    final enteredTime = int.tryParse(_timePerQuestionController.text.trim()) ?? _timePerQuestion;

    if (_quizSource == 'AUTO_GENERATE' && enteredCount < 1) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter at least 1 question.'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    if (enteredTime < 5) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please enter at least 5 seconds per question.'), backgroundColor: AppTheme.errorRed),
      );
      return;
    }

    setState(() {
      _questionCount = enteredCount;
      _timePerQuestion = enteredTime;
      _isLoading = true;
    });

    try {
      List<QuizQuestion>? customQuestions;
      if (_quizSource == 'CUSTOM_UPLOAD') {
        customQuestions = _parseCsvLocal(_csvController.text.trim());
      }

      final room = await _service.createRoom(
        roomType: 'TEACHER_CLASSROOM',
        hostId: 'teacher_host_01',
        hostName: 'Mr. Perera (Teacher)',
        hostAvatar: 'owl_scholar',
        topic: _selectedTopic,
        gradeLevel: _selectedGrade,
        questionCount: _questionCount,
        timePerQuestion: _timePerQuestion,
        mlInsightsEnabled: _mlInsightsEnabled,
        quizSource: _quizSource,
        customQuestions: customQuestions,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        nav.push(
          MaterialPageRoute(
            builder: (_) => TeacherLobbyScreen(initialRoom: room),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to launch classroom: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  List<QuizQuestion> _parseCsvLocal(String text) {
    final lines = text.split('\n');
    final List<QuizQuestion> questions = [];
    for (int i = 0; i < lines.length; i++) {
      final parts = lines[i].split(',').map((p) => p.trim()).toList();
      if (parts.length >= 6) {
        questions.add(QuizQuestion(
          questionId: 'custom_$i',
          questionText: parts[0],
          options: [parts[1], parts[2], parts[3], parts[4]],
          correctIndex: int.tryParse(parts[5]) ?? 0,
          explanation: parts.length > 6 ? parts[6] : '',
          topic: _selectedTopic,
          difficulty: 'Custom',
        ));
      }
    }
    return questions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Start as Teacher • Setup',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentTeal.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.school, color: AppTheme.accentTeal, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Classroom Host Controller',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Host up to 50 students with live telemetry & ML insights.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step 1: Select Quiz Source
            Text(
              'Step 1: Select Quiz Source',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _quizSource = 'AUTO_GENERATE'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _quizSource == 'AUTO_GENERATE' ? AppTheme.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _quizSource == 'AUTO_GENERATE' ? AppTheme.primaryBlue : AppTheme.borderLight,
                          width: _quizSource == 'AUTO_GENERATE' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: _quizSource == 'AUTO_GENERATE' ? AppTheme.primaryBlue : AppTheme.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Auto-Generate',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _quizSource == 'AUTO_GENERATE' ? AppTheme.primaryBlue : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'From Curriculum Bank',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _quizSource = 'CUSTOM_UPLOAD'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _quizSource == 'CUSTOM_UPLOAD' ? AppTheme.primaryLight : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _quizSource == 'CUSTOM_UPLOAD' ? AppTheme.primaryBlue : AppTheme.borderLight,
                          width: _quizSource == 'CUSTOM_UPLOAD' ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.upload_file,
                            color: _quizSource == 'CUSTOM_UPLOAD' ? AppTheme.primaryBlue : AppTheme.textSecondary,
                            size: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Custom / Upload',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _quizSource == 'CUSTOM_UPLOAD' ? AppTheme.primaryBlue : AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Upload CSV or Custom',
                            style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_quizSource == 'AUTO_GENERATE') ...[
              // Subject & Grade Selector
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Subject', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: _selectedSubject,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                          items: const [DropdownMenuItem(value: 'Mathematics', child: Text('Mathematics'))],
                          onChanged: (v) => setState(() => _selectedSubject = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target Grade', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<int>(
                          value: _selectedGrade,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                          items: const [
                            DropdownMenuItem(value: 10, child: Text('Grade 10')),
                            DropdownMenuItem(value: 11, child: Text('Grade 11')),
                          ],
                          onChanged: (v) => setState(() => _selectedGrade = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text('Curriculum Topic', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _selectedTopic,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                items: _topics.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedTopic = v!),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Number of Questions', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                  Text('Custom count', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary)),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _questionCountController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.format_list_numbered_rounded, color: AppTheme.primaryBlue, size: 20),
                  hintText: 'Enter question count (e.g. 5, 10, 15)',
                  suffixText: 'Questions',
                  suffixStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null && parsed > 0) {
                    setState(() => _questionCount = parsed);
                  }
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [5, 10, 15, 20].map((cnt) {
                  final isSel = _questionCount == cnt;
                  return ChoiceChip(
                    label: Text('$cnt Qs'),
                    selected: isSel,
                    selectedColor: AppTheme.primaryBlue.withOpacity(0.18),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                      color: isSel ? AppTheme.primaryBlue : AppTheme.textSecondary,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _questionCount = cnt;
                        _questionCountController.text = '$cnt';
                      });
                    },
                  );
                }).toList(),
              ),
            ] else ...[
              // Custom / CSV Upload
              Text(
                'Upload / Paste CSV Questions',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Format: Question, OptionA, OptionB, OptionC, OptionD, CorrectIndex (0-3), Explanation',
                style: GoogleFonts.firaCode(fontSize: 10.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _csvController,
                maxLines: 5,
                style: GoogleFonts.firaCode(fontSize: 11),
                decoration: const InputDecoration(
                  hintText: 'Enter comma-separated questions...',
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
            const SizedBox(height: 28),

            // Step 2: Configure Game Settings
            Text(
              'Step 2: Configure Game Settings',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Time per Question',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Custom seconds',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _timePerQuestionController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.timer_outlined, color: AppTheme.accentTeal, size: 20),
                          hintText: 'Enter seconds (e.g. 15, 30, 45, 60)',
                          suffixText: 'Seconds',
                          suffixStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed > 0) {
                            setState(() => _timePerQuestion = parsed);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [15, 30, 45, 60, 90].map((secs) {
                          final isSel = _timePerQuestion == secs;
                          return ChoiceChip(
                            label: Text('${secs}s'),
                            selected: isSel,
                            selectedColor: AppTheme.accentTeal.withOpacity(0.18),
                            labelStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                              color: isSel ? AppTheme.accentTeal : AppTheme.textSecondary,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _timePerQuestion = secs;
                                _timePerQuestionController.text = '$secs';
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Component 3 ML Insights',
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Track cognitive strain, hesitation, and frustration in real-time',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                    value: _mlInsightsEnabled,
                    activeColor: AppTheme.accentTeal,
                    onChanged: (v) => setState(() => _mlInsightsEnabled = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Launch Button (Step 3 Trigger)
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _launchTeacherLobby,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.rocket_launch, color: Colors.white),
              label: Text(
                _isLoading ? 'Launching Classroom...' : 'Open Teacher Lobby (Step 3)',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
