import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'services/multiplayer_service.dart';
import 'student/student_setup_screen.dart';
import 'student/student_lobby_screen.dart';
import 'student/student_match_screen.dart';
import 'teacher/teacher_setup_screen.dart';

class MultiplayerHubScreen extends StatefulWidget {
  const MultiplayerHubScreen({super.key});

  @override
  State<MultiplayerHubScreen> createState() => _MultiplayerHubScreenState();
}

class _MultiplayerHubScreenState extends State<MultiplayerHubScreen> {
  final MultiplayerService _service = MultiplayerService();
  bool _isJoining = false;

  void _showEnterRoomDialog() {
    final pinController = TextEditingController();
    final nameController = TextEditingController(text: 'Dharmasena K.');
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.meeting_room_rounded, color: AppTheme.primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enter Room',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Join Student Peer Match or Teacher Classroom',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Display Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Player Name',
                      labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13),
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // PIN Input
                  TextField(
                    controller: pinController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.firaCode(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 14,
                      color: AppTheme.primaryBlue,
                    ),
                    decoration: InputDecoration(
                      hintText: '0000',
                      counterText: '',
                      helperText: 'Enter 4-digit room PIN from student or teacher host',
                      helperStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),

                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.errorRed,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _isJoining
                        ? null
                        : () async {
                            final pin = pinController.text.trim();
                            final name = nameController.text.trim().isEmpty ? 'Student Player' : nameController.text.trim();

                            if (pin.length != 4) {
                              setModalState(() {
                                errorMessage = 'Please enter a valid 4-digit PIN';
                              });
                              return;
                            }

                            setModalState(() {
                              _isJoining = true;
                              errorMessage = null;
                            });

                            final nav = Navigator.of(context);
                            try {
                              final room = await _service.joinRoom(
                                pin: pin,
                                playerName: name,
                              );

                              // Find player ID
                              final myP = room.players.firstWhere(
                                (p) => p.name == name,
                                orElse: () => room.players.last,
                              );

                              nav.pop(); // close bottom sheet

                              if (!mounted) return;

                              if (room.status == 'IN_PROGRESS') {
                                Navigator.of(this.context).push(
                                  MaterialPageRoute(
                                    builder: (_) => StudentMatchScreen(
                                      room: room,
                                      currentPlayerId: myP.playerId,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(this.context).push(
                                  MaterialPageRoute(
                                    builder: (_) => StudentLobbyScreen(
                                      initialRoom: room,
                                      currentPlayerId: myP.playerId,
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() {
                                _isJoining = false;
                                errorMessage = 'Room not found or match is full. Check PIN: $pin';
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isJoining
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Enter Room',
                            style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Multiplayer Quiz',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Enter Room',
            icon: const Icon(Icons.pin_outlined),
            onPressed: _showEnterRoomDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Hero Header
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF3730A3), Color(0xFF4338CA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3730A3).withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.warningAmber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '⚡ COMPONENT 3 GAMIFICATION',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.bolt, color: AppTheme.warningAmber, size: 22),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Multiplayer Quiz\nLive Arena',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compete synchronously in peer lobbies or host live classroom quizzes with AI cognitive load tracking.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Option 1: Start as Student
            _buildRoleCard(
              title: 'Start as Student',
              badge: '2–5 PEER MATCH',
              badgeColor: AppTheme.accentTeal,
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              icon: Icons.sports_esports_rounded,
              description: 'Challenge your classmates to a synchronized 3, 5, or 10 question blitz with real-time mini-leaderboards and XP rewards.',
              steps: [
                'Step 1: Pick Module/Topic & Question Count',
                'Step 2: Peer Lobby (4-digit PIN, 2–5 players)',
                'Step 3: Fast-paced Synchronized Gameplay',
                'Step 4: Round Results (XP & Rematch)',
              ],
              buttonLabel: 'Start as Student',
              buttonIcon: Icons.arrow_forward_rounded,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StudentSetupScreen()),
                );
              },
            ),
            const SizedBox(height: 18),

            // Option 2: Start as Teacher
            _buildRoleCard(
              title: 'Start as Teacher',
              badge: 'UP TO 50 STUDENTS',
              badgeColor: const Color(0xFFF59E0B),
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              icon: Icons.school_rounded,
              description: 'Create AI auto-generated quizzes or upload CSVs. Control the live classroom pace and view ML frustration summaries.',
              steps: [
                'Step 1: Select Quiz Source (AI Auto-Gen / CSV)',
                'Step 2: Configure Game Settings (30s, ML toggle)',
                'Step 3: Teacher Lobby (PIN, QR code, 50 cap)',
                'Step 4: Host Live Control (Countdown & Next)',
                'Step 5: Classroom Analytics (Podium & ML Summary)',
              ],
              buttonLabel: 'Start as Teacher',
              buttonIcon: Icons.assessment_outlined,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TeacherSetupScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            // Enter Room Section Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderLight, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.key_rounded, color: AppTheme.primaryBlue, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Have a 4-Digit Game PIN?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Enter a room created by a peer or your teacher',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _showEnterRoomDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.meeting_room, color: Colors.white, size: 20),
                    label: Text(
                      'Enter Room',
                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
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

  Widget _buildRoleCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required LinearGradient gradient,
    required IconData icon,
    required String description,
    required List<String> steps,
    required String buttonLabel,
    required IconData buttonIcon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.45,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),

                // Step list
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: steps
                        .map(
                          (s) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.primaryBlue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 18),

                ElevatedButton.icon(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(buttonIcon, size: 18, color: Colors.white),
                  label: Text(
                    buttonLabel,
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
