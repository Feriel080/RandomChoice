import 'package:flutter/material.dart';

class AddChoiceDialog extends StatefulWidget {
  final Function(String) onAdd;

  const AddChoiceDialog({super.key, required this.onAdd});

  @override
  State<AddChoiceDialog> createState() => _AddChoiceDialogState();
}

class _AddChoiceDialogState extends State<AddChoiceDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addChoice() async {
    final choice = _controller.text.trim();
    if (choice.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      await widget.onAdd(choice);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item ✨'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Write here...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.add_circle_outline),
            ),
            autofocus: true,
            onSubmitted: (_) => _addChoice(),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enter any kind of activity you want to do.',
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
          child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Add'),
        ),
      ],
    );
  }
}
