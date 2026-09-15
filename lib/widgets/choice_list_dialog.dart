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
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
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

  Map<String, List<String>> get _filteredChoices {
    if (_searchQuery.isEmpty) return _currentChoices;

    final query = _searchQuery.toLowerCase();

    return {
      for (final entry in _currentChoices.entries)
        entry.key: entry.value
            .where((choice) => choice.toLowerCase().contains(query))
            .toList(),
    }..removeWhere((_, list) => list.isEmpty);
  }

  TextSpan _highlightMatch(String text, String query) {
    if (query.isEmpty) return TextSpan(text: text);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    final start = lowerText.indexOf(lowerQuery);

    if (start == -1) return TextSpan(text: text);

    final end = start + query.length;

    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, start)),
        TextSpan(
          text: text.substring(start, end),
          style: const TextStyle(
            color: Color.fromARGB(255, 28, 58, 117),
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(text: text.substring(end)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.list, color: Color(0xFF591C75)),
          const SizedBox(width: 8),
          if (!_isSearching) ...[
            const Text(
              'List Contents',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF591C75)),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          ] else ...[
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF591C75),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF591C75)),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                });
              },
            ),
          ],
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
                      style: TextStyle(color: Color(0xFF444655), fontSize: 16),
                    ),
                  ],
                ),
              )
            : AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final categories = _filteredChoices.keys
                      .where((cat) => _filteredChoices[cat]!.isNotEmpty)
                      .toList();

                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final items = _filteredChoices[category]!;

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
                                  title: Text.rich(
                                    _highlightMatch(choice, _searchQuery),
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
                                          onPressed: () =>
                                              _deleteChoice(category, choice),
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
          child: const Text('Close', style: TextStyle(fontSize: 16)),
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
              style: TextStyle(color: Color(0xFFffe3ea), fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFce315f),
            ),
          ),
      ],
    );
  }
}
