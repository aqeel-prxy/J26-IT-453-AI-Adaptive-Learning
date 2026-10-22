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
  bool _isSubmitting = false;
  String? _ocrErrorMessage;
  String? _ocrNoticeMessage;
  String? _solverErrorMessage;
  bool _showWorkingBox = false;


  final List<String> _mathSymbols = [
    'x²', 'x³', '√', '±', '×', '÷', '^', '≠', '≤', '≥', 'π', '(', ')', '='
  ];

  @override
  void dispose() {
    _questionController.dispose();
    _solutionController.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    if (_isOcrLoading || _isSubmitting) return;
    final img = await takePhotoFromCamera(context);
    if (img != null) {
      await _processPickedImage(img);
    }
  }

  Future<void> _pickPhotoFromGallery() async {
    if (_isOcrLoading || _isSubmitting) return;
    final img = await pickImageFromGallery();
    if (img != null) {
      await _processPickedImage(img);
    }
  }

  Future<void> _processPickedImage(PickedImageData img) async {
    setState(() {
      _pickedImage = img;
      _isOcrLoading = true;
      _ocrErrorMessage = null;
      _ocrNoticeMessage = null;
      _solverErrorMessage = null;
    });

    try {
      final ocrRes = await ErrorDiagnosisService.extractQuestionFromOCR(img.base64String);

      if (mounted) {
        if (ocrRes['success'] == true && ocrRes['extracted_question'] != null) {
          final extracted = (ocrRes['extracted_question'] as String).trim();
          setState(() {
            _questionController.text = extracted;
            _ocrNoticeMessage = 'Question identified via OCR: "$extracted". Review or edit the equation below, then click "Solve Step-by-Step".';
          });
        } else {
          setState(() {
            _ocrErrorMessage = ocrRes['error_message'] ??
                'Could not reliably extract mathematical symbols from this image. Please capture a clearer photo or type the question manually.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ocrErrorMessage = 'Failed to process image ($e). You can enter the equation manually below.';
        });
      }
    } finally {
      if (mounted) setState(() => _isOcrLoading = false);
    }
  }

  void _removePhoto() {
    setState(() {
      _pickedImage = null;
      _ocrErrorMessage = null;
      _ocrNoticeMessage = null;
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
      _ocrErrorMessage = null;
      _ocrNoticeMessage = null;
      _solverErrorMessage = null;
      _showWorkingBox = true;
    });
  }

  /// 1. Automatic Solving Workflow ("Solve")
  Future<void> _onSolvePressed() async {
    final question = _questionController.text.trim();
    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a mathematical question or capture a photo.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }
    await _solveQuestionAndNavigate(question);
  }

  Future<void> _solveQuestionAndNavigate(String question) async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _solverErrorMessage = null;
    });

    try {
      final res = await ErrorDiagnosisService.solveQuestion(question);

      if (!mounted) return;

      if (res['success'] == true) {
        Navigator.pushNamed(
          context,
          AppRouter.submit,
          arguments: {
            'mode': 'solve',
            'question': question,
            'solveResult': res,
          },
        );
      } else {
        setState(() {
          _solverErrorMessage = res['error_message'] ??
              'This question could not be solved by the engine. Please enter a valid Grade 10-11 linear or quadratic algebra equation.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _solverErrorMessage = 'Failed to derive step-by-step solution ($e).';
        });
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// 2. Student Working Checking Workflow ("Check My Working")
  Future<void> _onCheckWorkingPressed() async {
    final question = _questionController.text.trim();
    final solution = _solutionController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the mathematical problem statement first.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (solution.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your step-by-step derivation to check.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final res = await ErrorDiagnosisService.checkWorking(
        question: question,
        solutionSteps: solution,
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        AppRouter.submit,
        arguments: {
          'mode': 'check_working',
          'question': question,
          'solution': solution,
          'checkResult': res,
        },
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
            // Mode Header
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
                      child: const Icon(Icons.calculate, color: AppTheme.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mathematics Problem Solver',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
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

            // Card 1: Question Input (Manual / Camera / Image Upload)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Mathematical Question Input',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Type manually, capture from textbook with camera, or upload a photo:',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dual Action Buttons: Camera + Gallery
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (_isOcrLoading || _isSubmitting)
                              ? null
                              : _captureFromCamera,
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text('Capture Camera'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4338CA),
                            side: const BorderSide(color: Color(0xFF818CF8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: const Color(0xFFEEF2FF),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (_isOcrLoading || _isSubmitting)
                              ? null
                              : _pickPhotoFromGallery,
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text('Upload Photo'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBlue,
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Image Preview if picked
                  if (_pickedImage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pickedImage!.fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${(_pickedImage!.bytes.lengthInBytes / 1024).toStringAsFixed(1)} KB image ready',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
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

                  // OCR Loading State
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
                              'Analyzing question photo using AI OCR...',
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

                  // OCR Success Notice Banner
                  if (_ocrNoticeMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.successBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: AppTheme.successGreen, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _ocrNoticeMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF065F46),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // OCR Error Banner
                  if (_ocrErrorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.errorBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _ocrErrorMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Question Text Field
                  TextField(
                    controller: _questionController,
                    maxLines: 2,
                    minLines: 1,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Question Statement / Equation',
                      hintText: 'e.g. 2(x + 3) = 14  or  2x² + 5x - 3 = 0',
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

                  // Solver Error Message Banner (if unsupported question submitted)
                  if (_solverErrorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFD97706), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Unsupported Question Format',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF92400E),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _solverErrorMessage!,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Primary Solve Button
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _onSolvePressed,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(_isSubmitting ? 'Solving Problem...' : 'Solve Step-by-Step'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Card 2: Student Solution / "Check My Working" Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => setState(() => _showWorkingBox = !_showWorkingBox),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.edit_note, color: AppTheme.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '2. Check My Working (Optional)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Evaluate your personal step-by-step derivation for errors',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(
                          _showWorkingBox ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ),

                  if (_showWorkingBox) ...[
                    const Divider(height: 24),

                    // Symbol bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _mathSymbols.map((sym) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: InkWell(
                              onTap: () => _insertSymbol(sym),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  sym,
                                  style: GoogleFonts.firaCode(
                                    fontSize: 12,
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

                    // Derivation Input
                    TextField(
                      controller: _solutionController,
                      maxLines: 7,
                      style: GoogleFonts.firaCode(
                        fontSize: 13,
                        height: 1.5,
                        color: const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your derivation line-by-line ...\nLine 1: 2x² + 6x - x - 3 = 0\nLine 2: 2x(x + 3) - 1(x + 3) = 0\nLine 3: (2x - 1)(x + 3) = 0\nLine 4: x = 1/2 or x = 3',
                        hintStyle: GoogleFonts.firaCode(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                          height: 1.5,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Samples
                    Row(
                      children: [
                        Text(
                          'Samples: ',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () => _loadSample(
                            '2x² + 5x - 3 = 0',
                            '2x² + 6x - x - 3 = 0\n2x(x + 3) - 1(x + 3) = 0\n(2x - 1)(x + 3) = 0\nx = 1/2 or x = 3',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            'Sign Error Sample',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 6),
                        OutlinedButton(
                          onPressed: () => _loadSample(
                            '2(x + 3) = 14',
                            '2x + 6 = 14\n2x = 8\nx = 4',
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            'Linear Sample',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Check My Working Button
                    OutlinedButton.icon(
                      onPressed: _isSubmitting ? null : _onCheckWorkingPressed,
                      icon: const Icon(Icons.fact_check_outlined, size: 18),
                      label: Text(_isSubmitting ? 'Analyzing Working...' : 'Check My Working'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        foregroundColor: const Color(0xFF4338CA),
                        side: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                        backgroundColor: const Color(0xFFEEF2FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
