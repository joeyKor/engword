import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _wordsKey = 'words_data';
  static const String _learningStatusKey = 'learning_status_dates';

  Future<Map<String, dynamic>> readWords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? wordsJson = prefs.getString(_wordsKey);

    if (wordsJson == null) {
      // If not in SharedPreferences, load from assets and save it
      final String assetContent = await rootBundle.loadString('assets/word.json');
      await prefs.setString(_wordsKey, assetContent);
      print("Local word.json seeded from assets to SharedPreferences.");
      return json.decode(assetContent) as Map<String, dynamic>;
    }

    return json.decode(wordsJson) as Map<String, dynamic>;
  }

  Future<void> writeWords(Map<String, dynamic> words) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wordsKey, json.encode(words));
  }

  Future<List<String>> readLearningStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? dates = prefs.getStringList(_learningStatusKey);
    return dates ?? [];
  }

  Future<void> writeLearningStatus(List<String> dates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_learningStatusKey, dates);
  }

  Future<void> addLearningDate(String date) async {
    final List<String> dates = await readLearningStatus();
    if (!dates.contains(date)) {
      dates.add(date);
      await writeLearningStatus(dates);
    }
  }
}