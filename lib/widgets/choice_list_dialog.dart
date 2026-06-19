import 'package:flutter/material.dart';

class ChoiceListDialog extends StatefulWidget {
  final Map<String, List<String>> choices;
  final Function(String, String) onDelete;
  final VoidCallback onRefresh;

  const ChoiceListDialog({
    super.key,
    required this.choices,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  State<ChoiceListDialog> createState() => _ChoiceListDialogState();
}

class _ChoiceListDialogState extends State<ChoiceListDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final Set<String> _deletingItems = {};
  late Map<String, List<String>> _currentChoices;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.forward();
    _currentChoices = _cloneChoices(widget.choices);
  }

  @override
  void didUpdateWidget(covariant ChoiceListDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.choices != oldWidget.choices) {
      _currentChoices = _cloneChoices(widget.choices);
    }
  }

  Map<String, List<String>> _cloneChoices(Map<String, List<String>> choices) {
    return choices.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _itemKey(String category, String choice) => '$category-$choice';

  Future<void> _deleteChoice(String category, String choice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Choice?'),
        content: Text('Are you sure you want to delete "$choice"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFce315f),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFffe3ea)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final key = _itemKey(category, choice);
    final originalIndex = _currentChoices[category]?.indexOf(choice) ?? -1;

    setState(() {
      _deletingItems.add(key);
      _currentChoices[category]?.remove(choice);
    });

    try {
      await widget.onDelete(category, choice);
      widget.onRefresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$choice" Deleted successfully ✅'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        if (originalIndex >= 0) {
          _currentChoices[category]?.insert(originalIndex, choice);
        } else {
          _currentChoices[category]?.add(choice);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() {
        _deletingItems.remove(key);
      });
    }
  }

  bool get _isEmpty => _currentChoices.values.every((list) => list.isEmpty);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.list, color: Color(0xFF591C75)),
          SizedBox(width: 8),
          Text('List Contents', style: TextStyle(fontWeight: FontWeight.bold)),
          Spacer(),
        ],
      ),
      content: SizedBox(
        width: 520,
        height: 400,
        child: _isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Color(0xFF444655),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'The list is empty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF444655),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add some choices to get started!',
                      style: TextStyle(
                        color: Color(0xFF444655),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final categories = _currentChoices.keys
                      .where((cat) => _currentChoices[cat]!.isNotEmpty)
                      .toList();

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final items = _currentChoices[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF591C75),
                              ),
                            ),
                          ),
                          ...items.asMap().entries.map((entry) {
                            final index = entry.key;
                            final choice = entry.value;
                            final key = _itemKey(category, choice);
                            final isDeleting = _deletingItems.contains(key);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              child: Card(
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(
                                      0xFF591C75,
                                    ).withValues(alpha: 0.1),
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF591C75),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    choice,
                                    style: TextStyle(
                                      decoration: isDeleting
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isDeleting
                                          ? const Color(0xFFedeeff)
                                          : null,
                                      fontSize: 18,
                                    ),
                                  ),
                                  trailing: isDeleting
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Color(0xFFce315f),
                                          ),
                                          onPressed: () =>  _deleteChoice(category, choice),
                                          tooltip: 'Delete this choice',
                                        ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(fontSize: 16)
            ),
        ),
        if (!_isEmpty)
          ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Choices?'),
                  content: const Text(
                    'This will delete all your choices. This action cannot be undone!',
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFce315f),
                      ),
                      child: const Text(
                        'Delete All',
                        style: TextStyle(color: Color(0xFFffe3ea)),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                if (context.mounted) {
                  Navigator.pop(context, 'clear_all');
                }
              }
            },
            icon: const Icon(Icons.delete, color: Color(0xFFffe3ea)),
            label: const Text(
              'Clear All',
              style: TextStyle(
                color: Color(0xFFffe3ea),
                fontSize: 16,
                ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFce315f),
            ),
          ),
      ],
    );
  }
}
