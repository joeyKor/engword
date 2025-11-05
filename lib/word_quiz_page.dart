import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';

// WordQuizPage is the main page of the application where the quiz happens.
class WordQuizPage extends StatefulWidget {
  const WordQuizPage({super.key});

  @override
  State<WordQuizPage> createState() => _WordQuizPageState();
}

class _WordQuizPageState extends State<WordQuizPage> {
  List _words = []; // List to hold the words from the JSON file.
  int _currentIndex = 0; // Index of the current word in the quiz.
  String _message =
      ''; // Message to show to the user (e.g., "Correct!", "Incorrect.").
  List<TextEditingController> _controllers =
      []; // Controllers for the text fields.
  List<FocusNode> _focusNodes = []; // Focus nodes for the text fields.
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    _loadWords();
  }

// Load words from Firestore for the current date, or from the local JSON if not available.
  Future<void> _loadWords() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final doc = await FirebaseFirestore.instance.collection('daily_words').doc(today).get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!['words'] as List;
      setState(() {
        _words = List<Map<String, dynamic>>.from(data);
        _words.shuffle();
        _setupWord();
      });
    } else {
      // Fallback to local JSON
      final String response = await rootBundle.loadString('assets/word.json');
      final data = await json.decode(response);
      setState(() {
        _words = data;
        _words.shuffle(); // Shuffle the words for a random quiz.
        _setupWord();
      });
    }
  }

  // Set up the controllers and focus nodes for the current word.
  void _setupWord() {
    _controllers = List.generate(
      _words[_currentIndex]['word'].length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      _words[_currentIndex]['word'].length,
      (index) => FocusNode(),
    );
    // Request focus for the first text field
    _focusNodes[0].requestFocus();
    _speak();
  }

  // Speak the current word.
  Future<void> _speak() async {
    await flutterTts.speak(_words[_currentIndex]['word']);
  }

  // Check the user's answer.
  void _checkAnswer() {
    String answer = _controllers.map((controller) => controller.text).join();
    if (answer.toLowerCase() == _words[_currentIndex]['word']) {
      setState(() {
        _message = 'Correct!';
      });
      // Move to the next word after a short delay.
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _words.length;
          _message = '';
          _setupWord();
        });
      });
    } else {
      setState(() {
        _message = 'Incorrect. Try again.';
      });
    }
  }

  // Show a dialog to confirm the entered word.
  void _showConfirmationDialog() {
    String enteredWord = _controllers
        .map((controller) => controller.text)
        .join();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Answer'),
          content: Text('Is "$enteredWord" your final answer?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkAnswer();
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Dispose the controllers and focus nodes to free up resources.
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('English Word Quiz')),
      body: _words.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Meaning: ${_words[_currentIndex]['meaning']}',
                        style: const TextStyle(fontSize: 24),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: _speak,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) {
                      if (event is RawKeyDownEvent &&
                          event.logicalKey == LogicalKeyboardKey.backspace) {
                        for (int i = 0; i < _focusNodes.length; i++) {
                          if (_focusNodes[i].hasFocus && i > 0) {
                            _focusNodes[i - 1].requestFocus();
                            _controllers[i].clear();
                            _controllers[i - 1].clear();
                            break;
                          }
                        }
                      }
                    },
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(
                        _words[_currentIndex]['word'].length,
                        (index) => SizedBox(
                          width: 50,
                          height: 50,
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: _controllers[index].text.isNotEmpty
                                  ? Colors.grey[700]
                                  : Colors.grey[850],
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty &&
                                  index < _focusNodes.length - 1) {
                                _focusNodes[index + 1].requestFocus();
                              }
                              if (_controllers.every(
                                (controller) => controller.text.isNotEmpty,
                              )) {
                                _showConfirmationDialog();
                              }
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    child: const Text('Submit'),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _message,
                    style: TextStyle(
                      fontSize: 18,
                      color: _message == 'Correct!'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
