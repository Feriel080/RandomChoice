import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../widgets/floating_particles.dart';
import '../widgets/choice_card.dart';
import '../widgets/add_choice_dialog.dart';
import '../widgets/choice_list_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<String> _choices = [];
  String? _selectedChoice;
  bool _isLoading = false;

  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _loadChoices();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadChoices() async {
    setState(() => _isLoading = true);
    try {
      final choices = await _apiService.getChoices();
      setState(() {
        _choices = choices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load choices: $e');
    }
  }

  Future<void> _getRandomChoice() async {
    if (_choices.isEmpty) {
      _shakeController.forward().then((_) => _shakeController.reset());
      _showErrorSnackBar('Add some choices first!');
      return;
    }

    setState(() => _isLoading = true);

    // Add suspense with pulse animation
    _pulseController.repeat(reverse: true);

    try {
      await Future.delayed(const Duration(milliseconds: 1500)); // Suspense
      final choice = await _apiService.getRandomChoice();

      _pulseController.stop();
      _pulseController.reset();

      setState(() {
        _selectedChoice = choice;
        _isLoading = false;
      });

      // Haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      _pulseController.stop();
      _pulseController.reset();
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to get random choice: $e');
    }
  }

  Future<void> _addChoice(String choice) async {
    try {
      await _apiService.addChoice(choice);
      await _loadChoices();
      _showSuccessSnackBar('"$choice" added successfully! ✨');
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  Future<void> _clearChoices() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Choices?'),
        content: const Text('This action cannot be undone!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_sweep, color: Color(0xFFce315f)),
            tooltip: 'Clear all',
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.clearChoices();
        await _loadChoices();
        setState(() => _selectedChoice = null);
        _showSuccessSnackBar('All choices cleared! 🧹');
      } catch (e) {
        _showErrorSnackBar('Failed to clear choices: $e');
      }
    }
  }

  Future<void> _deleteChoice(String choice) async {
    try {
      await _apiService.deleteChoice(choice);
      await _loadChoices();
      if (_selectedChoice == choice) {
        setState(() => _selectedChoice = null);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete choice: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
        style: const TextStyle(
          fontSize: 16
        ),),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF667eea),
                  Color(0xFF764ba2),
                  Color(0xFF667eea),
                ],
              ),
            ),
          ),

          // Floating particles
          const FloatingParticles(),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  // Choice counter
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_choices.length} choices available',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Random choice button
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return AnimatedBuilder(
                        animation: _shakeAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(_shakeAnimation.value, 0),
                            child: Transform.scale(
                              scale: _pulseAnimation.value,
                              child: GestureDetector(
                                onTap: _isLoading ? null : _getRandomChoice,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [
                                        Colors.orange,
                                        Colors.deepOrange
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange
                                            .withValues(alpha: 0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.casino,
                                                size: 60,
                                                color: Colors.white,
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                'CHOOSE!',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  // Selected choice display
                  if (_selectedChoice != null)
                    ChoiceCard(choice: _selectedChoice!),

                  const Spacer(),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton.extended(
                        onPressed: () => showDialog(
                          context: context,
                          builder: (context) => AddChoiceDialog(
                            onAdd: _addChoice,
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text(
                          'Add Item',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 173, 240, 222),
                      ),
                      FloatingActionButton.extended(
                        onPressed: () async {
                          final result = await showDialog<String>(
                            context: context,
                            builder: (context) => ChoiceListDialog(
                              choices: _choices,
                              onDelete: _deleteChoice,
                              onRefresh: _loadChoices,
                            ),
                          );

                          // Handle clear all action
                          if (result == 'clear_all') {
                            await _clearChoices();
                          }
                        },
                        icon: const Icon(Icons.list),
                        label: const Text(
                          'View List',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        backgroundColor: const Color(0xFFedeeff),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
