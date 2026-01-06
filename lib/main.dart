import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'screens/splash_screen.dart';
import 'screens/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  await SharedPreferences.getInstance(); 

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
      home: _shouldShowSplash() ? const SplashScreen() : const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  bool _shouldShowSplash() {
    if (kIsWeb) return false; 
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false; 
    }
  }
}
