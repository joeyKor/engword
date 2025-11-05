import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:engword/local_storage_service.dart';

class ViewWordsPage extends StatefulWidget {
  const ViewWordsPage({super.key});

  @override
  State<ViewWordsPage> createState() => _ViewWordsPageState();
}

class _ViewWordsPageState extends State<ViewWordsPage> {
  final LocalStorageService _localStorageService = LocalStorageService();
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, dynamic>> _allWords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("en-US");
    _loadAllWords();
  }

  Future<void> _loadAllWords() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final Map<String, dynamic> localWordsMap = await _localStorageService.readWords();
      List<Map<String, dynamic>> words = [];

      localWordsMap.forEach((date, dailyWords) {
        for (var wordEntry in dailyWords) {
          words.add({
            'date': date,
            'word': wordEntry['word'],
            'meaning': wordEntry['meaning'],
            'example': wordEntry['example'] ?? 'No example',
          });
        }
      });

      // Sort by date, newest first
      words.sort((a, b) => DateFormat('yyyy-MM-dd').parse(b['date']).compareTo(DateFormat('yyyy-MM-dd').parse(a['date'])));

      setState(() {
        _allWords = words;
      });
    } catch (e) {
      print("Error loading all words: $e");
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _speakExample(String example) async {
    await flutterTts.speak(example);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View All Words'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allWords.isEmpty
              ? const Center(child: Text('No words saved yet.'))
              : ListView.builder(
                  itemCount: _allWords.length,
                  itemBuilder: (context, index) {
                    final wordData = _allWords[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${wordData['date']}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Word: ${wordData['word']}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[100]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Meaning: ${wordData['meaning']}',
                              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.brown[200]),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Example: ${wordData['example']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () => _speakExample(wordData['example']),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
