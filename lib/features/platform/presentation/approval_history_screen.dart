import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/approval_history_record.dart';
import 'providers/approval_history_provider.dart';

class ApprovalHistoryScreen extends ConsumerStatefulWidget {
  const ApprovalHistoryScreen({super.key});

  @override
  ConsumerState<ApprovalHistoryScreen> createState() => _ApprovalHistoryScreenState();
}

class _ApprovalHistoryScreenState extends ConsumerState<ApprovalHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(approvalHistoryProvider);
    final notifier = ref.read(approvalHistoryProvider.notifier);
    final filteredRecords = notifier.filteredRecords;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Approval History', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('View completed, rejected, and cancelled approval records.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            
            _buildStatisticsCards(context, theme, notifier.statistics),
            const SizedBox(height: 32),
            
            _buildToolbar(context, theme, state, notifier),
            const SizedBox(height: 24),
            
            _buildContentArea(context, theme, state, filteredRecords),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, ThemeData theme, Map<String, String> stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 5 : (constraints.maxWidth > 800 ? 3 : 2);
        final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: stats.entries.map((e) {
            IconData icon;
            Color color;
            switch (e.key) {
              case 'Approved': icon = LucideIcons.checkCircle; color = Colors.green; break;
              case 'Rejected': icon = LucideIcons.xCircle; color = Colors.red; break;
              case 'Cancelled': icon = LucideIcons.minusCircle; color = Colors.grey; break;
              case 'Expired': icon = LucideIcons.clock; color = Colors.orange; break;
              case 'Average Approval Time': icon = LucideIcons.timer; color = Colors.blue; break;
              default: icon = LucideIcons.activity; color = theme.colorScheme.primary;
            }

            return SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.key, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          Icon(icon, color: color, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(e.value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, ApprovalHistoryState state, ApprovalHistoryNotifier notifier) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by ID or Workflow...',
              prefixIcon: const Icon(LucideIcons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: notifier.setSearchQuery,
          ),
        ),
        _buildFilterDropdown(
          theme: theme,
          hint: 'Decision',
          value: state.selectedDecision,
          items: ['All', 'Approved', 'Rejected', 'Cancelled', 'Expired'],
          onChanged: (val) => notifier.setFilters(decision: val, workflow: state.selectedWorkflow, department: state.selectedDepartment, priority: state.selectedPriority),
        ),
        _buildFilterDropdown(
          theme: theme,
          hint: 'Workflow',
          value: state.selectedWorkflow,
          items: ['All', 'Purchase Order Approval', 'Leave Request Approval', 'Expense Reimbursement', 'Vendor Onboarding', 'Contract Approval'],
          onChanged: (val) => notifier.setFilters(decision: state.selectedDecision, workflow: val, department: state.selectedDepartment, priority: state.selectedPriority),
        ),
        const Spacer(),
        SegmentedButton<ApprovalHistoryViewMode>(
          segments: const [
            ButtonSegment(value: ApprovalHistoryViewMode.table, icon: Icon(LucideIcons.table)),
            ButtonSegment(value: ApprovalHistoryViewMode.card, icon: Icon(LucideIcons.layoutGrid)),
            ButtonSegment(value: ApprovalHistoryViewMode.timeline, icon: Icon(LucideIcons.gitCommit)),
          ],
          selected: {state.viewMode},
          onSelectionChanged: (Set<ApprovalHistoryViewMode> newSelection) {
            notifier.setViewMode(newSelection.first);
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(LucideIcons.download, size: 16),
          label: const Text('Export'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting records...')));
          },
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required ThemeData theme,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          value: value,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildContentArea(BuildContext context, ThemeData theme, ApprovalHistoryState state, List<ApprovalHistoryRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              Icon(LucideIcons.searchX, size: 48, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('No records found', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    switch (state.viewMode) {
      case ApprovalHistoryViewMode.table:
        return _buildTableView(context, theme, records);
      case ApprovalHistoryViewMode.card:
        return _buildCardView(context, theme, records);
      case ApprovalHistoryViewMode.timeline:
        return _buildTimelineView(context, theme, records);
    }
  }

  Widget _buildTableView(BuildContext context, ThemeData theme, List<ApprovalHistoryRecord> records) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: constraints.maxWidth > 1200 ? constraints.maxWidth : 1200,
              child: DataTable(
                headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                columnSpacing: 16,
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Workflow')),
                  DataColumn(label: Text('Request Type')),
                  DataColumn(label: Text('Approved By')),
                  DataColumn(label: Text('Decision')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Duration')),
                  DataColumn(label: Text('Comments')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: records.map((r) => DataRow(
                  cells: [
                    DataCell(Text(r.id, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold))),
                    DataCell(Text(r.workflow)),
                    DataCell(Text(r.requestType)),
                    DataCell(Text(r.approvedBy)),
                    DataCell(_buildDecisionBadge(r.decision, theme)),
                    DataCell(Text(DateFormat('MMM dd, yyyy HH:mm').format(r.decisionDate))),
                    DataCell(Text(r.duration)),
                    DataCell(SizedBox(width: 150, child: Text(r.comments, maxLines: 1, overflow: TextOverflow.ellipsis))),
                    DataCell(
                      IconButton(
                        icon: const Icon(LucideIcons.eye, size: 18),
                        onPressed: () {},
                        tooltip: 'View Details',
                      ),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildDecisionBadge(String decision, ThemeData theme) {
    Color bgColor;
    Color fgColor;
    
    switch (decision) {
      case 'Approved': bgColor = Colors.green.withOpacity(0.1); fgColor = Colors.green.shade700; break;
      case 'Rejected': bgColor = Colors.red.withOpacity(0.1); fgColor = Colors.red.shade700; break;
      case 'Cancelled': bgColor = Colors.grey.withOpacity(0.1); fgColor = Colors.grey.shade700; break;
      case 'Expired': bgColor = Colors.orange.withOpacity(0.1); fgColor = Colors.orange.shade700; break;
      default: bgColor = theme.colorScheme.surfaceVariant; fgColor = theme.colorScheme.onSurface;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        decision,
        style: theme.textTheme.labelSmall?.copyWith(color: fgColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCardView(BuildContext context, ThemeData theme, List<ApprovalHistoryRecord> records) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 600 ? 2 : 1));
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final r = records[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r.id, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        _buildDecisionBadge(r.decision, theme),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(r.workflow, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(r.requestType, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(LucideIcons.user, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(r.approvedBy, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(DateFormat('MMM dd, yyyy').format(r.decisionDate), style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildTimelineView(BuildContext context, ThemeData theme, List<ApprovalHistoryRecord> records) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: records.map<Widget>((ApprovalHistoryRecord r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      DateFormat('MMM dd, yyyy\nHH:mm').format(r.decisionDate),
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getDecisionColor(r.decision, theme),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 2,
                        height: 80,
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(r.id, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            _buildDecisionBadge(r.decision, theme),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(r.workflow, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Processed by ${r.approvedBy} (${r.duration})', style: theme.textTheme.bodySmall),
                        if (r.comments.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('"${r.comments}"', style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getDecisionColor(String decision, ThemeData theme) {
    switch (decision) {
      case 'Approved': return Colors.green;
      case 'Rejected': return Colors.red;
      case 'Cancelled': return Colors.grey;
      case 'Expired': return Colors.orange;
      default: return theme.colorScheme.primary;
    }
  }
}
