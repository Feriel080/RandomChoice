import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'local_storage_service.dart';

class ApiService {
  // Dynamic base URL based on platform
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000'; // Web development
    } else {
      return 'http://localhost:8000'; // Desktop/Mobile
    }
  }
  
  final LocalStorageService _localStorage = LocalStorageService();
  
  Future<List<String>> getChoices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/choices'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final choices = List<String>.from(data['choices']);
        // Save to local storage as backup
        await _localStorage.saveChoices(choices);
        return choices;
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API unavailable, using local storage: $e');
      }
      // Fallback to local storage
      return await _localStorage.getChoices();
    }
  }

  Future<String> getRandomChoice() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/random'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choice'];
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('API unavailable, using local random: $e');
      }
      // Fallback to local random selection
      final choices = await _localStorage.getChoices();
      if (choices.isEmpty) {
        throw Exception('No choices available! Add some choices first.');
      }
      return choices[Random().nextInt(choices.length)];
    }
  }

  Future<void> addChoice(String choice) async {
    // Always save locally first
    final choices = await _localStorage.getChoices();
    if (choices.contains(choice.trim())) {
      throw Exception('Choice already exists!');
    }
    await _localStorage.addChoice(choice.trim());
    
    // Try to sync with server
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/choices'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': choice.trim()}),
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        if (kDebugMode) {
          print('Server sync failed: ${data['detail']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Server sync failed, saved locally: $e');
      }
      // Choice is already saved locally, so this is fine
    }
  }

  Future<void> clearChoices() async {
    // Clear locally first
    await _localStorage.clearChoices();
    
    // Try to sync with server
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/choices'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Server clear failed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Server clear failed, cleared locally: $e');
      }
      // Choices are already cleared locally, so this is fine
    }
  }

  Future<void> deleteChoice(String choice) async {
    // Remove from local storage first
    final choices = await _localStorage.getChoices();
    choices.remove(choice);
    await _localStorage.saveChoices(choices);
    
    // Try to sync with server
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/choices/${Uri.encodeComponent(choice)}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));
    
      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Server delete failed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Server delete failed, deleted locally: $e');
      }
      // Choice is already deleted locally, so this is fine
    }
  }
}
