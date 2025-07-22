import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _choicesKey = 'random_choices';
  
  Future<List<String>> getChoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final choicesJson = prefs.getString(_choicesKey);
      if (choicesJson != null) {
        final List<dynamic> choicesList = json.decode(choicesJson);
        return choicesList.cast<String>();
      }
    } catch (e) {
      print('Error loading choices from local storage: $e');
    }
    return [];
  }
  
  Future<void> saveChoices(List<String> choices) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final choicesJson = json.encode(choices);
      await prefs.setString(_choicesKey, choicesJson);
    } catch (e) {
      print('Error saving choices to local storage: $e');
    }
  }
  
  Future<void> addChoice(String choice) async {
    final choices = await getChoices();
    if (!choices.contains(choice)) {
      choices.add(choice);
      await saveChoices(choices);
    }
  }
  
  Future<void> clearChoices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_choicesKey);
    } catch (e) {
      print('Error clearing choices: $e');
    }
  }

  Future<void> deleteChoice(String choice) async {
    try {
      final choices = await getChoices();
      choices.remove(choice);
      await saveChoices(choices);
    } catch (e) {
      print('Error deleting choice from local storage: $e');
    }
  }
}
