import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/notification_template_model.dart';
import 'providers/notification_template_provider.dart';

class NotificationTemplateScreen extends ConsumerWidget {
  const NotificationTemplateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationTemplateProvider);
    final notifier = ref.read(notificationTemplateProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme, state, notifier),
                  const SizedBox(height: 24),
                  _buildCategories(theme, state, notifier),
                  const SizedBox(height: 24),
                  _buildTable(context, theme, state, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, NotificationTemplateState state, NotificationTemplateNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Template Management', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildToolbar(context, theme, state, notifier),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Template Management', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            _buildToolbar(context, theme, state, notifier),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, NotificationTemplateState state, NotificationTemplateNotifier notifier) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            onChanged: notifier.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search templates...',
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {}, // Mock Import
          icon: const Icon(LucideIcons.upload, size: 16),
          label: const Text('Import'),
        ),
        OutlinedButton.icon(
          onPressed: () {}, // Mock Export
          icon: const Icon(LucideIcons.download, size: 16),
          label: const Text('Export'),
        ),
        FilledButton.icon(
          onPressed: () => context.go('/platform/notifications/templates/editor/new'),
          icon: const Icon(LucideIcons.plus, size: 16),
          label: const Text('Create Template'),
        ),
      ],
    );
  }

  Widget _buildCategories(ThemeData theme, NotificationTemplateState state, NotificationTemplateNotifier notifier) {
    final categories = ['All', 'Workflow', 'Approval', 'Sales', 'Inventory', 'Finance', 'Production', 'System', 'AI'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = state.activeCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) notifier.setActiveCategory(cat);
              },
              showCheckmark: false,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTable(BuildContext context, ThemeData theme, NotificationTemplateState state, NotificationTemplateNotifier notifier) {
    final templates = state.filteredTemplates;

    if (templates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 64.0),
          child: Column(
            children: [
              Icon(LucideIcons.fileCode, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(height: 24),
              Text('No templates found', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Try adjusting your search or category filters.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
          dataRowMinHeight: 56,
          dataRowMaxHeight: 56,
          columns: const [
            DataColumn(label: Text('Template Name')),
            DataColumn(label: Text('Code')),
            DataColumn(label: Text('Channel')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Last Updated')),
            DataColumn(label: Text('Actions')),
          ],
          rows: templates.map((template) {
            return DataRow(
              cells: [
                DataCell(
                  Text(template.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(template.code, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                  )
                ),
                DataCell(_buildChannelBadge(template.channel, theme)),
                DataCell(Text(template.category)),
                DataCell(_buildStatusBadge(template.status, theme)),
                DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(template.updatedAt))),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.edit, size: 18),
                        onPressed: () => context.go('/platform/notifications/templates/editor/${template.id}'),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.copy, size: 18),
                        onPressed: () => notifier.duplicateTemplate(template.id),
                        tooltip: 'Duplicate',
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                        onPressed: () {
                          // Mock delete without confirmation for brevity
                          notifier.deleteTemplate(template.id);
                        },
                        tooltip: 'Delete',
                      ),
                    ],
                  )
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChannelBadge(String channel, ThemeData theme) {
    IconData icon;
    Color color;
    switch (channel) {
      case 'Email': icon = LucideIcons.mail; color = Colors.blue; break;
      case 'SMS': icon = LucideIcons.messageSquare; color = Colors.green; break;
      case 'Push': icon = LucideIcons.smartphone; color = Colors.purple; break;
      case 'WhatsApp': icon = LucideIcons.messageCircle; color = Colors.teal; break;
      default: icon = LucideIcons.bell; color = Colors.grey;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(channel, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    if (status == 'Active') color = Colors.green;
    else if (status == 'Draft') color = Colors.orange;
    else color = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
