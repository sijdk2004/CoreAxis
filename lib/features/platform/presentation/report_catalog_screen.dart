import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import '../domain/report_catalog_model.dart';
import 'providers/report_catalog_provider.dart';

class ReportCatalogScreen extends ConsumerWidget {
  const ReportCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(reportCatalogProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToolbar(context, ref, theme, state, isDesktop),
          _buildCategories(context, ref, theme, state),
          Expanded(
            child: _buildContent(context, ref, theme, state),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref, ThemeData theme, ReportCatalogState state, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Catalog',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Central repository for all platform reports and dashboards.',
                      style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (isDesktop) ...[
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.download),
                  label: const Text('Export'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.upload),
                  label: const Text('Import'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('Create Report'),
                ),
              ] else ...[
                IconButton(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.plusCircle, size: 28),
                  color: theme.colorScheme.primary,
                ),
              ]
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (value) => ref.read(reportCatalogProvider.notifier).setSearchQuery(value),
                  decoration: InputDecoration(
                    hintText: 'Search reports by name or description...',
                    prefixIcon: const Icon(LucideIcons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Grid', icon: Icon(LucideIcons.layoutGrid)),
                  ButtonSegment(value: 'List', icon: Icon(LucideIcons.list)),
                  ButtonSegment(value: 'Table', icon: Icon(LucideIcons.table)),
                ],
                selected: {state.viewMode},
                onSelectionChanged: (set) => ref.read(reportCatalogProvider.notifier).setViewMode(set.first),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Favorites Only'),
                selected: state.showOnlyFavorites,
                onSelected: (_) => ref.read(reportCatalogProvider.notifier).toggleShowOnlyFavorites(),
                avatar: const Icon(LucideIcons.star, size: 16),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(LucideIcons.refreshCw),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(BuildContext context, WidgetRef ref, ThemeData theme, ReportCatalogState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryChip(context, ref, theme, state, 'All', null),
            const SizedBox(width: 8),
            ...ReportCategory.values.map((c) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: _buildCategoryChip(context, ref, theme, state, c.label, c.icon),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, WidgetRef ref, ThemeData theme, ReportCatalogState state, String label, IconData? icon) {
    final isSelected = state.selectedCategory == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => ref.read(reportCatalogProvider.notifier).setSelectedCategory(label),
      avatar: icon != null ? Icon(icon, size: 16) : null,
      selectedColor: theme.colorScheme.primaryContainer,
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ThemeData theme, ReportCatalogState state) {
    final items = ref.read(reportCatalogProvider.notifier).filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No reports found', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Try adjusting your search or category filters.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return switch (state.viewMode) {
      'List' => _buildListView(context, ref, theme, items),
      'Table' => _buildTableView(context, ref, theme, items),
      _ => _buildGridView(context, ref, theme, items), // Grid is default
    };
  }

  Widget _buildGridView(BuildContext context, WidgetRef ref, ThemeData theme, List<ReportCatalogItem> items) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final crossAxisCount = isDesktop ? 4 : (ResponsiveBreakpoints.of(context).largerThan(MOBILE) ? 2 : 1);

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item.category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.category.icon, color: item.category.color, size: 20),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(item.isFavorite ? LucideIcons.star : LucideIcons.star, color: item.isFavorite ? Colors.amber : null),
                            iconSize: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => ref.read(reportCatalogProvider.notifier).toggleFavorite(item.id),
                          ),
                          const SizedBox(width: 8),
                          _buildActionMenu(context, ref, theme, item),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusBadge(theme, item.status),
                      Text(
                        'Last run: ${DateFormat('MMM d, yyyy').format(item.lastRun)}',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.user, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(item.owner, style: theme.textTheme.bodySmall),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(LucideIcons.eye, size: 14, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text('${item.views}', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListView(BuildContext context, WidgetRef ref, ThemeData theme, List<ReportCatalogItem> items) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: item.category.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.category.icon, color: item.category.color),
            ),
            title: Text(item.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(theme, item.status),
                    const SizedBox(width: 16),
                    Icon(LucideIcons.user, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(item.owner, style: theme.textTheme.labelMedium),
                    const SizedBox(width: 16),
                    Icon(LucideIcons.building, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(item.organization, style: theme.textTheme.labelMedium),
                    const SizedBox(width: 16),
                    Icon(LucideIcons.calendar, size: 14, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('Last run: ${DateFormat('MMM d, yyyy').format(item.lastRun)}', style: theme.textTheme.labelMedium),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(item.isFavorite ? LucideIcons.star : LucideIcons.star, color: item.isFavorite ? Colors.amber : null),
                  onPressed: () => ref.read(reportCatalogProvider.notifier).toggleFavorite(item.id),
                ),
                _buildActionMenu(context, ref, theme, item),
              ],
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  Widget _buildTableView(BuildContext context, WidgetRef ref, ThemeData theme, List<ReportCatalogItem> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('Report Name')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Owner')),
              DataColumn(label: Text('Organization')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Last Run')),
              DataColumn(label: Text('Views', textAlign: TextAlign.right)),
              DataColumn(label: Text('Actions')),
            ],
            rows: items.map((item) {
              return DataRow(
                onSelectChanged: (_) {},
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Icon(item.isFavorite ? LucideIcons.star : LucideIcons.fileText, color: item.isFavorite ? Colors.amber : theme.colorScheme.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: item.category.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(item.category.label, style: TextStyle(color: item.category.color, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  DataCell(Text(item.owner)),
                  DataCell(Text(item.organization)),
                  DataCell(_buildStatusBadge(theme, item.status)),
                  DataCell(Text(DateFormat('MMM d, yyyy HH:mm').format(item.lastRun))),
                  DataCell(Text('${item.views}')),
                  DataCell(_buildActionMenu(context, ref, theme, item)),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, ReportStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withOpacity(0.2)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context, WidgetRef ref, ThemeData theme, ReportCatalogItem item) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 20),
      onSelected: (value) {
        if (value == 'Duplicate') {
          ref.read(reportCatalogProvider.notifier).duplicateReport(item.id);
        } else if (value == 'Archive') {
          ref.read(reportCatalogProvider.notifier).archiveReport(item.id);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'Open', child: Row(children: [Icon(LucideIcons.folderOpen, size: 16), SizedBox(width: 8), Text('Open')])),
        const PopupMenuItem(value: 'Edit', child: Row(children: [Icon(LucideIcons.edit2, size: 16), SizedBox(width: 8), Text('Edit')])),
        const PopupMenuItem(value: 'Duplicate', child: Row(children: [Icon(LucideIcons.copy, size: 16), SizedBox(width: 8), Text('Duplicate')])),
        const PopupMenuItem(value: 'Share', child: Row(children: [Icon(LucideIcons.share2, size: 16), SizedBox(width: 8), Text('Share')])),
        const PopupMenuItem(value: 'Schedule', child: Row(children: [Icon(LucideIcons.calendarClock, size: 16), SizedBox(width: 8), Text('Schedule')])),
        const PopupMenuItem(value: 'Export', child: Row(children: [Icon(LucideIcons.download, size: 16), SizedBox(width: 8), Text('Export')])),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'Archive', child: Row(children: [Icon(LucideIcons.archive, size: 16, color: Colors.red), SizedBox(width: 8), Text('Archive', style: TextStyle(color: Colors.red))])),
      ],
    );
  }
}
