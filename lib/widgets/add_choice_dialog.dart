import 'package:flutter/material.dart';

class AddChoiceDialog extends StatefulWidget {
  final Function(String, String) onAdd;
  final List<String> existingCategories;

  const AddChoiceDialog({
    super.key,
    required this.onAdd,
    required this.existingCategories,
  });

  @override
  State<AddChoiceDialog> createState() => _AddChoiceDialogState();
}

class _AddChoiceDialogState extends State<AddChoiceDialog> {
  final TextEditingController _choiceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;
  bool _creatingNewCategory = false;
  String? _selectedExistingCategory;

  @override
  void initState() {
    super.initState();
    _creatingNewCategory = widget.existingCategories.isEmpty;
  }

  @override
  void dispose() {
    _choiceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  String get _resolvedCategory {
    return _creatingNewCategory
        ? _categoryController.text.trim()
        : _selectedExistingCategory ?? '';
  }

  Future<void> _addChoice() async {
    final choice = _choiceController.text.trim();
    final category = _resolvedCategory;

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
    required bool isEmpty,
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
    final categoryIsEmpty = _categoryController.text.trim().isEmpty;

    return AlertDialog(
      title: const Text('Add New Item ✨'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.existingCategories.isNotEmpty)
              ToggleButtons(
                isSelected: [
                  !_creatingNewCategory,
                  _creatingNewCategory,
                ],
                onPressed: (index) {
                  setState(() {
                    _creatingNewCategory = index == 1;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                constraints: const BoxConstraints(minHeight: 36, minWidth: 100),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Existing Category'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('New Category'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
          
              if (!_creatingNewCategory && widget.existingCategories.isNotEmpty)
              DropdownButtonFormField<String>(
                initialValue: _selectedExistingCategory,
                decoration: _fieldDecoration(
                  hint: 'Select Category',
                  icon: Icons.category_outlined,
                  isEmpty: _selectedExistingCategory == null,
                ),
                borderRadius: BorderRadius.circular(8),
                mouseCursor: SystemMouseCursors.click,
                dropdownMenuItemMouseCursor: SystemMouseCursors.click,
                items: widget.existingCategories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedExistingCategory = val;
                    if (_submitted) setState(() {});
                  });
                }
              )
              else 
                TextField(
                  controller: _categoryController,
                  decoration: _fieldDecoration(
                    hint: 'New Category Name',
                    icon: Icons.category_outlined,
                    isEmpty: categoryIsEmpty,
                  ),
                  autofocus: true,
                  onChanged: (_) {
                    if (_submitted) setState(() {});
                  },
                  onSubmitted: (_) => _addChoice(),
                ),
              const SizedBox(height: 10),
              TextField(
                controller: _choiceController,
                decoration: _fieldDecoration(
                  hint: 'Choice',
                  icon: Icons.add_circle_outline,
                  isEmpty: _choiceController.text.trim().isEmpty,
                ),
                onChanged: (_) {
                  if (_submitted) setState(() {});
                },
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
        ),
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
