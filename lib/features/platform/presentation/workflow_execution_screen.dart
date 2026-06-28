import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import 'providers/workflow_execution_provider.dart';
import '../domain/models/workflow_execution.dart';
import '../data/mock_workflow_execution_repository.dart';

class WorkflowExecutionScreen extends ConsumerStatefulWidget {
  const WorkflowExecutionScreen({super.key});

  @override
  ConsumerState<WorkflowExecutionScreen> createState() => _WorkflowExecutionScreenState();
}

class _WorkflowExecutionScreenState extends ConsumerState<WorkflowExecutionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ExecutionDetail? _currentDetail;
  bool _isLoadingDetail = false;

  void _openDetailDrawer(String id) async {
    setState(() => _isLoadingDetail = true);
    _scaffoldKey.currentState?.openEndDrawer();
    
    final repo = MockWorkflowExecutionRepository();
    final detail = await repo.getExecutionDetail(id);
    
    setState(() {
      _currentDetail = detail;
      _isLoadingDetail = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(workflowExecutionProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Workflow Execution Monitor'),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [
          Row(
            children: [
              Text('Auto Refresh', style: theme.textTheme.bodyMedium),
              Switch(
                value: state.autoRefresh,
                onChanged: (val) => ref.read(workflowExecutionProvider.notifier).toggleAutoRefresh(),
              ),
              const SizedBox(width: 16),
            ],
          )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withOpacity(0.5),
            height: 1.0,
          ),
        ),
      ),
      endDrawer: _buildEndDrawer(theme),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatisticsCards(theme, state, isDesktop),
          const Divider(height: 1),
          _buildFilterBar(theme, state, isDesktop),
          const Divider(height: 1),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.filteredExecutions.isEmpty
                    ? const Center(child: Text('No executions found.'))
                    : _buildDataTable(theme, state, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(ThemeData theme, WorkflowExecutionState state, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      child: isDesktop
          ? IntrinsicHeight(
              child: Row(
                children: [
                  _buildStatCard(theme, 'Running', state.totalRunning.toString(), LucideIcons.playCircle, Colors.blue),
                  const SizedBox(width: 12),
                  _buildStatCard(theme, 'Completed', state.totalCompleted.toString(), LucideIcons.checkCircle2, Colors.green),
                  const SizedBox(width: 12),
                  _buildStatCard(theme, 'Failed', state.totalFailed.toString(), LucideIcons.alertCircle, Colors.red),
                  const SizedBox(width: 12),
                  _buildStatCard(theme, 'Cancelled', state.totalCancelled.toString(), LucideIcons.xCircle, Colors.grey),
                  const SizedBox(width: 12),
                  _buildStatCard(theme, 'Avg Duration', state.averageDuration, LucideIcons.clock, Colors.orange),
                ],
              ),
            )
          : Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStatCardFixed(theme, 'Running', state.totalRunning.toString(), LucideIcons.playCircle, Colors.blue),
                _buildStatCardFixed(theme, 'Completed', state.totalCompleted.toString(), LucideIcons.checkCircle2, Colors.green),
                _buildStatCardFixed(theme, 'Failed', state.totalFailed.toString(), LucideIcons.alertCircle, Colors.red),
                _buildStatCardFixed(theme, 'Cancelled', state.totalCancelled.toString(), LucideIcons.xCircle, Colors.grey),
                _buildStatCardFixed(theme, 'Avg Duration', state.averageDuration, LucideIcons.clock, Colors.orange),
              ],
            ),
    );
  }

  // Used on desktop: Expanded card taking up 1/5 of row
  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // Used on mobile: fixed width card
  Widget _buildStatCardFixed(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme, WorkflowExecutionState state, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _buildDropdown(
            theme, 
            ['All Workflows', 'Standard PO Approval', 'Employee Onboarding', 'Expense Reimbursement', 'High Value PO Approval', 'Leave Request'], 
            state.selectedWorkflow, 
            (val) => ref.read(workflowExecutionProvider.notifier).setFilter(workflow: val)
          ),
          _buildDropdown(
            theme, 
            ['All Statuses', 'Running', 'Completed', 'Failed', 'Cancelled'], 
            state.selectedStatus, 
            (val) => ref.read(workflowExecutionProvider.notifier).setFilter(status: val)
          ),
          _buildDropdown(
            theme, 
            ['Any Time', 'Last 24 Hours', 'Last 7 Days'], 
            state.selectedDate, 
            (val) => ref.read(workflowExecutionProvider.notifier).setFilter(date: val)
          ),
          _buildDropdown(
            theme, 
            ['All Users', 'John Doe', 'Jane Smith', 'System', 'Alice Wong', 'Bob Builder', 'Charlie Brown'], 
            state.selectedUser, 
            (val) => ref.read(workflowExecutionProvider.notifier).setFilter(user: val)
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, List<String> options, String value, Function(String?) onChanged) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          style: theme.textTheme.bodyMedium,
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme, WorkflowExecutionState state, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double usable = constraints.maxWidth - 32; // 16px padding each side

        // Proportional widths — always sum to usable width
        final double colId        = usable * 0.12;
        final double colWorkflow  = usable * 0.17;
        final double colStartedBy = usable * 0.09;
        final double colStartedAt = usable * 0.13;
        final double colCurrStep  = usable * 0.12;
        final double colAssigned  = usable * 0.12;
        final double colStatus    = usable * 0.10;
        final double colDuration  = usable * 0.08;
        final double colActions   = usable * 0.07;

        Widget hCell(String label, double w) => SizedBox(
          width: w,
          child: Text(label,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        );

        Widget cell(Widget child, double w) => SizedBox(width: w, child: child);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Fixed header ──────────────────────────────────────────────
            Container(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  hCell('Execution ID', colId),
                  hCell('Workflow',     colWorkflow),
                  hCell('Started By',  colStartedBy),
                  hCell('Started At',  colStartedAt),
                  hCell('Current Step',colCurrStep),
                  hCell('Assigned User',colAssigned),
                  hCell('Status',      colStatus),
                  hCell('Duration',    colDuration),
                  hCell('Actions',     colActions),
                ],
              ),
            ),
            const Divider(height: 1),
            // ── Scrollable body (vertical) ────────────────────────────────
            Expanded(
              child: ListView.builder(
                itemCount: state.filteredExecutions.length,
                itemBuilder: (context, index) {
                  final e = state.filteredExecutions[index];
                  return Column(
                    children: [
                      InkWell(
                        hoverColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              cell(Text(e.id, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis), colId),
                              cell(Text(e.workflowName, overflow: TextOverflow.ellipsis), colWorkflow),
                              cell(Text(e.startedBy, overflow: TextOverflow.ellipsis), colStartedBy),
                              cell(Text(DateFormat('MMM dd, yyyy HH:mm').format(e.startedAt), overflow: TextOverflow.ellipsis), colStartedAt),
                              cell(Text(e.currentStep, overflow: TextOverflow.ellipsis), colCurrStep),
                              cell(Text(e.assignedUser, overflow: TextOverflow.ellipsis), colAssigned),
                              cell(_buildStatusBadge(theme, e.status), colStatus),
                              cell(Text('${e.duration.inHours}h ${e.duration.inMinutes.remainder(60)}m', overflow: TextOverflow.ellipsis), colDuration),
                              cell(
                                IconButton(
                                  icon: const Icon(LucideIcons.eye, size: 18),
                                  onPressed: () => _openDetailDrawer(e.id),
                                  tooltip: 'View Details',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                ),
                                colActions,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildStatusBadge(ThemeData theme, String status) {
    Color color;
    if (status == 'Running') color = Colors.blue;
    else if (status == 'Completed') color = Colors.green;
    else if (status == 'Failed') color = Colors.red;
    else color = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEndDrawer(ThemeData theme) {
    return Drawer(
      width: 500,
      child: _isLoadingDetail
          ? const Center(child: CircularProgressIndicator())
          : _currentDetail == null
              ? const Center(child: Text('No details available.'))
              : _buildDrawerContent(theme, _currentDetail!),
    );
  }

  Widget _buildDrawerContent(ThemeData theme, ExecutionDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Execution Detail', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
        ),
        Expanded(
          child: DefaultTabController(
            length: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Timeline'),
                    Tab(text: 'Logs'),
                    Tab(text: 'Variables'),
                    Tab(text: 'Errors'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTimelineTab(theme, detail),
                      _buildLogsTab(theme, detail),
                      _buildVariablesTab(theme, detail),
                      _buildErrorsTab(theme, detail),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTab(ThemeData theme, ExecutionDetail detail) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: detail.timeline.length,
      itemBuilder: (context, index) {
        final event = detail.timeline[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: event.status == 'Success' ? Colors.green : Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index < detail.timeline.length - 1)
                    Container(
                      width: 2,
                      height: 50,
                      color: theme.dividerColor,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(event.node, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(DateFormat('HH:mm:ss').format(event.timestamp), style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(event.action, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text('By: ${event.user}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogsTab(ThemeData theme, ExecutionDetail detail) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: detail.logs.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 8),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          child: Text(
            detail.logs[index],
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        );
      },
    );
  }

  Widget _buildVariablesTab(ThemeData theme, ExecutionDetail detail) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: detail.variables.entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(e.value, style: const TextStyle(fontFamily: 'monospace')),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildErrorsTab(ThemeData theme, ExecutionDetail detail) {
    if (detail.errors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.checkCircle2, size: 48, color: Colors.green.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No errors detected.', style: theme.textTheme.bodyLarge),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: detail.errors.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.alertTriangle, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(detail.errors[index], style: const TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
    );
  }
}
