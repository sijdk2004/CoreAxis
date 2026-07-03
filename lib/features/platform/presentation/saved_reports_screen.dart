import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../domain/saved_report_model.dart';
import 'providers/saved_reports_provider.dart';

class SavedReportsScreen extends ConsumerWidget {
  const SavedReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(savedReportsProvider);
    final notifier = ref.read(savedReportsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme),
          _buildStatisticsCards(context, theme, state),
          const Divider(height: 1),
          _buildToolbar(context, theme, state, notifier),
          const Divider(height: 1),
          Expanded(
            child: _buildTable(context, theme, state, notifier),
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
            'Saved Reports',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage, view, and organize your saved reports and templates.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, ThemeData theme, SavedReportsState state) {
    final total = state.reports.where((r) => r.status != ReportStatus.archived).length;
    final favorites = state.reports.where((r) => r.isFavorite && r.status != ReportStatus.archived).length;
    final private = state.reports.where((r) => !r.isShared && r.status != ReportStatus.archived).length;
    final shared = state.reports.where((r) => r.isShared && r.status != ReportStatus.archived).length;
    final archived = state.reports.where((r) => r.status == ReportStatus.archived).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildStatCard(context, theme, 'Saved Reports', total.toString(), LucideIcons.fileText, Colors.blue)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(context, theme, 'Favorites', favorites.toString(), LucideIcons.star, Colors.orange)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(context, theme, 'Private', private.toString(), LucideIcons.lock, Colors.indigo)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(context, theme, 'Shared', shared.toString(), LucideIcons.users, Colors.green)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(context, theme, 'Archived', archived.toString(), LucideIcons.archive, Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, SavedReportsState state, SavedReportsNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => notifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search reports...',
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
          const SizedBox(width: 16),
          _buildFilterChip(theme, state, notifier, 'All', 'all'),
          const SizedBox(width: 8),
          _buildFilterChip(theme, state, notifier, 'Favorites', 'favorites'),
          const SizedBox(width: 8),
          _buildFilterChip(theme, state, notifier, 'Recent', 'recent'),
          const SizedBox(width: 8),
          _buildFilterChip(theme, state, notifier, 'Shared', 'shared'),
          const SizedBox(width: 8),
          _buildFilterChip(theme, state, notifier, 'Archived', 'archived'),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              // Mock action to create new report
            },
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('New Report'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, SavedReportsState state, SavedReportsNotifier notifier, String label, String filterValue) {
    final isSelected = state.filter == filterValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => notifier.setFilter(filterValue),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primary.withAlpha(25),
      checkmarkColor: theme.colorScheme.primary,
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

  Widget _buildTable(BuildContext context, ThemeData theme, SavedReportsState state, SavedReportsNotifier notifier) {
    final reports = state.filteredReports;

    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.fileSearch, size: 64, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text('No reports found', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Try adjusting your filters or search query.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(theme.colorScheme.surface),
            dividerThickness: 1,
            dataRowMaxHeight: 64,
            columns: const [
              DataColumn(label: Text('Report', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Owner', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Created', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Last Run', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Views', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: reports.map((report) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            report.isFavorite ? LucideIcons.star : LucideIcons.star,
                            color: report.isFavorite ? Colors.orange : theme.dividerColor,
                            size: 20,
                          ),
                          onPressed: () => notifier.toggleFavorite(report.id),
                        ),
                        const SizedBox(width: 8),
                        Icon(LucideIcons.fileText, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(report.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: theme.colorScheme.primary.withAlpha(50),
                          child: Text(
                            report.owner.substring(0, 1),
                            style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(report.owner),
                      ],
                    ),
                  ),
                  DataCell(Text(DateFormat('MMM dd, yyyy').format(report.created))),
                  DataCell(Text(report.lastRun != null ? DateFormat('MMM dd, yyyy').format(report.lastRun!) : 'Never')),
                  DataCell(Text(report.views.toString())),
                  DataCell(_buildStatusBadge(theme, report.status)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(LucideIcons.externalLink, size: 18),
                          tooltip: 'Open',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.copy, size: 18),
                          tooltip: 'Duplicate',
                          onPressed: () => notifier.duplicateReport(report.id),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(LucideIcons.moreVertical, size: 18),
                          onSelected: (value) {
                            switch (value) {
                              case 'rename':
                                _showRenameDialog(context, report, notifier);
                                break;
                              case 'archive':
                                notifier.archiveReport(report.id);
                                break;
                              case 'delete':
                                notifier.deleteReport(report.id);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'rename', child: Text('Rename')),
                            if (report.status != ReportStatus.archived)
                              const PopupMenuItem(value: 'archive', child: Text('Archive')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, ReportStatus status) {
    Color color;
    String text;

    switch (status) {
      case ReportStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case ReportStatus.draft:
        color = Colors.orange;
        text = 'Draft';
        break;
      case ReportStatus.archived:
        color = Colors.grey;
        text = 'Archived';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, SavedReportModel report, SavedReportsNotifier notifier) {
    final controller = TextEditingController(text: report.name);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Report'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Report Name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                notifier.renameReport(report.id, controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
