
import 'package:flutter/material.dart';
import 'word_quiz_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EngWord'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WordQuizPage()),
            );
          },
          child: const Text('영어 학습'),
        ),
      ),
    );
  }
}
