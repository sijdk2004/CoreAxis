import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../domain/data_history_model.dart';
import 'providers/data_history_provider.dart';

class DataHistoryScreen extends ConsumerStatefulWidget {
  const DataHistoryScreen({super.key});

  @override
  ConsumerState<DataHistoryScreen> createState() => _DataHistoryScreenState();
}

class _DataHistoryScreenState extends ConsumerState<DataHistoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  DataChangeRecord? _selectedRecord;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dataHistoryProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: _selectedRecord != null
          ? Drawer(
              width: isDesktop ? 600 : MediaQuery.of(context).size.width * 0.9,
              child: _buildDifferenceDrawer(context, _selectedRecord!),
            )
          : null,
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (data) {
          final filteredRecords = data.records.where((record) {
            final query = _searchQuery.toLowerCase();
            return record.entityName.toLowerCase().contains(query) ||
                record.entityType.toLowerCase().contains(query) ||
                record.changedBy.toLowerCase().contains(query) ||
                record.module.toLowerCase().contains(query);
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, theme),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildToolbar(context, theme),
                      const SizedBox(height: 24),
                      _buildDataTable(context, theme, filteredRecords),
                    ],
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.history, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Data Change History', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Track and compare entity modifications across the platform', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting report...')));
            },
            icon: const Icon(LucideIcons.download),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search by entity, user, module...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.filter),
          label: const Text('Filter'),
        ),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context, ThemeData theme, List<DataChangeRecord> records) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
              columns: const [
                DataColumn(label: Text('Entity')),
                DataColumn(label: Text('Changed By')),
                DataColumn(label: Text('Changed On')),
                DataColumn(label: Text('Module')),
                DataColumn(label: Text('Action')),
                DataColumn(label: Text('Actions')),
              ],
              rows: records.map((record) {
                return DataRow(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Icon(_getEntityIcon(record.entityType), size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(record.entityName, style: const TextStyle(fontWeight: FontWeight.w500)),
                              Text(record.entityId, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(record.userAvatarUrl),
                          ),
                          const SizedBox(width: 8),
                          Text(record.changedBy),
                        ],
                      ),
                    ),
                    DataCell(Text(DateFormat('MMM d, y HH:mm').format(record.changedOn))),
                    DataCell(Text(record.module)),
                    DataCell(_buildActionBadge(context, record.action)),
                    DataCell(
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedRecord = record;
                          });
                          Future.delayed(const Duration(milliseconds: 50), () {
                            _scaffoldKey.currentState?.openEndDrawer();
                          });
                        },
                        icon: const Icon(LucideIcons.fileDiff, size: 16),
                        label: const Text('View Difference'),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Showing ${records.length} records', style: theme.textTheme.bodySmall),
                Row(
                  children: [
                    IconButton(icon: const Icon(LucideIcons.chevronLeft, size: 16), onPressed: () {}),
                    const Text('Page 1 of 1'),
                    IconButton(icon: const Icon(LucideIcons.chevronRight, size: 16), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifferenceDrawer(BuildContext context, DataChangeRecord record) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Change Details', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('${record.entityName} (${record.entityId})', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Field Comparison'),
                      Tab(text: 'JSON Viewer'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildFieldComparisonTab(context, theme, record),
                        _buildJsonViewerTab(context, theme, record),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldComparisonTab(BuildContext context, ThemeData theme, DataChangeRecord record) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Modified Fields', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Row(
              children: [
                _buildLegendItem(theme, 'Added', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem(theme, 'Removed', Colors.red),
                const SizedBox(width: 16),
                _buildLegendItem(theme, 'Modified', Colors.orange),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...record.changes.map((change) => _buildFieldChangeRow(theme, change)),
        const SizedBox(height: 32),
        Text('Change Metadata', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildMetadataCard(theme, record),
      ],
    );
  }

  Widget _buildJsonViewerTab(BuildContext context, ThemeData theme, DataChangeRecord record) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Before', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        const JsonEncoder.withIndent('  ').convert(record.rawBeforeJson),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('After', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        const JsonEncoder.withIndent('  ').convert(record.rawAfterJson),
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4), border: Border.all(color: color)),
        ),
        const SizedBox(width: 8),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildFieldChangeRow(ThemeData theme, FieldChange change) {
    Color highlightColor;
    switch (change.changeType) {
      case ChangeType.added:
        highlightColor = Colors.green;
        break;
      case ChangeType.removed:
        highlightColor = Colors.red;
        break;
      case ChangeType.modified:
        highlightColor = Colors.orange;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: highlightColor.withOpacity(0.05),
        border: Border(left: BorderSide(color: highlightColor, width: 4)),
        borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(change.fieldName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              if (change.beforeValue != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      change.beforeValue!,
                      style: const TextStyle(color: Colors.red, decoration: TextDecoration.lineThrough),
                    ),
                  ),
                ),
              if (change.beforeValue != null && change.afterValue != null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(LucideIcons.arrowRight, size: 16),
                ),
              if (change.afterValue != null)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      change.afterValue!,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard(ThemeData theme, DataChangeRecord record) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMetadataRow(theme, 'Action ID', record.id),
            const Divider(),
            _buildMetadataRow(theme, 'Timestamp', DateFormat('yyyy-MM-dd HH:mm:ss').format(record.changedOn)),
            const Divider(),
            _buildMetadataRow(theme, 'Module', record.module),
            const Divider(),
            _buildMetadataRow(theme, 'Actor', record.changedBy),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  IconData _getEntityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'organization':
        return LucideIcons.building;
      case 'user':
        return LucideIcons.user;
      case 'workflow':
        return LucideIcons.gitMerge;
      case 'document':
        return LucideIcons.fileText;
      default:
        return LucideIcons.box;
    }
  }

  Widget _buildActionBadge(BuildContext context, ChangeAction action) {
    final theme = Theme.of(context);
    Color color;
    String text;

    switch (action) {
      case ChangeAction.create:
        color = Colors.green;
        text = 'Created';
        break;
      case ChangeAction.update:
        color = Colors.blue;
        text = 'Updated';
        break;
      case ChangeAction.delete:
        color = Colors.red;
        text = 'Deleted';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
