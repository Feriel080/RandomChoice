import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'screens/splash_screen.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const RandomChoiceGameApp());
}

class RandomChoiceGameApp extends StatelessWidget {
  const RandomChoiceGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Choice',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Caveat',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Show splash screen only on mobile platforms
      home: _shouldShowSplash() ? const SplashScreen() : const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  bool _shouldShowSplash() {
    // Show splash screen on mobile platforms (Android/iOS)
    if (kIsWeb) return false; // Not on web
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false; // Fallback for unsupported platforms
    }
  }
}
