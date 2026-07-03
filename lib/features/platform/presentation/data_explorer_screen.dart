import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../domain/data_explorer_model.dart';
import 'providers/data_explorer_provider.dart';

class DataExplorerScreen extends ConsumerWidget {
  const DataExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(dataExplorerProvider);
    final notifier = ref.read(dataExplorerProvider.notifier);

    // Responsive layout checking
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _buildToolbar(context, theme, notifier),
          const Divider(height: 1),
          Expanded(
            child: Row(
              children: [
                if (isDesktop || isTablet)
                  SizedBox(
                    width: 250,
                    child: _buildLeftPanel(context, theme, state, notifier),
                  ),
                if (isDesktop || isTablet)
                  const VerticalDivider(width: 1),
                Expanded(
                  child: _buildCenterGrid(context, theme, state),
                ),
                if (isDesktop)
                  const VerticalDivider(width: 1),
                if (isDesktop)
                  SizedBox(
                    width: 300,
                    child: _buildRightPanel(context, theme, state),
                  ),
              ],
            ),
          ),
        ],
      ),
      // Drawer for mobile view
      drawer: (!isDesktop && !isTablet) ? Drawer(
        child: _buildLeftPanel(context, theme, state, notifier),
      ) : null,
      endDrawer: (!isDesktop) ? Drawer(
        child: _buildRightPanel(context, theme, state),
      ) : null,
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, DataExplorerNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Row(
        children: [
          Text(
            'Data Explorer',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 24),
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => notifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search data...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
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
          // Actions
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.barChart2, size: 16),
            label: const Text('Charts'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.tableProperties, size: 16),
            label: const Text('Pivot'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.download, size: 16),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context, ThemeData theme, DataExplorerState state, DataExplorerNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('ENTITIES', style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          )),
        ),
        _buildEntityItem(theme, state, notifier, ExplorerEntity.users, 'Users', LucideIcons.users),
        _buildEntityItem(theme, state, notifier, ExplorerEntity.organizations, 'Organizations', LucideIcons.building2),
        _buildEntityItem(theme, state, notifier, ExplorerEntity.workflows, 'Workflows', LucideIcons.gitMerge),
        _buildEntityItem(theme, state, notifier, ExplorerEntity.approvals, 'Approvals', LucideIcons.checkCircle),
        _buildEntityItem(theme, state, notifier, ExplorerEntity.notifications, 'Notifications', LucideIcons.bell),
        _buildEntityItem(theme, state, notifier, ExplorerEntity.audit, 'Audit Logs', LucideIcons.history),
        _buildEntityItem(theme, state, notifier, ExplorerEntity.documents, 'Documents', LucideIcons.fileText),
        _buildEntityItem(theme, state, notifier, ExplorerEntity.furnitureErp, 'Furniture ERP', LucideIcons.sofa),
      ],
    );
  }

  Widget _buildEntityItem(ThemeData theme, DataExplorerState state, DataExplorerNotifier notifier, ExplorerEntity entity, String title, IconData icon) {
    final isSelected = state.selectedEntity == entity;
    return ListTile(
      leading: Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant, size: 20),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primary.withAlpha(25),
      onTap: () => notifier.selectEntity(entity),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildCenterGrid(BuildContext context, ThemeData theme, DataExplorerState state) {
    final rows = state.filteredRows;
    final columns = state.data.columns;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
          child: Row(
            children: [
              Icon(LucideIcons.database, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Data Grid View - ${_capitalize(state.selectedEntity.name)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text('${rows.length} rows', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.searchX, size: 48, color: theme.dividerColor),
                      const SizedBox(height: 16),
                      Text('No results found', style: theme.textTheme.titleMedium),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 550), // Approximation of left+right panel width
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surface),
                        columns: columns.map((col) {
                          return DataColumn(
                            label: Row(
                              children: [
                                Text(col.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                Icon(LucideIcons.arrowUpDown, size: 12, color: theme.dividerColor),
                              ],
                            ),
                          );
                        }).toList(),
                        rows: rows.map((row) {
                          return DataRow(
                            cells: columns.map((col) {
                              return DataCell(
                                Text(row[col.key]?.toString() ?? '-'),
                              );
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context, ThemeData theme, DataExplorerState state) {
    final columns = state.data.columns;
    final rows = state.data.rows;
    
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(50),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Insights', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildStatCard(theme, 'Total Records', rows.length.toString(), LucideIcons.database),
          const SizedBox(height: 16),
          _buildStatCard(theme, 'Data Columns', columns.length.toString(), LucideIcons.columns),
          const SizedBox(height: 32),
          Text('Field Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...columns.map((col) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      col.type == int ? LucideIcons.hash : LucideIcons.caseUpper,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(col.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text('100% fill rate', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';
}
