import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routing/app_router.dart';
import '../../core/utils/image_picker_helper.dart';
import '../../core/services/error_diagnosis_service.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _questionController = TextEditingController();
  final _solutionController = TextEditingController();
  PickedImageData? _pickedImage;
  bool _isOcrLoading = false;

  final List<String> _mathSymbols = [
    'x²', 'x³', '√', '±', '×', '÷', '^', '≠', '≤', '≥', 'π', '(', ')', '='
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _solutionController.dispose();
    super.dispose();
  }

  Future<void> _handleImageCapture({required bool useCamera}) async {
    setState(() => _isOcrLoading = true);
    try {
      final img = useCamera
          ? await takePhotoFromCamera()
          : await pickImageFromGallery();

      if (img != null) {
        setState(() => _pickedImage = img);

        // Run OCR on the captured/picked image
        final extracted = await ErrorDiagnosisService.extractQuestionFromOCR(img.base64String);
        if (extracted != null && mounted) {
          setState(() {
            _questionController.text = extracted;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Question extracted via OCR: "$extracted"',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.successGreen,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to process image: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isOcrLoading = false);
    }
  }

  void _removePhoto() {
    setState(() {
      _pickedImage = null;
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
          content: Text('Please type a mathematical problem or take/upload a question photo.'),
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
        'question': question.isNotEmpty ? question : 'Solve 2x² + 5x - 3 = 0',
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
                      child: const Icon(Icons.playlist_add_check, color: AppTheme.primaryBlue, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Error Diagnosis Workspace',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Component 4',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF6D28D9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card 1: Question Input (Typed or Camera/OCR)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Mathematical Problem / Question',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Problem text field
                  TextField(
                    controller: _questionController,
                    maxLines: 2,
                    minLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type your mathematical problem statement (e.g. 2x² + 5x - 3 = 0)...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontWeight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // OCR Loading indicator
                  if (_isOcrLoading) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Extracting mathematical text from image using AI OCR...',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Photo preview thumbnail if attached
                  if (_pickedImage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.memory(
                              _pickedImage!.bytes,
                              width: 48,
                              height: 48,
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.successGreen,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'OCR Attached',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${(_pickedImage!.bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _pickedImage!.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppTheme.errorRed, size: 20),
                            onPressed: _removePhoto,
                            tooltip: 'Remove photo',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Dual Action Buttons: Camera + Gallery
                  Row(
                    children: [
                      // Camera button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isOcrLoading ? null : () => _handleImageCapture(useCamera: true),
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text('Take Photo (Camera)'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4338CA),
                            side: const BorderSide(color: Color(0xFF818CF8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: const Color(0xFFEEF2FF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Gallery/Upload button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isOcrLoading ? null : () => _handleImageCapture(useCamera: false),
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text('Upload Question Image'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: AppTheme.primaryLight.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Card 2: Step-by-Step Derivation
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
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
                      Text(
                        '2. Enter Your Step-by-Step Solution:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        '1 transformation / line',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mathematical Symbol Insertion Ribbon
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _mathSymbols.map((sym) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => _insertSymbol(sym),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
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
                  const SizedBox(height: 12),

                  // Solution text field
                  TextField(
                    controller: _solutionController,
                    maxLines: 8,
                    style: GoogleFonts.firaCode(
                      fontSize: 14,
                      height: 1.6,
                      color: const Color(0xFF1E293B),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type each intermediate solution step on a new line ...\nLine 1: 2x² + 5x - 3 = 0\nLine 2: 2x² + 6x - x - 3 = 0\nLine 3: 2x(x + 3) - 1(x + 3) = 0 ...',
                      hintStyle: GoogleFonts.firaCode(
                        color: const Color(0xFF94A3B8),
                        fontSize: 13,
                        height: 1.6,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Quick Samples Section
            Row(
              children: [
                Text(
                  'Quick Samples: ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _loadSample(
                    '2x² + 5x - 3 = 0',
                    '2x² + 6x - x - 3 = 0\n2x(x + 3) - 1(x + 3) = 0\n(2x - 1)(x + 3) = 0\nx = 1/2 or x = 3',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Quadratic Error Sample',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _loadSample(
                    'x² + 5x + 6 = 0',
                    'x² + 2x + 3x + 6 = 0\nx(x + 2) + 3(x + 2) = 0\n(x + 2)(x + 3) = 0\nx = -2 or x = -3',
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Correct Sample',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton.icon(
              onPressed: _onSolvePressed,
              icon: const Icon(Icons.psychology_outlined, size: 20),
              label: const Text('Submit Solution for AI Error Diagnosis'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
