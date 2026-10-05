import 'package:flutter/material.dart';
import '../../core/routing/app_router.dart';

class ConceptScreen extends StatelessWidget {
  final String conceptTitle;
  final String topicCategory;

  const ConceptScreen({
    super.key,
    this.conceptTitle = 'Solving Quadratic Equations by Factorization',
    this.topicCategory = 'Quadratic Equations',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(topicCategory)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              conceptTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Chip(
              label: Text('Grade 10 • Concept Code: MATH-G10-QUAD-01'),
              backgroundColor: Color(0xFFE2E8F0),
            ),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Concept Mastery Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    LinearProgressIndicator(value: 0.42, minHeight: 8, backgroundColor: Color(0xFFE2E8F0), color: Color(0xFF0D9488)),
                    SizedBox(height: 4),
                    Text('Estimated Mastery: 42%', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.question);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Problem Solving Session'),
            ),
          ],
        ),
      ),
    );
  }
}
