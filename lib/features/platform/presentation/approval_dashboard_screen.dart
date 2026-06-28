import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'providers/approval_dashboard_provider.dart';

class ApprovalDashboardScreen extends ConsumerWidget {
  const ApprovalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(approvalDashboardProvider);
    final notifier = ref.read(approvalDashboardProvider.notifier);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Approval Dashboard'),
        centerTitle: false,
        actions: [
          _buildFilterDropdown(theme, state.selectedPeriod, ['Today', 'This Week', 'This Month'], (v) => notifier.setFilter(period: v)),
          const SizedBox(width: 8),
          if (isDesktop) ...[
            _buildFilterDropdown(theme, state.selectedDepartment, ['All Departments', 'Finance', 'HR', 'IT', 'Legal'], (v) => notifier.setFilter(department: v)),
            const SizedBox(width: 8),
            _buildFilterDropdown(theme, state.selectedPriority, ['All Priorities', 'High', 'Medium', 'Low'], (v) => notifier.setFilter(priority: v)),
            const SizedBox(width: 16),
          ],
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Refresh',
            onPressed: () => notifier.refresh(),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor.withOpacity(0.5), height: 1.0),
        ),
      ),
      body: _buildBody(context, theme, state, isDesktop),
    );
  }

  Widget _buildFilterDropdown(ThemeData theme, String value, List<String> options, Function(String?) onChanged) {
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

  Widget _buildBody(BuildContext context, ThemeData theme, ApprovalDashboardState state, bool isDesktop) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.alertTriangle, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.errorMessage, style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 24 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildKPIRow(theme, state, isDesktop),
          const SizedBox(height: 24),
          if (isDesktop) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildApprovalTrendChart(theme, state)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildStatusDistributionChart(theme, state)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildDepartmentVolumeChart(theme, state)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildSlaComplianceChart(theme, state)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPendingApprovalsWidget(theme, state)),
                const SizedBox(width: 24),
                Expanded(child: _buildEscalatedRequestsWidget(theme, state)),
                const SizedBox(width: 24),
                Expanded(child: _buildHealthAndRecentWidget(theme, state)),
              ],
            )
          ] else ...[
            _buildApprovalTrendChart(theme, state),
            const SizedBox(height: 24),
            _buildStatusDistributionChart(theme, state),
            const SizedBox(height: 24),
            _buildDepartmentVolumeChart(theme, state),
            const SizedBox(height: 24),
            _buildSlaComplianceChart(theme, state),
            const SizedBox(height: 24),
            _buildPendingApprovalsWidget(theme, state),
            const SizedBox(height: 24),
            _buildEscalatedRequestsWidget(theme, state),
            const SizedBox(height: 24),
            _buildHealthAndRecentWidget(theme, state),
          ]
        ],
      ),
    );
  }

  // ─── KPIS ─────────────────────────────────────────────────────────────
  Widget _buildKPIRow(ThemeData theme, ApprovalDashboardState state, bool isDesktop) {
    final kpis = [
      _buildKPICard(theme, 'Pending Approvals', '${state.pendingApprovals}', LucideIcons.clock, Colors.orange),
      _buildKPICard(theme, 'Approved Today', '${state.approvedToday}', LucideIcons.checkCircle, Colors.green),
      _buildKPICard(theme, 'Rejected Today', '${state.rejectedToday}', LucideIcons.xCircle, Colors.red),
      _buildKPICard(theme, 'Escalated', '${state.escalatedRequests}', LucideIcons.alertCircle, Colors.purple),
      _buildKPICard(theme, 'Avg Time', state.avgApprovalTime, LucideIcons.timer, Colors.blue),
      _buildKPICard(theme, 'SLA Compliance', '${state.slaCompliance}%', LucideIcons.shieldCheck, Colors.teal),
    ];

    if (isDesktop) {
      return IntrinsicHeight(
        child: Row(
          children: kpis.expand((kpi) => [Expanded(child: kpi), const SizedBox(width: 16)]).toList()..removeLast(),
        ),
      );
    } else {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: kpis.map((kpi) => SizedBox(width: 150, child: kpi)).toList(),
      );
    }
  }

  Widget _buildKPICard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
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
    );
  }

  // ─── CHARTS ───────────────────────────────────────────────────────────
  Widget _buildChartContainer(ThemeData theme, String title, Widget chart, {double height = 300}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildApprovalTrendChart(ThemeData theme, ApprovalDashboardState state) {
    return _buildChartContainer(
      theme,
      'Approval Trend (Last 7 Days)',
      LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor.withOpacity(0.2), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  if (value >= 0 && value < days.length) {
                    return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(days[value.toInt()], style: theme.textTheme.bodySmall));
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: theme.textTheme.bodySmall),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: state.approvalTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistributionChart(ThemeData theme, ApprovalDashboardState state) {
    final colors = {'Approved': Colors.green, 'Rejected': Colors.red, 'Pending': Colors.orange, 'Escalated': Colors.purple};
    return _buildChartContainer(
      theme,
      'Status Distribution',
      Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: state.statusDistribution.entries.map((e) {
                  return PieChartSectionData(
                    color: colors[e.key] ?? Colors.grey,
                    value: e.value,
                    title: '${e.value}%',
                    radius: 50,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: state.statusDistribution.keys.map((key) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, color: colors[key]),
                      const SizedBox(width: 8),
                      Text(key, style: theme.textTheme.bodySmall),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDepartmentVolumeChart(ThemeData theme, ApprovalDashboardState state) {
    final keys = state.departmentVolume.keys.toList();
    return _buildChartContainer(
      theme,
      'Department Volume',
      BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < keys.length) {
                    return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(keys[value.toInt()], style: theme.textTheme.bodySmall));
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: state.departmentVolume.entries.toList().asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: Colors.blueAccent,
                  width: 20,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSlaComplianceChart(ThemeData theme, ApprovalDashboardState state) {
    return _buildChartContainer(
      theme,
      'SLA Compliance %',
      LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: theme.textTheme.bodySmall),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 80,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: state.slaComplianceTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: Colors.teal,
              barWidth: 4,
              dotData: FlDotData(show: true),
            ),
          ],
        ),
      ),
    );
  }

  // ─── WIDGETS ──────────────────────────────────────────────────────────
  Widget _buildListContainer(ThemeData theme, String title, Widget child) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsWidget(ThemeData theme, ApprovalDashboardState state) {
    if (state.pendingMyApprovals.isEmpty) {
      return _buildListContainer(theme, 'Pending My Approval', const Center(child: Text('No pending approvals.')));
    }
    return _buildListContainer(
      theme,
      'Pending My Approval',
      ListView.separated(
        itemCount: state.pendingMyApprovals.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = state.pendingMyApprovals[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item['title'], style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            subtitle: Text('${item['id']} • ${item['requester']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: Text('Due in ${item['due']}', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEscalatedRequestsWidget(ThemeData theme, ApprovalDashboardState state) {
    if (state.escalatedRequestsList.isEmpty) {
      return _buildListContainer(theme, 'Escalated Requests', const Center(child: Text('No escalations.')));
    }
    return _buildListContainer(
      theme,
      'Escalated Requests',
      ListView.separated(
        itemCount: state.escalatedRequestsList.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final item = state.escalatedRequestsList[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item['title'], style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            subtitle: Text(item['reason']),
            trailing: Icon(LucideIcons.alertTriangle, color: item['priority'] == 'High' ? Colors.red : Colors.orange),
          );
        },
      ),
    );
  }

  Widget _buildHealthAndRecentWidget(ThemeData theme, ApprovalDashboardState state) {
    return _buildListContainer(
      theme,
      'System Health & Activity',
      Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Approval Health', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                Text('${state.approvalHealthScore}/100', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('Recent Decisions', style: TextStyle(fontWeight: FontWeight.bold))),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: state.recentDecisions.length,
              itemBuilder: (context, index) {
                final item = state.recentDecisions[index];
                final isApproved = item['decision'] == 'Approved';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(isApproved ? LucideIcons.checkCircle : LucideIcons.xCircle, color: isApproved ? Colors.green : Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item['title'], style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
                      Text(item['time'], style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
