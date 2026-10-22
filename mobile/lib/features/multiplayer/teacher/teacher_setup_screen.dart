import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'csv_web_helper.dart' as web_helper;
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

  // Custom / CSV state
  bool _isDragging = false;
  String? _uploadedFileName;
  int? _uploadedFileSize;
  List<QuizQuestion> _extractedQuestions = [];
  bool _showRawCsvEditor = false;

  // Custom / CSV text controller with mixed MCQ and Direct questions sample
  final _csvController = TextEditingController(
    text: "Solve: 2x + 6 = 14, 2, 4, 6, 8, 1, 2x = 8 so x = 4\n"
        "Simplify: 3² × 3³, 3⁵, 3⁶, 9⁵, 27, 0, Product rule adds powers\n"
        "State Pythagoras' theorem in words, a² + b² = c² in a right-angled triangle\n"
        "Factorize: x² - 9, (x-3)(x+3), (x-9)(x+1), (x-3)², x(x-9), 0, Difference of two squares\n"
        "Calculate the sum of interior angles in a hexagon, 720 degrees",
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
    _extractedQuestions = _extractQuestionsFromCsv(_csvController.text);
    if (_extractedQuestions.isNotEmpty) {
      _questionCount = _extractedQuestions.length;
      _questionCountController.text = '$_questionCount';
    }

    if (kIsWeb) {
      web_helper.initWebDropZone(
        (isDragging) {
          if (mounted && _isDragging != isDragging) {
            setState(() => _isDragging = isDragging);
          }
        },
        (content, fileName, size) {
          if (mounted) {
            _applyUploadedContent(content, fileName, size);
          }
        },
      );
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      web_helper.disposeWebDropZone();
    }
    _questionCountController.dispose();
    _timePerQuestionController.dispose();
    _csvController.dispose();
    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    try {
      if (kIsWeb) {
        await web_helper.pickFileCrossPlatform((content, fileName, size) {
          if (mounted) {
            _applyUploadedContent(content, fileName, size);
          }
        });
        return;
      }

      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        final bytes = await file.readAsBytes();
        final content = utf8.decode(bytes);
        final size = (await file.length()) ?? bytes.length;
        if (content.isNotEmpty) {
          _applyUploadedContent(content, file.name, size);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read file: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  Future<void> _handleDroppedFiles(List<dynamic> files) async {
    if (files.isEmpty) return;
    try {
      final file = files.first;
      final bytes = await file.readAsBytes();
      final content = utf8.decode(bytes);
      final size = await file.length();
      _applyUploadedContent(content, file.name, size);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process dropped file: $e'), backgroundColor: AppTheme.errorRed),
        );
      }
    }
  }

  void _applyUploadedContent(String content, String fileName, int size) {
    final parsed = _extractQuestionsFromCsv(content);
    setState(() {
      _csvController.text = content;
      _uploadedFileName = fileName;
      _uploadedFileSize = size;
      _extractedQuestions = parsed;
      if (parsed.isNotEmpty) {
        _questionCount = parsed.length;
        _questionCountController.text = '${parsed.length}';
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully extracted ${parsed.length} questions from $fileName'),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<QuizQuestion> _extractQuestionsFromCsv(String text) {
    if (text.trim().isEmpty) return [];

    final rows = _parseCsvRows(text);
    final List<QuizQuestion> questions = [];

    int startIndex = 0;
    // Check if first row is header
    if (rows.isNotEmpty) {
      final firstRow = rows[0].map((c) => c.toLowerCase()).join(' ');
      if (firstRow.contains('question') || firstRow.contains('option') || firstRow.contains('answer')) {
        startIndex = 1;
      }
    }

    for (int i = startIndex; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || row.every((c) => c.trim().isEmpty)) continue;

      final questionText = row[0].trim();
      if (questionText.isEmpty) continue;

      // Extract candidate options: columns 1 through 4 (if any)
      final List<String> candidateOptions = [];
      for (int c = 1; c < row.length && c <= 4; c++) {
        final opt = row[c].trim();
        if (opt.isNotEmpty) {
          candidateOptions.add(opt);
        }
      }

      // Check if it qualifies as an MCQ (has at least 2 non-empty options)
      final isMcq = candidateOptions.length >= 2;

      if (isMcq) {
        int correctIndex = 0;
        String explanation = '';

        if (row.length >= 6) {
          final answerCol = row[5].trim();
          correctIndex = _resolveCorrectIndex(answerCol, candidateOptions);
        }
        if (row.length >= 7) {
          explanation = row[6].trim();
        }

        questions.add(QuizQuestion(
          questionId: 'custom_${questions.length + 1}',
          questionText: questionText,
          options: candidateOptions,
          correctIndex: correctIndex,
          explanation: explanation,
          topic: _selectedTopic,
          difficulty: 'Custom',
        ));
      } else {
        // Non-MCQ: Direct question without multiple choice options
        String explanation = '';
        if (row.length >= 2) {
          explanation = row[1].trim();
        }

        questions.add(QuizQuestion(
          questionId: 'custom_${questions.length + 1}',
          questionText: questionText,
          options: const [],
          correctIndex: 0,
          explanation: explanation,
          topic: _selectedTopic,
          difficulty: 'Custom',
        ));
      }
    }

    return questions;
  }

  int _resolveCorrectIndex(String key, List<String> options) {
    final parsedInt = int.tryParse(key);
    if (parsedInt != null) {
      if (parsedInt >= 0 && parsedInt < options.length) {
        return parsedInt;
      }
      if (parsedInt >= 1 && parsedInt <= options.length) {
        return parsedInt - 1;
      }
    }

    final upper = key.toUpperCase();
    if (upper == 'A') return 0;
    if (upper == 'B') return options.length > 1 ? 1 : 0;
    if (upper == 'C') return options.length > 2 ? 2 : 0;
    if (upper == 'D') return options.length > 3 ? 3 : 0;

    final matchIdx = options.indexWhere((opt) => opt.toLowerCase() == key.toLowerCase());
    if (matchIdx != -1) return matchIdx;

    return 0;
  }

  List<List<String>> _parseCsvRows(String input) {
    final List<List<String>> rows = [];
    final StringBuffer currentField = StringBuffer();
    final List<String> currentRow = [];
    bool inQuotes = false;

    for (int i = 0; i < input.length; i++) {
      final char = input[i];

      if (char == '"') {
        if (inQuotes && i + 1 < input.length && input[i + 1] == '"') {
          currentField.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        currentRow.add(currentField.toString().trim());
        currentField.clear();
      } else if ((char == '\n' || char == '\r') && !inQuotes) {
        if (char == '\r' && i + 1 < input.length && input[i + 1] == '\n') {
          i++;
        }
        currentRow.add(currentField.toString().trim());
        currentField.clear();
        if (currentRow.any((field) => field.isNotEmpty)) {
          rows.add(List.from(currentRow));
        }
        currentRow.clear();
      } else {
        currentField.write(char);
      }
    }

    if (currentField.isNotEmpty || currentRow.isNotEmpty) {
      currentRow.add(currentField.toString().trim());
      if (currentRow.any((field) => field.isNotEmpty)) {
        rows.add(currentRow);
      }
    }

    return rows;
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

    List<QuizQuestion>? customQuestions;
    if (_quizSource == 'CUSTOM_UPLOAD') {
      customQuestions = _extractedQuestions.isNotEmpty
          ? _extractedQuestions
          : _extractQuestionsFromCsv(_csvController.text.trim());

      if (customQuestions.isEmpty) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No valid questions found in CSV. Please drop/select a CSV file or enter questions.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }
    }

    setState(() {
      _questionCount = _quizSource == 'CUSTOM_UPLOAD' ? (customQuestions?.length ?? enteredCount) : enteredCount;
      _timePerQuestion = enteredTime;
      _isLoading = true;
    });

    try {
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
              // Custom / CSV Upload - Drag & Drop and File Picker
              DropTarget(
                onDragDone: (detail) => _handleDroppedFiles(detail.files),
                onDragEntered: (detail) => setState(() => _isDragging = true),
                onDragExited: (detail) => setState(() => _isDragging = false),
                child: InkWell(
                  onTap: _pickCsvFile,
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: _isDragging ? AppTheme.primaryLight : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isDragging ? AppTheme.primaryBlue : (_uploadedFileName != null ? AppTheme.successGreen : AppTheme.borderLight),
                        width: _isDragging || _uploadedFileName != null ? 2.0 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isDragging ? AppTheme.primaryBlue.withOpacity(0.12) : Colors.black.withOpacity(0.03),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _uploadedFileName != null ? AppTheme.successGreen.withOpacity(0.12) : AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _uploadedFileName != null ? Icons.task_alt_rounded : Icons.cloud_upload_outlined,
                            size: 32,
                            color: _uploadedFileName != null ? AppTheme.successGreen : AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _uploadedFileName != null
                              ? 'CSV Attached: $_uploadedFileName'
                              : 'Drag & Drop CSV File Here',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _uploadedFileName != null
                              ? '${((_uploadedFileSize ?? 0) / 1024).toStringAsFixed(1)} KB • Click to choose a different file'
                              : 'or click to browse files from your computer',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Supports .csv and .txt',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'MCQs + Direct Questions',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // CSV Format Guideline Pill and Raw Editor Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _showRawCsvEditor = !_showRawCsvEditor);
                    },
                    icon: Icon(_showRawCsvEditor ? Icons.keyboard_arrow_up : Icons.code, size: 16),
                    label: Text(
                      _showRawCsvEditor ? 'Hide Raw CSV' : 'Edit / View Raw CSV',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      const template = "Solve: 2x + 6 = 14, 2, 4, 6, 8, 1, 2x = 8 so x = 4\n"
                          "Simplify: 3² × 3³, 3⁵, 3⁶, 9⁵, 27, 0, Product rule adds powers\n"
                          "State Pythagoras theorem in your own words, a² + b² = c² in a right-angled triangle\n"
                          "Factorize: x² - 9, (x-3)(x+3), (x-9)(x+1), (x-3)², x(x-9), 0, Difference of two squares\n"
                          "Calculate the sum of interior angles in a hexagon, 720 degrees";
                      _applyUploadedContent(template, 'sample_mixed_quiz.csv', template.length);
                    },
                    icon: const Icon(Icons.refresh, size: 15),
                    label: Text(
                      'Load Sample CSV',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accentTeal),
                    ),
                  ),
                ],
              ),

              if (_showRawCsvEditor) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CSV Format:\n• MCQ: Question, OptionA, OptionB, OptionC, OptionD, CorrectIndex (0-3 or letter), Explanation\n• Direct Question: Question, Explanation/Reference Answer',
                        style: GoogleFonts.firaCode(fontSize: 10.5, color: AppTheme.textSecondary, height: 1.35),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _csvController,
                        maxLines: 5,
                        style: GoogleFonts.firaCode(fontSize: 11),
                        decoration: InputDecoration(
                          hintText: 'Enter questions in CSV format...',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        onChanged: (val) {
                          final parsed = _extractQuestionsFromCsv(val);
                          setState(() {
                            _extractedQuestions = parsed;
                            _questionCount = parsed.length;
                            _questionCountController.text = '${parsed.length}';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Extracted Questions & Answers Display Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.quiz_outlined, size: 18, color: AppTheme.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        'Extracted Questions (${_extractedQuestions.length})',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStatBadge(
                        label: '${_extractedQuestions.where((q) => q.isMcq).length} MCQs',
                        color: AppTheme.primaryBlue,
                        bgColor: AppTheme.primaryLight,
                      ),
                      const SizedBox(width: 6),
                      _buildStatBadge(
                        label: '${_extractedQuestions.where((q) => !q.isMcq).length} Direct',
                        color: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFF3E8FF),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_extractedQuestions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Text(
                    'No questions extracted yet. Drag & drop a CSV file above or click to select.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...List.generate(_extractedQuestions.length, (idx) {
                  final q = _extractedQuestions[idx];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: q.isMcq ? AppTheme.borderLight : const Color(0xFFE9D5FF),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question Header: Index & Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Q ${idx + 1}',
                                style: GoogleFonts.firaCode(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                              ),
                            ),
                            if (q.isMcq)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 12, color: AppTheme.primaryBlue),
                                    const SizedBox(width: 4),
                                    Text(
                                      'MCQ (${q.options.length} Choices)',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryBlue),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3E8FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.help_outline_rounded, size: 12, color: Color(0xFF7C3AED)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Direct Question',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Question Text
                        Text(
                          q.questionText,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Show answers / options if MCQ
                        if (q.isMcq) ...[
                          Column(
                            children: List.generate(q.options.length, (optIdx) {
                              final isCorrect = (optIdx == q.correctIndex);
                              final letter = String.fromCharCode(65 + optIdx);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                                decoration: BoxDecoration(
                                  color: isCorrect ? AppTheme.successBg : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isCorrect ? AppTheme.successGreen : const Color(0xFFE2E8F0),
                                    width: isCorrect ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: isCorrect ? AppTheme.successGreen : Colors.white,
                                      child: Text(
                                        letter,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isCorrect ? Colors.white : AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        q.options[optIdx],
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          fontWeight: isCorrect ? FontWeight.w800 : FontWeight.w600,
                                          color: isCorrect ? AppTheme.successGreen : AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isCorrect) ...[
                                      const Icon(Icons.check_circle, size: 16, color: AppTheme.successGreen),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Answer',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppTheme.successGreen),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                          ),
                          if (q.explanation.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 14, color: AppTheme.primaryBlue),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      q.explanation,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ] else ...[
                          // Otherwise: Non-MCQ Notice
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE9D5FF)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, size: 14, color: Color(0xFF7C3AED)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Direct question shown directly to student without options.',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF7C3AED)),
                                    ),
                                  ],
                                ),
                                if (q.explanation.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Reference Answer / Key: ${q.explanation}',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
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

  Widget _buildStatBadge({required String label, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
