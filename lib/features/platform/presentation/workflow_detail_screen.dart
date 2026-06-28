import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import 'providers/workflow_detail_provider.dart';

class WorkflowDetailScreen extends ConsumerStatefulWidget {
  final String workflowId;

  const WorkflowDetailScreen({
    super.key,
    required this.workflowId,
  });

  @override
  ConsumerState<WorkflowDetailScreen> createState() => _WorkflowDetailScreenState();
}

class _WorkflowDetailScreenState extends ConsumerState<WorkflowDetailScreen> {
  String _activeTab = 'Overview';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final workflowAsync = ref.watch(workflowDetailProvider(widget.workflowId));

    return workflowAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(LucideIcons.fileX, size: 48),
            const SizedBox(height: 16),
            Text('Workflow not found: $err', style: theme.textTheme.headlineSmall),
          ]),
        ),
      ),
      data: (detail) {
        final tabs = ['Overview', 'Steps', 'Versions', 'Executions', 'Audit Logs', 'Analytics'];

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: Column(
            children: [
              _buildHeader(context, theme, detail),
              _buildTabBar(theme, tabs, _activeTab),
              const Divider(height: 1),
              Expanded(
                child: _buildTabContent(theme, detail, _activeTab),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, WorkflowDetail detail) {
    Color statusColor = Colors.grey;
    if (detail.status == 'Published') statusColor = Colors.green;
    if (detail.status == 'Active') statusColor = Colors.blue;
    if (detail.status == 'Draft') statusColor = Colors.orange;
    if (detail.status == 'Archived') statusColor = Colors.grey;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              Text('Workflows', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('/')),
              Text('${detail.category}', style: TextStyle(color: theme.colorScheme.primary, fontSize: 13)),
              const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('/')),
              Text(detail.name, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(LucideIcons.workflow, color: theme.colorScheme.primary, size: 32),
              ),
              const SizedBox(width: 24),
              // Title block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(detail.name,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.3)),
                          ),
                          child: Text(detail.status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      children: [
                        _buildMeta(theme, LucideIcons.tag, detail.code),
                        _buildMeta(theme, LucideIcons.folder, detail.category),
                        _buildMeta(theme, LucideIcons.gitCommitHorizontal, detail.version),
                        _buildMeta(theme, LucideIcons.user, 'By ${detail.createdBy}'),
                        if (detail.publishedAt != null)
                          _buildMeta(theme, LucideIcons.calendarCheck, 'Published ${DateFormat('MMM d, yyyy').format(detail.publishedAt!)}'),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                children: [
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.copy, size: 16), label: const Text('Clone')),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.download, size: 16), label: const Text('Export')),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.powerOff, size: 16),
                    label: const Text('Deactivate'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(onPressed: () {}, icon: const Icon(LucideIcons.edit2, size: 16), label: const Text('Edit')),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeta(ThemeData theme, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme, List<String> tabs, String activeTab) {
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: tabs.map((tab) {
          final isActive = tab == activeTab;
          return InkWell(
            onTap: () {
              setState(() {
                _activeTab = tab;
              });
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? theme.colorScheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(ThemeData theme, WorkflowDetail detail, String tab) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: switch (tab) {
        'Overview' => _buildOverviewTab(theme, detail),
        'Steps' => _buildStepsTab(theme, detail),
        'Versions' => _buildVersionsTab(theme, detail),
        'Executions' => _buildExecutionsTab(theme, detail),
        'Audit Logs' => _buildAuditLogsTab(theme, detail),
        'Analytics' => _buildAnalyticsTab(theme, detail),
        _ => const SizedBox(),
      },
    );
  }

  // ─── OVERVIEW TAB ────────────────────────────────────────────────────────────

  Widget _buildOverviewTab(ThemeData theme, WorkflowDetail detail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Row
        Row(
          children: [
            Expanded(child: _buildKpiCard(theme, 'Total Executions', '${detail.totalExecutions}', LucideIcons.zap, Colors.blue)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard(theme, 'Completion Rate', '${(detail.completionRate * 100).toStringAsFixed(1)}%', LucideIcons.checkCircle2, Colors.green)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard(theme, 'Failure Rate', '${(detail.failureRate * 100).toStringAsFixed(1)}%', LucideIcons.xCircle, Colors.red)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard(theme, 'Avg Duration', detail.avgDuration, LucideIcons.timer, Colors.purple)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard(theme, 'Pending Approvals', '${detail.pendingApprovals}', LucideIcons.clipboardCheck, Colors.orange)),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildDescriptionCard(theme, detail)),
            const SizedBox(width: 24),
            Expanded(flex: 3, child: _buildExecutionTrendCard(theme, detail.executionTrend)),
          ],
        ),
        const SizedBox(height: 24),
        _buildTimelineCard(theme, detail),
      ],
    );
  }

  Widget _buildKpiCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500))),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(ThemeData theme, WorkflowDetail detail) {
    return _card(
      theme,
      title: 'Summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(detail.description, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, height: 1.6)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailRow(theme, 'Workflow Code', detail.code),
          _buildDetailRow(theme, 'Category', detail.category),
          _buildDetailRow(theme, 'Version', detail.version),
          _buildDetailRow(theme, 'Steps', '${detail.steps.length} steps'),
          _buildDetailRow(theme, 'Created', DateFormat('MMM d, yyyy').format(detail.createdAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildExecutionTrendCard(ThemeData theme, List<double> trend) {
    return _card(
      theme,
      title: 'Execution Trend (Last 12 Months)',
      child: SizedBox(
        height: 180,
        child: LayoutBuilder(builder: (context, constraints) {
          final maxVal = trend.reduce((a, b) => a > b ? a : b);
          final barWidth = (constraints.maxWidth / trend.length) - 6;
          final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

          return Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: trend.asMap().entries.map((e) {
                    final height = (e.value / maxVal) * 130;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: barWidth,
                          height: height,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: months.map((m) => SizedBox(
                  width: barWidth,
                  child: Text(m, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                )).toList(),
              )
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTimelineCard(ThemeData theme, WorkflowDetail detail) {
    final events = [
      {'icon': LucideIcons.filePlus, 'label': 'Workflow Created', 'date': detail.createdAt, 'color': Colors.blue},
      {'icon': LucideIcons.uploadCloud, 'label': 'Version v2.0.0 Published', 'date': DateTime.now().subtract(const Duration(days: 45)), 'color': Colors.green},
      {'icon': LucideIcons.edit2, 'label': 'SLA Updated to 48h', 'date': DateTime.now().subtract(const Duration(days: 6)), 'color': Colors.orange},
      {'icon': LucideIcons.uploadCloud, 'label': 'Version v2.1.0 Published', 'date': detail.publishedAt!, 'color': Colors.green},
    ];

    return _card(
      theme,
      title: 'Timeline',
      child: Column(
        children: events.asMap().entries.map((e) {
          final isLast = e.key == events.length - 1;
          final event = e.value;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (event['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(event['icon'] as IconData, size: 18, color: event['color'] as Color),
                    ),
                    if (!isLast)
                      Expanded(child: Container(width: 2, color: theme.dividerColor.withOpacity(0.4), margin: const EdgeInsets.symmetric(vertical: 4))),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                    child: Row(
                      children: [
                        Expanded(child: Text(event['label'] as String, style: const TextStyle(fontWeight: FontWeight.w500))),
                        Text(DateFormat('MMM d, yyyy').format(event['date'] as DateTime), style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── STEPS TAB ───────────────────────────────────────────────────────────────

  Widget _buildStepsTab(ThemeData theme, WorkflowDetail detail) {
    return _card(
      theme,
      title: '${detail.steps.length} Workflow Steps',
      child: Column(
        children: detail.steps.asMap().entries.map((e) {
          final step = e.value;
          final isLast = e.key == detail.steps.length - 1;

          Color stepColor = Colors.grey;
          IconData stepIcon = LucideIcons.circle;
          if (step.status == 'completed') { stepColor = Colors.green; stepIcon = LucideIcons.checkCircle2; }
          if (step.status == 'active') { stepColor = Colors.blue; stepIcon = LucideIcons.loader; }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left connector
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: stepColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: Center(child: Icon(stepIcon, color: stepColor, size: 20)),
                    ),
                    if (!isLast)
                      Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), color: theme.dividerColor.withOpacity(0.4))),
                  ],
                ),
                const SizedBox(width: 20),
                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
                                child: Text('Step ${step.order}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.indigo.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text(step.type, style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.w600)),
                              ),
                              const Spacer(),
                              if (step.slaHours > 0)
                                Row(children: [
                                  Icon(LucideIcons.clock, size: 12, color: theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text('SLA: ${step.slaHours}h', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                                ]),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(step.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 6),
                          Text(step.description, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                          const SizedBox(height: 8),
                          Row(children: [
                            Icon(LucideIcons.userCheck, size: 12, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(step.assignedRole, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── VERSIONS TAB ────────────────────────────────────────────────────────────

  Widget _buildVersionsTab(ThemeData theme, WorkflowDetail detail) {
    return _card(
      theme,
      title: 'Version History',
      padding: EdgeInsets.zero,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)),
        columns: const [
          DataColumn(label: Text('Version', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Published Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Published By', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Change Notes', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: detail.versions.map((v) => DataRow(cells: [
          DataCell(Text(v.version, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
          DataCell(Text(DateFormat('MMM d, yyyy').format(v.publishedAt))),
          DataCell(Text(v.publishedBy)),
          DataCell(SizedBox(width: 280, child: Text(v.changeNotes, style: const TextStyle(fontSize: 13)))),
          DataCell(
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: v.isCurrent ? Colors.green.withOpacity(0.1) : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(v.isCurrent ? 'Current' : 'Archived', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: v.isCurrent ? Colors.green : theme.colorScheme.onSurfaceVariant)),
            ),
          ),
        ])).toList(),
      ),
    );
  }

  // ─── EXECUTIONS TAB ──────────────────────────────────────────────────────────

  Widget _buildExecutionsTab(ThemeData theme, WorkflowDetail detail) {
    return _card(
      theme,
      title: 'Execution History',
      padding: EdgeInsets.zero,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)),
        columns: const [
          DataColumn(label: Text('Execution ID', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Initiated By', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Start Time', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: detail.executions.map((exec) {
          Color statusColor = Colors.grey;
          if (exec.status == 'completed') statusColor = Colors.green;
          if (exec.status == 'failed') statusColor = Colors.red;
          if (exec.status == 'running') statusColor = Colors.blue;
          return DataRow(cells: [
            DataCell(Text(exec.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold))),
            DataCell(Text(exec.initiator)),
            DataCell(Text(DateFormat('MMM d, HH:mm').format(exec.startTime))),
            DataCell(Text(exec.duration)),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: statusColor.withOpacity(0.3))),
              child: Text(exec.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // ─── AUDIT LOGS TAB ──────────────────────────────────────────────────────────

  Widget _buildAuditLogsTab(ThemeData theme, WorkflowDetail detail) {
    return _card(
      theme,
      title: 'Audit Logs',
      child: Column(
        children: detail.auditLogs.map((log) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, shape: BoxShape.circle),
                child: Icon(LucideIcons.activity, size: 18, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(4)),
                          child: Text('by ${log.actor}', style: const TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(log.details, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
              ),
              Text(DateFormat('MMM d, yyyy').format(log.timestamp), style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  // ─── ANALYTICS TAB ───────────────────────────────────────────────────────────

  Widget _buildAnalyticsTab(ThemeData theme, WorkflowDetail detail) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildCompletionRateChart(theme, detail)),
            const SizedBox(width: 24),
            Expanded(child: _buildApprovalTimeChart(theme, detail)),
          ],
        ),
        const SizedBox(height: 24),
        _buildExecutionTrendCard(theme, detail.executionTrend),
      ],
    );
  }

  Widget _buildCompletionRateChart(ThemeData theme, WorkflowDetail detail) {
    return _card(
      theme,
      title: 'Completion vs Failure Rate',
      child: SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: detail.completionRate,
                strokeWidth: 20,
                backgroundColor: Colors.red.withOpacity(0.2),
                color: Colors.green,
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${(detail.completionRate * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              Text('Success Rate', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalTimeChart(ThemeData theme, WorkflowDetail detail) {
    final data = [
      {'label': 'Dept Head', 'hours': 16.0, 'target': 24.0},
      {'label': 'Finance', 'hours': 35.0, 'target': 48.0},
      {'label': 'VP Procure', 'hours': 18.0, 'target': 24.0},
    ];

    return _card(
      theme,
      title: 'Avg Approval Time per Step (hrs)',
      child: SizedBox(
        height: 220,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: data.map((d) {
            final ratio = (d['hours'] as double) / (d['target'] as double);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(d['label'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Text('${d['hours']}h / ${d['target']}h target', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ratio,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: ratio > 0.85 ? Colors.orange : Colors.green,
                    minHeight: 10,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── SHARED HELPERS ───────────────────────────────────────────────────────────

  Widget _card(ThemeData theme, {required String title, required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          )
        ],
      ),
    );
  }
}
