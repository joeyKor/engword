import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _wordControllers =
      List.generate(3, (_) => TextEditingController());
  final List<TextEditingController> _meaningControllers =
      List.generate(3, (_) => TextEditingController());

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Map<String, dynamic>> _selectedDayWords = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadWordsForSelectedDate(_selectedDay!);
  }

  Future<void> _loadWordsForSelectedDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final doc = await FirebaseFirestore.instance
        .collection('daily_words')
        .doc(dateStr)
        .get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!['words'] as List;
      setState(() {
        _selectedDayWords = List<Map<String, dynamic>>.from(data);
        for (int i = 0; i < 3; i++) {
          if (i < _selectedDayWords.length) {
            _wordControllers[i].text = _selectedDayWords[i]['word'];
            _meaningControllers[i].text = _selectedDayWords[i]['meaning'];
          } else {
            _wordControllers[i].clear();
            _meaningControllers[i].clear();
          }
        }
      });
    } else {
      setState(() {
        _selectedDayWords = [];
        for (int i = 0; i < 3; i++) {
          _wordControllers[i].clear();
          _meaningControllers[i].clear();
        }
      });
    }
  }

  Future<void> _saveWords() async {
    if (_formKey.currentState!.validate()) {
      final words = [];
      for (int i = 0; i < 3; i++) {
        words.add({
          'word': _wordControllers[i].text,
          'meaning': _meaningControllers[i].text,
        });
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay!);

      try {
        await FirebaseFirestore.instance
            .collection('daily_words')
            .doc(dateStr)
            .set({'words': words});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Words saved successfully!')),
        );
        _loadWordsForSelectedDate(_selectedDay!); // Refresh words after saving
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save words: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Daily Words'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _loadWordsForSelectedDate(selectedDay);
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
              const SizedBox(height: 20),
              ...List.generate(3, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Word ${index + 1}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _wordControllers[index],
                      decoration: const InputDecoration(labelText: 'Word'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a word';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _meaningControllers[index],
                      decoration: const InputDecoration(labelText: 'Meaning'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a meaning';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),
              ElevatedButton(
                onPressed: _saveWords,
                child: const Text('Save Words'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}