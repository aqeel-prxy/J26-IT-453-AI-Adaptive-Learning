import 'package:flutter/material.dart';
import '../../core/routing/app_router.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _solutionController = TextEditingController(
    text: 'x^2 + 5x + 6 = 0\n(x + 2)(x + 3) = 0\nx = 2 or x = 3',
  );

  void _onSolvePressed() {
    Navigator.pushNamed(
      context,
      AppRouter.submit,
      arguments: _solutionController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Question Workspace')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Problem 1 of 5', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                Chip(label: Text('Difficulty: 0.5'), backgroundColor: Color(0xFFFEF3C7)),
              ],
            ),
            const SizedBox(height: 12),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Question Statement', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Solve for x: x² + 5x + 6 = 0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Enter Your Step-by-Step Solution:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _solutionController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Write each step on a new line...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onSolvePressed,
              icon: const Icon(Icons.send),
              label: const Text('Submit Solution for Analysis'),
            ),
          ],
        ),
      ),
    );
  }
}
