import 'package:flutter/material.dart';

class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      {'title': 'Quadratic Equations', 'grade': 'Grade 10', 'concepts': 4},
      {'title': 'Perimeter and Area of Plane Figures', 'grade': 'Grade 10', 'concepts': 3},
      {'title': 'Indices and Logarithms', 'grade': 'Grade 11', 'concepts': 5},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Grade 10–11 Math Topics')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final item = topics[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF1E3A8A),
                child: Icon(Icons.calculate, color: Colors.white),
              ),
              title: Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${item['grade']} • ${item['concepts']} Concepts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Selected topic: ${item['title']}')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
