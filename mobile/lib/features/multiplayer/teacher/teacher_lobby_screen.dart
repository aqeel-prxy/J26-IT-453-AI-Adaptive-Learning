import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/multiplayer_models.dart';
import '../services/multiplayer_service.dart';
import 'teacher_live_control_screen.dart';

class TeacherLobbyScreen extends StatefulWidget {
  final MultiplayerRoom initialRoom;

  const TeacherLobbyScreen({super.key, required this.initialRoom});

  @override
  State<TeacherLobbyScreen> createState() => _TeacherLobbyScreenState();
}

class _TeacherLobbyScreenState extends State<TeacherLobbyScreen> {
  final MultiplayerService _service = MultiplayerService();
  late MultiplayerRoom _room;
  Timer? _pollTimer;
  bool _isStarting = false;

  @override
  void initState() {
    super.initState();
    _room = widget.initialRoom;
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final updated = await _service.getRoom(_room.pin);
        if (mounted) setState(() => _room = updated);
      } catch (_) {}
    });
  }

  Future<void> _simulateAddStudents() async {
    for (int i = 0; i < 3; i++) {
      await _service.addBotPeer(_room.pin);
    }
    final updated = await _service.getRoom(_room.pin);
    if (mounted) {
      setState(() => _room = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simulated students joined the classroom!'),
          backgroundColor: AppTheme.successGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _startLiveQuiz() async {
    setState(() => _isStarting = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final updated = await _service.startGame(_room.pin);
      _pollTimer?.cancel();
      if (mounted) {
        nav.pushReplacement(
          MaterialPageRoute(
            builder: (_) => TeacherLiveControlScreen(room: updated),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isStarting = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Cannot start quiz: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentCount = _room.players.where((p) => !p.isHost).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Teacher Lobby • Step 3',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // PIN & QR Code Display Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'CLASSROOM SESSION CODE',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white70,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _room.pin,
                        style: GoogleFonts.firaCode(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentTeal,
                          letterSpacing: 10,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy PIN',
                        icon: const Icon(Icons.copy, color: Colors.white, size: 22),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _room.pin));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('PIN copied!'), backgroundColor: AppTheme.successGreen),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // QR Code Tile Graphic
                  Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_2, size: 88, color: AppTheme.darkSlate),
                          Text(
                            'Scan PIN: ${_room.pin}',
                            style: GoogleFonts.firaCode(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.darkSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Ask students to open Adaptive Learning and select "Enter Room"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Live Student Counter Header (Up to 50)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Live Student Roster',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$studentCount / 50 Joined',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _simulateAddStudents,
                  icon: const Icon(Icons.group_add, size: 16),
                  label: const Text('Simulate +3', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Joined Students List
            if (_room.players.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Center(
                  child: Text(
                    'No students have joined yet. Waiting for PIN entry...',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _room.players.length,
                itemBuilder: (context, index) {
                  final p = _room.players[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: p.isHost ? AppTheme.accentTeal.withOpacity(0.2) : AppTheme.primaryLight,
                          child: Icon(
                            p.isHost ? Icons.school : Icons.person,
                            size: 18,
                            color: p.isHost ? AppTheme.accentTeal : AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            p.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: p.isHost ? AppTheme.primaryLight : AppTheme.successBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            p.isHost ? 'Host' : 'Ready 🟢',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: p.isHost ? AppTheme.primaryBlue : AppTheme.successGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),

            // Start Live Control Button (Step 4 Trigger)
            ElevatedButton.icon(
              onPressed: _isStarting ? null : _startLiveQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: _isStarting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.play_circle_fill, color: Colors.white),
              label: Text(
                _isStarting ? 'Starting Quiz...' : 'Start Live Quiz (Step 4)',
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
