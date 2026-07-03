import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PlatformShortcut {
  final String label;
  final List<String> keys;
  final String category;
  final String description;

  const PlatformShortcut({
    required this.label,
    required this.keys,
    required this.category,
    this.description = '',
  });
}

const List<PlatformShortcut> globalShortcuts = [
  PlatformShortcut(label: 'Global Search', keys: ['Ctrl', 'K'], category: 'Search', description: 'Open the global command palette'),
  PlatformShortcut(label: 'Create New', keys: ['Ctrl', 'N'], category: 'Editing', description: 'Create a new record in the active context'),
  PlatformShortcut(label: 'Save', keys: ['Ctrl', 'S'], category: 'Editing', description: 'Save the current record or form'),
  PlatformShortcut(label: 'Help', keys: ['Ctrl', '/'], category: 'Accessibility', description: 'Open this cheat sheet'),
  PlatformShortcut(label: 'Reports', keys: ['Ctrl', 'Shift', 'R'], category: 'Reports', description: 'Navigate to the reports module'),
  PlatformShortcut(label: 'AI Assistant', keys: ['Ctrl', 'Shift', 'A'], category: 'AI', description: 'Toggle the AI context panel'),
  PlatformShortcut(label: 'Workflow', keys: ['Ctrl', 'Shift', 'W'], category: 'Workflow', description: 'Open the workflow designer'),
];

class KeyCapWidget extends StatelessWidget {
  final String keyLabel;

  const KeyCapWidget({super.key, required this.keyLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.dividerColor,
            offset: const Offset(0, 2),
            blurRadius: 0,
          )
        ],
      ),
      child: Text(
        keyLabel,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class ShortcutCheatSheetDialog extends StatelessWidget {
  const ShortcutCheatSheetDialog({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return const ShortcutCheatSheetDialog();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group by category
    final Map<String, List<PlatformShortcut>> grouped = {};
    for (var s in globalShortcuts) {
      grouped.putIfAbsent(s.category, () => []).add(s);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.keyboard, size: 24),
                    const SizedBox(width: 12),
                    Text('Keyboard Shortcuts', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: grouped.entries.map((entry) {
                    return SizedBox(
                      width: 250,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(entry.key.toUpperCase(), style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          const SizedBox(height: 12),
                          ...entry.value.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(s.label, style: theme.textTheme.bodyMedium)),
                                Row(
                                  children: s.keys.map((k) => KeyCapWidget(keyLabel: k)).toList(),
                                )
                              ],
                            ),
                          )),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
