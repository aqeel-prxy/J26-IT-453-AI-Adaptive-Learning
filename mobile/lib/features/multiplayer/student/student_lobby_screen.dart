import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../models/multiplayer_models.dart';
import '../services/multiplayer_service.dart';
import 'student_match_screen.dart';

class StudentLobbyScreen extends StatefulWidget {
  final MultiplayerRoom initialRoom;
  final String currentPlayerId;

  const StudentLobbyScreen({
    super.key,
    required this.initialRoom,
    required this.currentPlayerId,
  });

  @override
  State<StudentLobbyScreen> createState() => _StudentLobbyScreenState();
}

class _StudentLobbyScreenState extends State<StudentLobbyScreen> {
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
        if (mounted) {
          setState(() => _room = updated);
          if (updated.status == 'IN_PROGRESS' && !_isStarting) {
            _navigateToMatch();
          }
        }
      } catch (_) {}
    });
  }

  void _navigateToMatch() {
    _pollTimer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => StudentMatchScreen(
          room: _room,
          currentPlayerId: widget.currentPlayerId,
        ),
      ),
    );
  }

  Future<void> _addBotPeer() async {
    final bot = await _service.addBotPeer(_room.pin);
    if (bot != null && mounted) {
      final updated = await _service.getRoom(_room.pin);
      setState(() => _room = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${bot.name} joined the peer lobby!'),
          backgroundColor: AppTheme.accentTeal,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _startMatch() async {
    setState(() => _isStarting = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final updated = await _service.startGame(_room.pin);
      _pollTimer?.cancel();
      if (mounted) {
        nav.pushReplacement(
          MaterialPageRoute(
            builder: (_) => StudentMatchScreen(
              room: updated,
              currentPlayerId: widget.currentPlayerId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isStarting = false);
        messenger.showSnackBar(
          SnackBar(content: Text('Cannot start match: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHost = _room.players.any((p) => p.playerId == widget.currentPlayerId && p.isHost);
    final canStart = _room.players.length >= 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Peer Lobby • Step 2',
          style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 4-Digit PIN Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E1B4B).withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'SHARE ROOM PIN WITH CLASSMATES',
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
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accentTeal,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Copy PIN',
                        icon: const Icon(Icons.copy, color: Colors.white, size: 22),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _room.pin));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Room PIN copied to clipboard!'),
                              backgroundColor: AppTheme.successGreen,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_room.topic} • ${_room.questionCount} Questions • ${_room.timePerQuestion}s limit',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Player Counter Header (Limits 2 - 5)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Connected Peers',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_room.players.length} / ${_room.maxPlayers}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_room.players.length < _room.maxPlayers)
                  OutlinedButton.icon(
                    onPressed: _addBotPeer,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: const Size(0, 32),
                      side: const BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.smart_toy_outlined, size: 14),
                    label: Text(
                      'Add Practice Peer',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Players List (2 - 5 players)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _room.players.length,
              itemBuilder: (context, index) {
                final player = _room.players[index];
                final isMe = player.playerId == widget.currentPlayerId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isMe ? AppTheme.primaryBlue : AppTheme.borderLight,
                      width: isMe ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primaryLight,
                        child: Text(
                          player.name.contains('🐼')
                              ? '🐼'
                              : (player.name.contains('🦉')
                                  ? '🦉'
                                  : (player.name.contains('⭐') ? '⭐' : '🦊')),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  player.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBlue.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'YOU',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              player.isHost ? 'Host Organizer' : 'Ready to Compete',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: player.isHost ? AppTheme.primaryBlue : AppTheme.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 20),
                    ],
                  ),
                );
              },
            ),

            if (_room.players.length < 2) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.warningBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Waiting for at least 1 more peer to join (or tap "Add Practice Peer" to play right now).',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.orange[900]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Start Match Button (Step 3 Trigger)
            if (isHost)
              ElevatedButton.icon(
                onPressed: canStart && !_isStarting ? _startMatch : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: _isStarting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                label: Text(
                  canStart ? 'Start Match (Step 3)' : 'Waiting for Players (Min 2)',
                  style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Waiting for host to start match...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
