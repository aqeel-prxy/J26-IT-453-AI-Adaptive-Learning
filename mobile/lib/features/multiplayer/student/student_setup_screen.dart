import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/multiplayer_models.dart';
import '../services/multiplayer_service.dart';
import 'student_lobby_screen.dart';

class StudentSetupScreen extends StatefulWidget {
  const StudentSetupScreen({super.key});

  @override
  State<StudentSetupScreen> createState() => _StudentSetupScreenState();
}

class _StudentSetupScreenState extends State<StudentSetupScreen> {
  final MultiplayerService _service = MultiplayerService();

  String _selectedTopic = 'Quadratic Equations';
  int _questionCount = 5;
  int _timePerQuestion = 20;
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
    super.dispose();
  }

  Future<void> _createPeerLobby() async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final enteredCount = int.tryParse(_questionCountController.text.trim()) ?? _questionCount;
    final enteredTime = int.tryParse(_timePerQuestionController.text.trim()) ?? _timePerQuestion;

    if (enteredCount < 1) {
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
      final room = await _service.createRoom(
        roomType: 'STUDENT_PEER',
        hostId: 'student_me',
        hostName: 'Kavindu (You)',
        hostAvatar: 'fox_math',
        topic: _selectedTopic,
        questionCount: _questionCount,
        timePerQuestion: _timePerQuestion,
        mlInsightsEnabled: true,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        nav.push(
          MaterialPageRoute(
            builder: (_) => StudentLobbyScreen(
              initialRoom: room,
              currentPlayerId: 'student_me',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to create room: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Start as Student • Step 1',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.25),
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
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sports_esports, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peer Challenge Setup',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Compete in real-time with 2 to 5 classmates.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step 1: Pick a Module / Topic
            Text(
              'Select Module / Topic',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            ..._topics.map((topic) {
              final isSelected = _selectedTopic == topic;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => setState(() => _selectedTopic = topic),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textMuted,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            topic,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? AppTheme.primaryBlue : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Step 2: Question Count (Customizable User Entry + Quick Presets)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question Count',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Enter custom count',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Number of Questions Input Field
            TextFormField(
              controller: _questionCountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.format_list_numbered_rounded, color: AppTheme.primaryBlue, size: 20),
                hintText: 'Enter question count (e.g. 5, 8, 12)',
                suffixText: 'Questions',
                suffixStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.textSecondary, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null && parsed > 0) {
                  setState(() => _questionCount = parsed);
                }
              },
            ),
            const SizedBox(height: 10),

            // Quick Preset Selection Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [3, 5, 10, 15, 20].map((count) {
                final isSelected = _questionCount == count;
                return ChoiceChip(
                  label: Text('$count Qs'),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryBlue.withOpacity(0.16),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                  ),
                  onSelected: (_) {
                    setState(() {
                      _questionCount = count;
                      _questionCountController.text = '$count';
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Step 3: Speed Limit / Seconds per Question (Customizable User Entry + Presets)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Time Limit per Question',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Enter seconds',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Time Limit Input Field
            TextFormField(
              controller: _timePerQuestionController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.timer_outlined, color: AppTheme.accentTeal, size: 20),
                hintText: 'Enter seconds per question (e.g. 15, 20, 30)',
                suffixText: 'Seconds',
                suffixStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.textSecondary, fontSize: 13),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.accentTeal, width: 1.8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (val) {
                final parsed = int.tryParse(val);
                if (parsed != null && parsed > 0) {
                  setState(() => _timePerQuestion = parsed);
                }
              },
            ),
            const SizedBox(height: 10),

            // Quick Speed Preset Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [10, 15, 20, 30, 45, 60].map((secs) {
                final isSelected = _timePerQuestion == secs;
                return ChoiceChip(
                  label: Text('${secs}s'),
                  selected: isSelected,
                  selectedColor: AppTheme.accentTeal.withOpacity(0.18),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppTheme.accentTeal : AppTheme.textSecondary,
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
            const SizedBox(height: 36),

            // Create Peer Lobby Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createPeerLobby,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.meeting_room, color: Colors.white),
              label: Text(
                _isLoading ? 'Creating Lobby...' : 'Create Peer Lobby (Step 2)',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
