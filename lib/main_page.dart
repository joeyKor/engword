import 'package:engword/learning_status_page.dart';
import 'package:engword/settings_page.dart';
import 'package:flutter/material.dart';
import 'word_quiz_page.dart';
import 'package:engword/view_words_page.dart';
import 'package:engword/local_storage_service.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final LocalStorageService _localStorageService = LocalStorageService();
  String _learningStatusMessage = '';
  Color _messageColor = Colors.black;
  String _todayDate = '';

  @override
  void initState() {
    super.initState();
    _checkLearningStatus();
    _setTodayDate();
  }

  void _setTodayDate() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MMMM-dd, EEEE'); // Changed format for full month name
    setState(() {
      _todayDate = formatter.format(now);
    });
  }

  Future<void> _checkLearningStatus() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final List<String> completedDates = await _localStorageService.readLearningStatus();

    setState(() {
      if (completedDates.contains(today)) {
        _learningStatusMessage = 'Today\'s learning completed!';
        _messageColor = Colors.yellow;
      } else {
        _learningStatusMessage = 'Today\'s learning not completed.';
        _messageColor = Colors.red;
      }
    });
  }

  Future<void> _showPinDialog() async {
    final pinController = TextEditingController();
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter PIN'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please enter the PIN to access settings.'),
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  maxLength: 4,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () {
                if (pinController.text == '0000') {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                } else {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect PIN')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EngWord'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showPinDialog,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _todayDate,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Increased font size
            ),
            const SizedBox(height: 25), // Increased SizedBox height
            Text(
              _learningStatusMessage,
              style: TextStyle(fontSize: 20, color: _messageColor), // Increased font size
            ),
            const SizedBox(height: 25), // Increased SizedBox height
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WordQuizPage()),
                );
                _checkLearningStatus();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Increased padding
                textStyle: const TextStyle(fontSize: 20), // Increased font size
              ),
              child: const Text('Start Learning'),
            ),
            const SizedBox(height: 25), // Increased SizedBox height
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewWordsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Increased padding
                textStyle: const TextStyle(fontSize: 20), // Increased font size
              ),
              child: const Text('View Words'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LearningStatusPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Increased padding
                textStyle: const TextStyle(fontSize: 20), // Increased font size
              ),
              child: const Text('Check Learning Status'),
            ),
          ],
        ),
      ),
    );
  }
}
