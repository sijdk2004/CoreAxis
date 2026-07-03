import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../domain/models/audit_explorer_model.dart';
import 'providers/audit_explorer_provider.dart';

class AuditExplorerScreen extends ConsumerWidget {
  const AuditExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncState = ref.watch(auditExplorerProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Audit Explorer'),
        backgroundColor: Colors.transparent,
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          return Column(
            children: [
              _buildToolbar(context, ref, state, isDesktop),
              _buildQuickFilters(context, ref, state),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildContent(context, state),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms);
        },
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref, AuditExplorerState state, bool isDesktop) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: isDesktop ? 1 : 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search audit events...',
                prefixIcon: const Icon(LucideIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => ref.read(auditExplorerProvider.notifier).setSearchQuery(val),
            ),
          ),
          if (isDesktop) const Spacer(),
          const SizedBox(width: 16),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'table', icon: Icon(LucideIcons.table)),
              ButtonSegment(value: 'card', icon: Icon(LucideIcons.layoutGrid)),
              ButtonSegment(value: 'timeline', icon: Icon(LucideIcons.list)),
            ],
            selected: {state.viewMode},
            onSelectionChanged: (set) => ref.read(auditExplorerProvider.notifier).setViewMode(set.first),
            showSelectedIcon: false,
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.filter),
            label: const Text('Filters'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.download),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context, WidgetRef ref, AuditExplorerState state) {
    final filters = ['All', 'Info', 'Warning', 'Critical', 'Error', 'Users', 'Organizations', 'Tenants', 'RBAC', 'Workflows', 'Approvals', 'Documents'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              label: Text(f),
              selected: state.selectedFilter == f,
              onSelected: (selected) {
                if (selected) {
                  ref.read(auditExplorerProvider.notifier).setFilter(f);
                } else {
                  ref.read(auditExplorerProvider.notifier).setFilter('All');
                }
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuditExplorerState state) {
    if (state.items.isEmpty) {
      return const Center(child: Text('No audit events found.'));
    }

    switch (state.viewMode) {
      case 'card':
        return _buildCardView(context, state);
      case 'timeline':
        return _buildTimelineView(context, state);
      case 'table':
      default:
        return _buildTableView(context, state);
    }
  }

  Widget _buildTableView(BuildContext context, AuditExplorerState state) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
          columns: const [
            DataColumn(label: Text('Audit ID')),
            DataColumn(label: Text('Timestamp')),
            DataColumn(label: Text('Severity')),
            DataColumn(label: Text('Action')),
            DataColumn(label: Text('User')),
            DataColumn(label: Text('Module')),
            DataColumn(label: Text('Entity')),
            DataColumn(label: Text('Org / Tenant')),
            DataColumn(label: Text('Network / Device')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.items.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.id, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                DataCell(Text(item.timestamp)),
                DataCell(_buildSeverityBadge(item.severity)),
                DataCell(Text(item.action, style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(Text(item.user)),
                DataCell(Text(item.module)),
                DataCell(Text(item.entity)),
                DataCell(Text('${item.organization}\n${item.tenant}')),
                DataCell(Text('${item.ipAddress}\n${item.device}')),
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.eye, size: 18), 
                      onPressed: () => context.push('/platform/audit/entity/${item.id}'), 
                      tooltip: 'View Details',
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.fileDiff, size: 18), 
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Compare Changes coming soon')));
                      }, 
                      tooltip: 'Compare Changes',
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardView(BuildContext context, AuditExplorerState state) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 200,
      ),
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
          ),
          child: InkWell(
            onTap: () => context.push('/platform/audit/entity/${item.id}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.id, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                    _buildSeverityBadge(item.severity),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${item.module} - ${item.entity}', style: const TextStyle(color: Colors.grey)),
                const Spacer(),
                Row(
                  children: [
                    const Icon(LucideIcons.user, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(item.user, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    const Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(item.timestamp.split(' ').first, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

  Widget _buildTimelineView(BuildContext context, AuditExplorerState state) {
    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(item.timestamp.split(' ').last, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (index != state.items.length - 1)
                    Container(
                      width: 2,
                      height: 80,
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            _buildSeverityBadge(item.severity),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('${item.user} on ${item.module} -> ${item.entity}'),
                        const SizedBox(height: 8),
                        Text('${item.ipAddress} | ${item.device} | ${item.organization}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'error':
        color = Colors.red;
        break;
      case 'warning':
        color = Colors.orange;
        break;
      case 'info':
      default:
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(severity.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
