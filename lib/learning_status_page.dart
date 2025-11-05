import 'package:flutter/material.dart';
import 'package:engword/local_storage_service.dart';

class LearningStatusPage extends StatefulWidget {
  const LearningStatusPage({super.key});

  @override
  State<LearningStatusPage> createState() => _LearningStatusPageState();
}

class _LearningStatusPageState extends State<LearningStatusPage> {
  final LocalStorageService _localStorageService = LocalStorageService();
  List<String> _completedDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedDates();
  }

  Future<void> _loadCompletedDates() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final List<String> dates = await _localStorageService.readLearningStatus();
      dates.sort((a, b) => b.compareTo(a)); // Sort by date, newest first
      setState(() {
        _completedDates = dates;
      });
    } catch (e) {
      print("Error loading completed dates: $e");
      // Optionally show an error message to the user
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Status'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _completedDates.isEmpty
              ? const Center(child: Text('No learning completed yet.'))
              : ListView.builder(
                  itemCount: _completedDates.length,
                  itemBuilder: (context, index) {
                    final date = _completedDates[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text('Learned on: $date'),
                      ),
                    );
                  },
                ),
    );
  }
}
