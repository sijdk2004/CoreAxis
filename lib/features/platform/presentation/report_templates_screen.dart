import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../domain/report_template_model.dart';
import 'providers/report_templates_provider.dart';

class ReportTemplatesScreen extends ConsumerWidget {
  const ReportTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(reportTemplatesProvider);
    final notifier = ref.read(reportTemplatesProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme),
          const Divider(height: 1),
          _buildToolbar(context, theme, state, notifier),
          const Divider(height: 1),
          _buildCategories(context, theme, state, notifier),
          const Divider(height: 1),
          Expanded(
            child: _buildGrid(context, theme, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Templates',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jumpstart your reporting with pre-built templates designed for your industry.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, ReportTemplatesState state, ReportTemplatesNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => notifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search templates...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const Spacer(),
          FilterChip(
            label: const Text('Favorites Only'),
            selected: state.showOnlyFavorites,
            onSelected: (_) => notifier.toggleShowFavorites(),
            avatar: Icon(
              state.showOnlyFavorites ? LucideIcons.star : LucideIcons.star,
              color: state.showOnlyFavorites ? Colors.orange : theme.dividerColor,
              size: 16,
            ),
            backgroundColor: theme.colorScheme.surface,
            selectedColor: theme.colorScheme.primary.withAlpha(25),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: state.showOnlyFavorites ? theme.colorScheme.primary : theme.dividerColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, ThemeData theme, ReportTemplatesState state, ReportTemplatesNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          _buildCategoryChip(theme, state, notifier, null, 'All Categories'),
          const SizedBox(width: 8),
          ...TemplateCategory.values.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildCategoryChip(theme, state, notifier, category, _capitalize(category.name)),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ThemeData theme, ReportTemplatesState state, ReportTemplatesNotifier notifier, TemplateCategory? category, String label) {
    final isSelected = state.selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected || category == null) {
          notifier.setCategory(category);
        }
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withAlpha(25),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, ThemeData theme, ReportTemplatesState state, ReportTemplatesNotifier notifier) {
    final templates = state.filteredTemplates;

    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.layoutTemplate, size: 64, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text('No templates found', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Try adjusting your search or category filters.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    // Grid layout adjustments based on screen width
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount = 4;
    if (width < 800) crossAxisCount = 1;
    else if (width < 1200) crossAxisCount = 2;
    else if (width < 1600) crossAxisCount = 3;

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.85,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(context, theme, template, notifier);
      },
    );
  }

  Widget _buildTemplateCard(BuildContext context, ThemeData theme, ReportTemplateModel template, ReportTemplatesNotifier notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withAlpha(50)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preview Area
          Expanded(
            flex: 3,
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      LucideIcons.layoutDashboard,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(50),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        template.isFavorite ? LucideIcons.star : LucideIcons.star,
                        color: template.isFavorite ? Colors.orange : theme.dividerColor,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface.withAlpha(200),
                      ),
                      onPressed: () => notifier.toggleFavorite(template.id),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _buildComplexityBadge(theme, template.complexity),
                  ),
                ],
              ),
            ),
          ),
          // Info Area
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    template.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Meta Info
                  Row(
                    children: [
                      Icon(LucideIcons.layoutGrid, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text('${template.widgetCount} widgets', style: theme.textTheme.bodySmall),
                      const Spacer(),
                      Icon(LucideIcons.clock, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(template.estimatedTime, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Mock preview action
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Preview'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Mock use template action
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Use Template'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => notifier.cloneTemplate(template.id),
                        icon: const Icon(LucideIcons.copy, size: 20),
                        tooltip: 'Clone Template',
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplexityBadge(ThemeData theme, ComplexityLevel complexity) {
    Color color;
    String text;

    switch (complexity) {
      case ComplexityLevel.low:
        color = Colors.green;
        text = 'Low';
        break;
      case ComplexityLevel.medium:
        color = Colors.orange;
        text = 'Medium';
        break;
      case ComplexityLevel.high:
        color = Colors.red;
        text = 'High';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(220),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.zap, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';
}
