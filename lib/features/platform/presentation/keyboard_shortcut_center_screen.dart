import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/presentation/widgets/keyboard_shortcut_overlay.dart';

class KeyboardShortcutCenterScreen extends ConsumerStatefulWidget {
  const KeyboardShortcutCenterScreen({super.key});

  @override
  ConsumerState<KeyboardShortcutCenterScreen> createState() => _KeyboardShortcutCenterScreenState();
}

class _KeyboardShortcutCenterScreenState extends ConsumerState<KeyboardShortcutCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Filter shortcuts based on query
    final filtered = globalShortcuts.where((s) {
      final query = _searchQuery.toLowerCase();
      return s.label.toLowerCase().contains(query) || 
             s.category.toLowerCase().contains(query) || 
             s.description.toLowerCase().contains(query) ||
             s.keys.any((k) => k.toLowerCase().contains(query));
    }).toList();

    // Group by category
    final Map<String, List<PlatformShortcut>> grouped = {};
    for (var s in filtered) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Keyboard Shortcut Center'),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: 300,
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search shortcuts (e.g., Ctrl, Save)',
                leading: const Icon(LucideIcons.search, size: 18),
                trailing: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                ],
                onChanged: (val) => setState(() => _searchQuery = val),
                elevation: const WidgetStatePropertyAll(0),
                backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.appWindow),
            tooltip: 'Open Overlay Cheat Sheet',
            onPressed: () => ShortcutCheatSheetDialog.show(context),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: filtered.isEmpty 
        ? const Center(child: Text('No shortcuts found matching your search.'))
        : ListView.builder(
            padding: const EdgeInsets.all(32),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final category = grouped.keys.elementAt(index);
              final items = grouped[category]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.toUpperCase(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: theme.dividerColor),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, itemIndex) {
                          final shortcut = items[itemIndex];
                          return ListTile(
                            title: Text(shortcut.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: shortcut.description.isNotEmpty ? Text(shortcut.description) : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: shortcut.keys.map((k) => KeyCapWidget(keyLabel: k)).toList(),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              );
            },
          ),
    );
  }
}
