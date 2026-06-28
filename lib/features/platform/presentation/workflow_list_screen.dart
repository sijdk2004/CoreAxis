import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'providers/workflow_list_provider.dart';

class WorkflowListScreen extends ConsumerStatefulWidget {
  const WorkflowListScreen({super.key});

  @override
  ConsumerState<WorkflowListScreen> createState() => _WorkflowListScreenState();
}

class _WorkflowListScreenState extends ConsumerState<WorkflowListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(workflowListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildSliverHeader(theme),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildStatsRow(theme, state),
                      const SizedBox(height: 24),
                      _buildMainContent(theme, state),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverHeader(ThemeData theme) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
      elevation: 0,
      scrolledUnderElevation: 1,
      toolbarHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.listTree, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Workflow List', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Manage configurable workflows and automation processes', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.download, size: 16),
                label: const Text('Export'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.upload, size: 16),
                label: const Text('Import Template'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Create Workflow'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme, WorkflowListState state) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(theme, 'Total Workflows', state.totalCount.toString(), LucideIcons.layers)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(theme, 'Active & Running', state.runningCount.toString(), LucideIcons.playCircle, color: Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(theme, 'Published', state.publishedCount.toString(), LucideIcons.checkCircle2, color: Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(theme, 'Draft', state.draftCount.toString(), LucideIcons.fileEdit, color: Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(theme, 'Archived', state.archivedCount.toString(), LucideIcons.archive, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, {Color? color}) {
    final iconColor = color ?? theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, WorkflowListState state) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildToolbar(theme, state),
          const Divider(height: 1),
          if (state.selectedIds.isNotEmpty) _buildBulkActionBar(theme, state),
          if (state.selectedIds.isNotEmpty) const Divider(height: 1),
          _buildDataTable(theme, state),
          const Divider(height: 1),
          _buildPaginationFooter(theme, state),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme, WorkflowListState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref.read(workflowListProvider.notifier).search(val),
              decoration: InputDecoration(
                hintText: 'Search workflows by name or code...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
              ),
            ),
          ),
          const Spacer(),
          _buildDropdownFilter(
            theme,
            value: state.filterStatus ?? 'All',
            items: ['All', 'Active', 'Inactive', 'Draft', 'Published', 'Archived'],
            onChanged: (val) => ref.read(workflowListProvider.notifier).setFilterStatus(val == 'All' ? null : val),
            label: 'Status',
          ),
          const SizedBox(width: 12),
          _buildDropdownFilter(
            theme,
            value: state.filterCategory ?? 'All Categories',
            items: ['All Categories', 'Sales', 'Purchase', 'Manufacturing', 'Inventory', 'Finance', 'HR', 'Quality', 'Custom'],
            onChanged: (val) => ref.read(workflowListProvider.notifier).setFilterCategory(val == 'All Categories' ? null : val),
            label: 'Category',
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            tooltip: 'View Columns',
            icon: const Icon(LucideIcons.columns),
            itemBuilder: (context) {
              final allCols = ['Workflow Name', 'Workflow Code', 'Category', 'Version', 'Steps', 'Status', 'Last Modified', 'Actions'];
              return allCols.map((c) => CheckedPopupMenuItem<String>(
                checked: state.visibleColumns.contains(c),
                value: c,
                child: Text(c),
              )).toList();
            },
            onSelected: (col) => ref.read(workflowListProvider.notifier).toggleColumn(col),
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCcw, size: 20),
            onPressed: () => ref.read(workflowListProvider.notifier).loadWorkflows(),
          )
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(ThemeData theme, {required String value, required List<String> items, required Function(String?) onChanged, required String label}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildBulkActionBar(ThemeData theme, WorkflowListState state) {
    return Container(
      color: theme.colorScheme.primaryContainer.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Text('${state.selectedIds.length} workflows selected', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => ref.read(workflowListProvider.notifier).selectAll(false),
            icon: const Icon(LucideIcons.x, size: 16),
            label: const Text('Clear'),
          ),
          const SizedBox(width: 12),
          FilledButton.tonalIcon(
            onPressed: () => ref.read(workflowListProvider.notifier).bulkDelete(),
            icon: const Icon(LucideIcons.trash2, size: 16),
            label: const Text('Delete Selected'),
            style: FilledButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme, WorkflowListState state) {
    if (state.filteredWorkflows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: Text('No workflows found matching your criteria.')),
      );
    }

    final allSelected = state.filteredWorkflows.isNotEmpty &&
        state.selectedIds.length == state.filteredWorkflows.length;

    // Fixed column widths (except Workflow Name which is computed dynamically)
    const double checkW  = 48;
    const double codeW   = 120;
    const double catW    = 100;
    const double verW    = 72;
    const double stepsW  = 56;
    const double statusW = 100;
    const double modW    = 140;
    const double actW    = 48;

    return LayoutBuilder(builder: (context, constraints) {
      final totalFixed = checkW + actW +
          (state.visibleColumns.contains('Workflow Code') ? codeW : 0) +
          (state.visibleColumns.contains('Category') ? catW : 0) +
          (state.visibleColumns.contains('Version') ? verW : 0) +
          (state.visibleColumns.contains('Steps') ? stepsW : 0) +
          (state.visibleColumns.contains('Status') ? statusW : 0) +
          (state.visibleColumns.contains('Last Modified') ? modW : 0);

      // Workflow Name absorbs all remaining space (min 140)
      final nameW = state.visibleColumns.contains('Workflow Name')
          ? (constraints.maxWidth - totalFixed).clamp(140.0, double.infinity)
          : 0.0;

      final headerBg = theme.colorScheme.surfaceContainerHighest.withOpacity(0.3);

      Widget buildHeaderRow() => Container(
        color: headerBg,
        height: 48,
        child: Row(
          children: [
            // Checkbox header
            SizedBox(
              width: checkW,
              child: Center(
                child: Checkbox(
                  value: allSelected,
                  onChanged: (val) =>
                      ref.read(workflowListProvider.notifier).selectAll(val ?? false),
                ),
              ),
            ),
            if (state.visibleColumns.contains('Workflow Name'))
              _headerCell('Workflow Name', nameW),
            if (state.visibleColumns.contains('Workflow Code'))
              _headerCell('Code', codeW),
            if (state.visibleColumns.contains('Category'))
              _headerCell('Category', catW),
            if (state.visibleColumns.contains('Version'))
              _headerCell('Version', verW),
            if (state.visibleColumns.contains('Steps'))
              _headerCell('Steps', stepsW),
            if (state.visibleColumns.contains('Status'))
              _headerCell('Status', statusW),
            if (state.visibleColumns.contains('Last Modified'))
              _headerCell('Last Modified', modW),
            // Actions header
            SizedBox(
              width: actW,
              child: const Center(
                child: Text('Actions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      );

      Widget buildDataRow(dynamic w) {
        final isSelected = state.selectedIds.contains(w.id);
        Color statusColor = Colors.grey;
        if (w.status == 'Published') statusColor = Colors.green;
        if (w.status == 'Active') statusColor = Colors.blue;
        if (w.status == 'Draft') statusColor = Colors.orange;
        if (w.status == 'Archived') statusColor = Colors.grey;

        return Container(
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withOpacity(0.15)
                : null,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor.withOpacity(0.4)),
            ),
          ),
          height: 64,
          child: Row(
            children: [
              SizedBox(
                width: checkW,
                child: Center(
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) =>
                        ref.read(workflowListProvider.notifier).toggleSelection(w.id),
                  ),
                ),
              ),
              if (state.visibleColumns.contains('Workflow Name'))
                SizedBox(
                  width: nameW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                        Text('By ${w.createdBy}',
                            style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ],
                    ),
                  ),
                ),
              if (state.visibleColumns.contains('Workflow Code'))
                SizedBox(
                  width: codeW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(w.code,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              if (state.visibleColumns.contains('Category'))
                SizedBox(
                  width: catW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(w.category,
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              if (state.visibleColumns.contains('Version'))
                SizedBox(
                  width: verW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(w.version,
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              if (state.visibleColumns.contains('Steps'))
                SizedBox(
                  width: stepsW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text('${w.steps}',
                        style: const TextStyle(fontSize: 13)),
                  ),
                ),
              if (state.visibleColumns.contains('Status'))
                SizedBox(
                  width: statusW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Text(w.status,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              if (state.visibleColumns.contains('Last Modified'))
                SizedBox(
                  width: modW,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                        DateFormat('MMM d, yyyy HH:mm')
                            .format(w.lastModified),
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              // Always-visible sticky Actions
              SizedBox(
                width: actW,
                child: Center(child: _buildActionMenu(theme, w.id)),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          buildHeaderRow(),
          ...state.filteredWorkflows.map(buildDataRow),
        ],
      );
    });
  }

  Widget _headerCell(String label, double width) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis),
      ),
    );
  }


  Widget _buildActionMenu(ThemeData theme, String id) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 20),
      onSelected: (action) {
        if (action == 'view') context.push('/platform/workflows/$id');
        if (action == 'clone') ref.read(workflowListProvider.notifier).cloneWorkflow(id);
        if (action == 'publish') ref.read(workflowListProvider.notifier).publishWorkflow(id);
        if (action == 'archive') ref.read(workflowListProvider.notifier).archiveWorkflow(id);
        if (action == 'delete') ref.read(workflowListProvider.notifier).deleteWorkflow(id);
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'view', child: Row(children: [Icon(LucideIcons.eye, size: 16), SizedBox(width: 8), Text('View Details')])),
        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(LucideIcons.edit2, size: 16), SizedBox(width: 8), Text('Edit Workflow')])),
        const PopupMenuItem(value: 'clone', child: Row(children: [Icon(LucideIcons.copy, size: 16), SizedBox(width: 8), Text('Clone (Mock)')])),
        const PopupMenuItem(value: 'publish', child: Row(children: [Icon(LucideIcons.uploadCloud, size: 16), SizedBox(width: 8), Text('Publish (Mock)')])),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'archive', child: Row(children: [Icon(LucideIcons.archive, size: 16), SizedBox(width: 8), Text('Archive (Mock)')])),
        PopupMenuItem(value: 'delete', child: Row(children: const [Icon(LucideIcons.trash2, size: 16, color: Colors.red), SizedBox(width: 8), Text('Delete (Mock)', style: TextStyle(color: Colors.red))])),
      ],
    );
  }

  Widget _buildPaginationFooter(ThemeData theme, WorkflowListState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Rows per page:'),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: 10,
              items: [10, 25, 50].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
              onChanged: (_) {},
            ),
          ),
          const SizedBox(width: 24),
          Text('1-${state.filteredWorkflows.length} of ${state.filteredWorkflows.length}'),
          const SizedBox(width: 24),
          IconButton(icon: const Icon(LucideIcons.chevronLeft), onPressed: null),
          IconButton(icon: const Icon(LucideIcons.chevronRight), onPressed: null),
        ],
      ),
    );
  }
}
