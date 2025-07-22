import 'package:flutter/material.dart';

class ChoiceListDialog extends StatefulWidget {
  final List<String> choices;
  final Function(String) onDelete;
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
  List<String> _currentChoices = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.forward();
    _currentChoices = List.from(widget.choices);
  }

  @override
  void didUpdateWidget(covariant ChoiceListDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.choices != oldWidget.choices) {
      _currentChoices = List.from(widget.choices);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _deleteChoice(String choice) async {
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
                backgroundColor: const Color(0xFFce315f)),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFffe3ea)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _deletingItems.add(choice);
        _currentChoices.remove(choice);
      });

      try {
        await widget.onDelete(choice);
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
          _deletingItems.remove(choice);
          _currentChoices.insert(widget.choices.indexOf(choice), choice);
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
        // added this
        setState(() {
          _deletingItems.remove(choice);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.list, color: Color(0xFF591C75)),
          SizedBox(width: 8),
          Text(
            'List Contents',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Spacer()
        ],
      ),
      content: SizedBox(
        width: double.minPositive,
        height: 400,
        child: _currentChoices.isEmpty
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF444655),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add some choices to get started!',
                      style: TextStyle(
                        color: Color(0xFF444655),
                      ),
                    ),
                  ],
                ),
              )
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ListView.builder(
                    itemCount: _currentChoices.length,
                    itemBuilder: (context, index) {
                      final choice = _currentChoices[index];
                      final isDeleting = _deletingItems.contains(choice);

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: Card(
                          elevation: 2,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF591C75)
                                  .withValues(alpha: 0.1),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF591C75),
                                  fontSize: 16,
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
                                  fontSize: 16),
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
                                    onPressed: () => _deleteChoice(choice),
                                    tooltip: 'Delete this choice',
                                  ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        if (widget.choices.isNotEmpty)
          ElevatedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Choices?'),
                  content: const Text(
                      'This will delete all your choices. This action cannot be undone!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFce315f)),
                      child: const Text(
                        'Delete All',
                        style: TextStyle(color: Color(0xFFffe3ea)),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                Navigator.pop(context, 'clear_all');
              }
            },
            icon: const Icon(Icons.delete, color: Color(0xFFffe3ea)),
            label: const Text(
              'Clear All',
              style: TextStyle(color: Color(0xFFffe3ea)),
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFce315f)),
          ),
      ],
    );
  }
}
