import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'providers/global_search_provider.dart';
import 'models/global_search_model.dart';

class GlobalSearchDialog extends ConsumerStatefulWidget {
  const GlobalSearchDialog({super.key});

  @override
  ConsumerState<GlobalSearchDialog> createState() => _GlobalSearchDialogState();
}

class _GlobalSearchDialogState extends ConsumerState<GlobalSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalSearchProvider.notifier).clearQuery();
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final state = ref.watch(globalSearchProvider);
    final notifier = ref.read(globalSearchProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Dark Overlay
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                color: Colors.black87, // Darker overlay for focus
              ).animate().fade(duration: 200.ms),
            ),
          ),
          
          // Command Palette
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
              child: Container(
                width: 650,
                constraints: const BoxConstraints(maxHeight: 500),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 100,
                      spreadRadius: 20,
                      offset: const Offset(0, 30),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSearchInput(theme, notifier, isDark),
                    const Divider(height: 1, thickness: 1),
                    Expanded(
                      child: state.query.isEmpty
                          ? _buildEmptyState(theme, state, isDark)
                          : _buildResultsState(theme, state, isDark),
                    ),
                    _buildFooter(theme, isDark),
                  ],
                ),
              ).animate().fade(duration: 200.ms).slideY(begin: -0.05, end: 0, curve: Curves.easeOutCubic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput(ThemeData theme, CommandPaletteNotifier notifier, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(LucideIcons.search, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              onChanged: notifier.updateQuery,
              decoration: InputDecoration(
                hintText: 'Type a command or search...',
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(fontSize: 18, color: isDark ? Colors.grey.shade600 : Colors.grey.shade500),
              ),
              style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.x, size: 20),
              onPressed: () {
                _searchController.clear();
                notifier.clearQuery();
                _searchFocus.requestFocus();
              },
              splashRadius: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, CommandPaletteState state, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (state.allCommands.any((c) => c.group == CommandGroup.recent)) ...[
          _buildSectionHeader('RECENT', theme, isDark),
          ...state.allCommands.where((c) => c.group == CommandGroup.recent).map((r) => _buildResultItem(r, theme, isDark)),
        ],
        if (state.allCommands.any((c) => c.group == CommandGroup.favorites)) ...[
          _buildSectionHeader('FAVORITES', theme, isDark),
          ...state.allCommands.where((c) => c.group == CommandGroup.favorites).map((r) => _buildResultItem(r, theme, isDark)),
        ],
      ],
    );
  }

  Widget _buildResultsState(ThemeData theme, CommandPaletteState state, bool isDark) {
    final results = state.filteredCommands;
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.searchX, size: 48, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No commands found for "${state.query}"', style: theme.textTheme.titleMedium?.copyWith(color: isDark ? Colors.white : Colors.black)),
          ],
        ),
      );
    }

    // Group results
    final grouped = <CommandGroup, List<CommandItem>>{};
    for (var r in results) {
      grouped.putIfAbsent(r.group, () => []).add(r);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, groupIndex) {
        final group = grouped.keys.elementAt(groupIndex);
        final items = grouped[group]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(items.first.groupLabel.toUpperCase(), theme, isDark),
            ...items.map((r) => _buildResultItem(r, theme, isDark)),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildResultItem(CommandItem result, ThemeData theme, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close dialog
        if (result.route != null) {
          context.go(result.route!);
        } else if (result.actionType == 'logout') {
          context.go('/login');
        } else {
          // Mock action notification
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Action executed: ${result.title}')),
          );
        }
      },
      hoverColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              result.icon, 
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              size: 18,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Text(
                    result.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  if (result.subtitle != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '-',
                      style: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        result.subtitle!,
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600, 
                          fontSize: 13
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildShortcutHint('↑↓', 'Navigate', theme, isDark),
          const SizedBox(width: 16),
          _buildShortcutHint('↵', 'Select', theme, isDark),
          const SizedBox(width: 16),
          _buildShortcutHint('esc', 'Close', theme, isDark),
        ],
      ),
    );
  }

  Widget _buildShortcutHint(String key, String action, ThemeData theme, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            key,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          action,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
