import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' show log;

class LocalStorageService {
  static const String _choicesKey = 'choices';
  
  Future<Map<String, List<String>>> getChoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final choicesJson = prefs.getString(_choicesKey);
      if (choicesJson != null) {
        final Map<String, dynamic> choicesMap = json.decode(choicesJson);
        return choicesMap.map((key, value) => MapEntry(key, List<String>.from(value)));
      }
    } catch (e) {
      log('Error loading choices from local storage: $e');

    }
    return {};
  }
  
  Future<void> saveChoices(Map<String, List<String>> choices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final choicesJson = json.encode(choices);
      await prefs.setString(_choicesKey, choicesJson);
    } catch (e) {
      log('Error saving choices to local storage: $e');
    }
  }
  

  Future<void> addChoice(String category, String choice) async {
    final choices = await getChoices(); 
    choices[category] ??= [];
    if (!choices[category]!.contains(choice)) {
      choices[category]!.add(choice);
      await saveChoices(choices);
    }
  }
  
  Future<void> clearChoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_choicesKey);
    } catch (e) {
      log('Error clearing choices: $e');
    }
  }

  Future<void> deleteChoice(String category, String choice) async {
    try {
      final choices = await getChoices();
      choices[category]?.remove(choice);
      if(choices[category]?.isEmpty ?? false) {
        choices.remove(category);
      }
      await saveChoices(choices);
    } catch (e) {
      log('Error deleting choice from local storage: $e');
    }
  }
}
