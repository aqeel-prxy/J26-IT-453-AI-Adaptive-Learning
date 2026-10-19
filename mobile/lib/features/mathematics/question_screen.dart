import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import '../../core/utils/image_picker_helper.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _questionController = TextEditingController();
  final _solutionController = TextEditingController();
  PickedImageData? _pickedImage;
  bool _isUploadingPhoto = false;

  final List<String> _mathSymbols = [
    'x²', 'x³', '√', '±', '×', '÷', '^', '≠', '≤', '≥', 'π', '(', ')', '='
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _solutionController.dispose();
    super.dispose();
  }

  Future<void> _pickQuestionPhoto() async {
    setState(() => _isUploadingPhoto = true);
    try {
      final img = await pickImageFromDevice();
      if (img != null) {
        setState(() {
          _pickedImage = img;
          if (_questionController.text.trim().isEmpty) {
            _questionController.text = 'Photo Problem: ${img.fileName}';
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  void _removePhoto() {
    setState(() {
      _pickedImage = null;
      if (_questionController.text.startsWith('Photo Problem:')) {
        _questionController.clear();
      }
    });
  }

  void _insertSymbol(String symbol) {
    final text = _solutionController.text;
    final selection = _solutionController.selection;
    if (selection.start >= 0) {
      final newText = selection.textBefore(text) + symbol + selection.textAfter(text);
      _solutionController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + symbol.length),
      );
    } else {
      _solutionController.text += symbol;
    }
  }

  void _loadSample(String question, String solution) {
    setState(() {
      _questionController.text = question;
      _solutionController.text = solution;
      _pickedImage = null;
    });
  }

  void _onSolvePressed() {
    final question = _questionController.text.trim();
    final solution = _solutionController.text.trim();

    if (question.isEmpty && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please type a mathematical problem or attach a question photo.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (solution.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your step-by-step mathematical derivation.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRouter.submit,
      arguments: {
        'question': question.isNotEmpty
            ? question
            : (_pickedImage != null ? 'Image Problem: ${_pickedImage!.fileName}' : 'Custom Problem'),
        'solution': solution,
        'hasImage': _pickedImage != null,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Problem Solving Workspace'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode Banner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.edit_note, color: AppTheme.primaryBlue, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Error Diagnosis Workspace',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E7FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Component 4',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card 1: Question Input / Photo Upload
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '1. Mathematical Problem / Question',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (_questionController.text.isNotEmpty || _pickedImage != null)
                        InkWell(
                          onTap: () {
                            setState(() {
                              _questionController.clear();
                              _pickedImage = null;
                            });
                          },
                          child: Text(
                            'Clear',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.errorRed,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Typed Question TextField
                  TextField(
                    controller: _questionController,
                    maxLines: 2,
                    minLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your mathematical problem statement here...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textMuted,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Photo Upload Option
                  if (_pickedImage == null)
                    OutlinedButton.icon(
                      onPressed: _isUploadingPhoto ? null : _pickQuestionPhoto,
                      icon: _isUploadingPhoto
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: Text(
                        _isUploadingPhoto ? 'Selecting Image...' : 'Attach Photo of Question (Image / OCR)',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: const BorderSide(color: AppTheme.primaryBlue),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _pickedImage!.bytes,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Question Photo Attached',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF065F46),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _pickedImage!.fileName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                            tooltip: 'Remove photo',
                            onPressed: _removePhoto,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card 2: Step-by-Step Derivation
            Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '2. Enter Your Step-by-Step Solution:',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '1 transformation / line',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Math Symbol Quick Bar
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _mathSymbols.map((sym) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: InkWell(
                            onTap: () => _insertSymbol(sym),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                sym,
                                style: GoogleFonts.firaCode(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Solution Text Area
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: TextField(
                      controller: _solutionController,
                      maxLines: null,
                      expands: true,
                      style: GoogleFonts.firaCode(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary,
                        height: 1.6,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Type each intermediate solution step on a new line...\nLine 1: 2x² + 5x - 3 = 0\nLine 2: 2x² + 6x - x - 3 = 0\nLine 3: 2x(x + 3) - 1(x + 3) = 0...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Samples Bar for Student Testing Convenience
            Row(
              children: [
                Text(
                  'Quick Samples:',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Quadratic Error Sample', style: TextStyle(fontSize: 11)),
                  onPressed: () => _loadSample(
                    'Solve for x: x² + 5x + 6 = 0',
                    'x^2 + 5x + 6 = 0\n(x + 2)(x + 3) = 0\nx = 2 or x = 3',
                  ),
                ),
                const SizedBox(width: 6),
                ActionChip(
                  label: const Text('Indices Sample', style: TextStyle(fontSize: 11)),
                  onPressed: () => _loadSample(
                    'Simplify: 2³ × 2⁴',
                    '2^3 * 2^4\n2^(3+4)\n2^7',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _onSolvePressed,
                icon: const Icon(Icons.psychology, size: 22),
                label: Text(
                  'Submit Solution for AI Error Diagnosis',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
