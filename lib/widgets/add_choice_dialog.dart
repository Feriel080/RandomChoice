import 'package:flutter/material.dart';

class AddChoiceDialog extends StatefulWidget {
  final Function(String, String) onAdd;

  const AddChoiceDialog({super.key, required this.onAdd});

  @override
  State<AddChoiceDialog> createState() => _AddChoiceDialogState();
}

class _AddChoiceDialogState extends State<AddChoiceDialog> {
  final TextEditingController _choiceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _choiceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _addChoice() async {
    final choice = _choiceController.text.trim();
    final category = _categoryController.text.trim();

    if (choice.isEmpty || category.isEmpty) {
      setState(() => _submitted = true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.onAdd(category, choice);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    required bool isEmpty
  }) {
    final showError = _submitted && isEmpty;
    return InputDecoration(
      hintText: hint,
      border: const OutlineInputBorder(),
      prefixIcon: Icon(icon),
      errorText: showError ? 'This field is required' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item ✨'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _categoryController,
            decoration: _fieldDecoration(
              hint: 'Category',
              icon: Icons.category_outlined,
              isEmpty: _categoryController.text.trim().isEmpty
            ),
            autofocus: true,
            onChanged: (_) { if (_submitted) setState(() {}); },
            onSubmitted: (_) => _addChoice(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _choiceController,
            decoration: _fieldDecoration(
              hint: 'Choice',
              icon: Icons.add_circle_outline,
              isEmpty: _choiceController.text.trim().isEmpty
            ),
            onChanged: (_) { if (_submitted) setState(() {}); },
            onSubmitted: (_) => _addChoice(),
          ),
          const SizedBox(height: 10),
          const Text(
            'The category is for grouping your choices.',
            style: TextStyle(
              fontSize: 17,
              color: Color.fromARGB(255, 133, 131, 131),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addChoice,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
