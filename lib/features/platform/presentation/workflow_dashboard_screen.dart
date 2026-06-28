import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/workflow_dashboard_provider.dart';

class WorkflowDashboardScreen extends ConsumerStatefulWidget {
  const WorkflowDashboardScreen({super.key});

  @override
  ConsumerState<WorkflowDashboardScreen> createState() => _WorkflowDashboardScreenState();
}

class _WorkflowDashboardScreenState extends ConsumerState<WorkflowDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(workflowDashboardProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(theme, state),
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.kpis != null)
            SliverPadding(
              padding: EdgeInsets.all(isDesktop ? 32 : 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildKPIGrid(theme, state.kpis!, isDesktop),
                  const SizedBox(height: 32),
                  _buildChartsRow(theme, state, isDesktop),
                  const SizedBox(height: 32),
                  _buildTablesRow(theme, state, isDesktop),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(ThemeData theme, WorkflowDashboardState state) {
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
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(LucideIcons.workflow, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Workflow Engine', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Executive overview of automated processes', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
              const Spacer(),
              _buildDateFilters(theme, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilters(ThemeData theme, WorkflowDashboardState state) {
    final filters = ['Today', 'This Week', 'This Month', 'Custom'];
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: filters.map((f) {
          final isSelected = state.filterRange == f;
          return InkWell(
            onTap: () => ref.read(workflowDashboardProvider.notifier).setFilterRange(f),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                f,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKPIGrid(ThemeData theme, WorkflowKpis kpis, bool isDesktop) {
    return GridView.count(
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isDesktop ? 2.2 : 1.5,
      children: [
        _buildKPICard(theme, 'Total Workflows', kpis.totalWorkflows.toString(), LucideIcons.gitFork, Colors.blue, '+12%'),
        _buildKPICard(theme, 'Active Workflows', kpis.activeWorkflows.toString(), LucideIcons.activity, Colors.green, '+4%'),
        _buildKPICard(theme, 'Running Executions', kpis.runningExecutions.toString(), LucideIcons.playCircle, Colors.orange, null),
        _buildKPICard(theme, 'Pending Approvals', kpis.pendingApprovals.toString(), LucideIcons.clipboardCheck, Colors.purple, '-2%'),
        _buildKPICard(theme, 'Completed Today', kpis.completedToday.toString(), LucideIcons.checkCircle2, Colors.teal, '+24%'),
        _buildKPICard(theme, 'Failed Executions', kpis.failedExecutions.toString(), LucideIcons.xCircle, Colors.red, '-5%'),
        _buildKPICard(theme, 'Avg Processing Time', kpis.avgProcessingTime, LucideIcons.timer, Colors.indigo, '-10s'),
        _buildKPICard(theme, 'Automation Rate', '${(kpis.automationRate * 100).toInt()}%', LucideIcons.bot, Colors.cyan, '+2%'),
      ],
    );
  }

  Widget _buildKPICard(ThemeData theme, String title, String value, IconData icon, Color color, String? trend) {
    final isPositive = trend != null && trend.startsWith('+');
    final trendColor = isPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 16),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              if (trend != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown, size: 12, color: trendColor),
                      const SizedBox(width: 4),
                      Text(trend, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: trendColor)),
                    ],
                  ),
                )
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildChartsRow(ThemeData theme, WorkflowDashboardState state, bool isDesktop) {
    final children = [
      Expanded(flex: 3, child: _buildTrendChart(theme, state.executionTrend)),
      if (isDesktop) const SizedBox(width: 24),
      Expanded(flex: 2, child: _buildDistributionChart(theme, state.categoryDistribution)),
      if (isDesktop) const SizedBox(width: 24),
      Expanded(flex: 2, child: _buildSuccessRateChart(theme, state.kpis!)),
    ];

    return isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: children) : Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 24), child: c)).toList());
  }

  Widget _buildTrendChart(ThemeData theme, List<double> trendData) {
    return _buildCardWrapper(
      theme,
      title: 'Execution Trend',
      child: SizedBox(
        height: 200,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxVal = trendData.reduce((a, b) => a > b ? a : b);
            final barWidth = (constraints.maxWidth / trendData.length) - 8;
            
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: trendData.map((val) {
                final height = (val / maxVal) * constraints.maxHeight;
                return Container(
                  width: barWidth,
                  height: height,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDistributionChart(ThemeData theme, Map<String, double> distribution) {
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal, Colors.grey];
    
    return _buildCardWrapper(
      theme,
      title: 'Category Distribution',
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Horizontal stacked bar
            Container(
              height: 24,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: distribution.entries.toList().asMap().entries.map((entry) {
                  return Expanded(
                    flex: (entry.value.value * 100).toInt(),
                    child: Container(color: colors[entry.key % colors.length]),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: distribution.entries.toList().asMap().entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[entry.key % colors.length], shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('${entry.value.key} (${(entry.value.value * 100).toInt()}%)', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                  ],
                );
              }).toList(),
            )
          ],
        ),
      )
    );
  }

  Widget _buildSuccessRateChart(ThemeData theme, WorkflowKpis kpis) {
    final total = kpis.completedToday + kpis.failedExecutions;
    final successRate = total == 0 ? 0.0 : (kpis.completedToday / total);

    return _buildCardWrapper(
      theme,
      title: 'Success Rate',
      child: SizedBox(
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: successRate,
                strokeWidth: 12,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: Colors.green,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(successRate * 100).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text('Completed', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTablesRow(ThemeData theme, WorkflowDashboardState state, bool isDesktop) {
    final children = [
      Expanded(flex: 3, child: _buildRecentExecutions(theme, state.recentExecutions)),
      if (isDesktop) const SizedBox(width: 24),
      Expanded(flex: 2, child: _buildPendingTasks(theme, state.pendingTasks)),
    ];

    return isDesktop ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: children) : Column(children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 24), child: c)).toList());
  }

  Widget _buildRecentExecutions(ThemeData theme, List<WorkflowExecution> executions) {
    return _buildCardWrapper(
      theme,
      title: 'Recent Executions',
      action: TextButton(onPressed: (){}, child: const Text('View All')),
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: executions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final exec = executions[index];
          
          Color statusColor = Colors.grey;
          IconData statusIcon = LucideIcons.circle;
          if (exec.status == 'completed') { statusColor = Colors.green; statusIcon = LucideIcons.checkCircle2; }
          if (exec.status == 'failed') { statusColor = Colors.red; statusIcon = LucideIcons.xCircle; }
          if (exec.status == 'running') { statusColor = Colors.orange; statusIcon = LucideIcons.loader; }

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            title: Text(exec.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text('${exec.category} • Initiated by ${exec.initiator}', style: const TextStyle(fontSize: 12)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(DateFormat('HH:mm').format(exec.startTime), style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(exec.duration, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          );
        },
      )
    );
  }

  Widget _buildPendingTasks(ThemeData theme, List<WorkflowTask> tasks) {
    return _buildCardWrapper(
      theme,
      title: 'Pending Tasks',
      action: TextButton(onPressed: (){}, child: const Text('View All')),
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isHigh = task.priority == 'High';

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(task.workflowName, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 12, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM d, HH:mm').format(task.dueDate), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isHigh ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(task.priority, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isHigh ? Colors.red : Colors.orange)),
                    )
                  ],
                )
              ],
            ),
          );
        },
      )
    );
  }

  Widget _buildCardWrapper(ThemeData theme, {required String title, required Widget child, Widget? action, EdgeInsetsGeometry? padding}) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (action != null) action,
              ],
            ),
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
