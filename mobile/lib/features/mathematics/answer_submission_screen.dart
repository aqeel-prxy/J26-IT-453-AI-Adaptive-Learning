import 'package:flutter/material.dart';
import '../../core/routing/app_router.dart';

class AnswerSubmissionScreen extends StatefulWidget {
  final String submittedSolution;

  const AnswerSubmissionScreen({
    super.key,
    this.submittedSolution = 'x^2 + 5x + 6 = 0\n(x + 2)(x + 3) = 0\nx = 2 or x = 3',
  });

  @override
  State<AnswerSubmissionScreen> createState() => _AnswerSubmissionScreenState();
}

class _AnswerSubmissionScreenState extends State<AnswerSubmissionScreen> {
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _simulateAnalysis();
  }

  Future<void> _simulateAnalysis() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adaptive Feedback')),
      body: _isAnalyzing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing step-by-step mathematical solution...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: const Color(0xFFFEF2F2),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: const [
                          Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 36),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Step 3 Error Detected', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                                Text('Classification: Sign Error', style: TextStyle(fontSize: 12, color: Colors.black87)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Diagnostic Feedback (Component 4)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text(
                    'In step 3, setting (x + 2) = 0 yields x = -2, not x = 2. Remember to change signs when solving linear factors.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  const Text('Suggested Correction:', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: const Text('x = -2 or x = -3', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, AppRouter.dashboard, (route) => false);
                    },
                    child: const Text('Return to Dashboard'),
                  ),
                ],
              ),
            ),
    );
  }
}
