import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'providers/workflow_analytics_provider.dart';

class WorkflowAnalyticsDashboardScreen extends ConsumerWidget {
  const WorkflowAnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(workflowAnalyticsProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isTablet = MediaQuery.of(context).size.width >= 768 && !isDesktop;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Workflow Analytics Dashboard'),
        centerTitle: false,
        actions: [
          _buildDateRangeFilter(theme),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(LucideIcons.download),
            tooltip: 'Export Dashboard',
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withOpacity(0.5),
            height: 1.0,
          ),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                        Expanded(flex: 2, child: _buildExecutionTrendChart(theme, state)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildDurationChart(theme, state)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 1, child: _buildBottleneckChart(theme, state)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildDepartmentChart(theme, state)),
                      ],
                    ),
                  ] else ...[
                    _buildExecutionTrendChart(theme, state),
                    const SizedBox(height: 24),
                    _buildDurationChart(theme, state),
                    const SizedBox(height: 24),
                    _buildBottleneckChart(theme, state),
                    const SizedBox(height: 24),
                    _buildDepartmentChart(theme, state),
                  ],
                  const SizedBox(height: 24),
                  _buildHeatmap(theme, state, isDesktop),
                  const SizedBox(height: 24),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildTopSlowWorkflows(theme, state)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildTopAutomatedProcesses(theme, state)),
                        const SizedBox(width: 24),
                        Expanded(child: _buildInsights(theme, state)),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopSlowWorkflows(theme, state),
                        const SizedBox(height: 24),
                        _buildTopAutomatedProcesses(theme, state),
                        const SizedBox(height: 24),
                        _buildInsights(theme, state),
                      ],
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateRangeFilter(ThemeData theme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: 'Last 7 Days',
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          style: theme.textTheme.bodyMedium,
          items: ['Today', 'Last 7 Days', 'Last 30 Days', 'This Quarter']
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildKPIRow(ThemeData theme, WorkflowAnalyticsState state, bool isDesktop) {
    return isDesktop
        ? IntrinsicHeight(
            child: Row(
              children: [
                _buildKPICard(theme, 'Automation Rate', '${state.automationRate}%', LucideIcons.cpu, Colors.blue),
                const SizedBox(width: 16),
                _buildKPICard(theme, 'Avg Completion', state.avgCompletionTime, LucideIcons.clock, Colors.orange),
                const SizedBox(width: 16),
                _buildKPICard(theme, 'Failure Rate', '${state.failureRate}%', LucideIcons.alertTriangle, Colors.red),
                const SizedBox(width: 16),
                _buildKPICard(theme, 'Approval SLA', '${state.approvalSLA}%', LucideIcons.checkCircle2, Colors.green),
                const SizedBox(width: 16),
                _buildKPICard(theme, 'Escalations', '${state.escalations}', LucideIcons.trendingUp, Colors.purple),
              ],
            ),
          )
        : Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildKPICardFixed(theme, 'Automation Rate', '${state.automationRate}%', LucideIcons.cpu, Colors.blue),
              _buildKPICardFixed(theme, 'Avg Completion', state.avgCompletionTime, LucideIcons.clock, Colors.orange),
              _buildKPICardFixed(theme, 'Failure Rate', '${state.failureRate}%', LucideIcons.alertTriangle, Colors.red),
              _buildKPICardFixed(theme, 'Approval SLA', '${state.approvalSLA}%', LucideIcons.checkCircle2, Colors.green),
              _buildKPICardFixed(theme, 'Escalations', '${state.escalations}', LucideIcons.trendingUp, Colors.purple),
            ],
          );
  }

  Widget _buildKPICard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Expanded(
      child: _kpiCardContent(theme, title, value, icon, color),
    );
  }

  Widget _buildKPICardFixed(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      child: _kpiCardContent(theme, title, value, icon, color),
    );
  }

  Widget _kpiCardContent(ThemeData theme, String title, String value, IconData icon, Color color) {
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

  Widget _buildExecutionTrendChart(ThemeData theme, WorkflowAnalyticsState state) {
    return _buildChartContainer(
      theme,
      'Execution Trend (Last 7 Days)',
      LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 50,
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[value.toInt()], style: theme.textTheme.bodySmall),
                    );
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
              spots: state.executionTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationChart(ThemeData theme, WorkflowAnalyticsState state) {
    final keys = state.workflowDuration.keys.toList();
    return _buildChartContainer(
      theme,
      'Avg Duration (Hours)',
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        keys[value.toInt()].split(' ').first, // short name
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: state.workflowDuration.entries.toList().asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  color: Colors.orange,
                  width: 16,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBottleneckChart(ThemeData theme, WorkflowAnalyticsState state) {
    final keys = state.approvalBottlenecks.keys.toList();
    return _buildChartContainer(
      theme,
      'Approval Bottlenecks',
      BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(keys[value.toInt()], style: theme.textTheme.bodySmall),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: state.approvalBottlenecks.entries.toList().asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: Colors.redAccent,
                  width: 24,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDepartmentChart(ThemeData theme, WorkflowAnalyticsState state) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    int colorIndex = 0;
    return _buildChartContainer(
      theme,
      'Department Usage',
      Row(
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: state.departmentComparison.entries.map((e) {
                  final c = colors[colorIndex % colors.length];
                  colorIndex++;
                  return PieChartSectionData(
                    color: c,
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
              children: state.departmentComparison.entries.toList().asMap().entries.map((e) {
                final c = colors[e.key % colors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, color: c),
                      const SizedBox(width: 8),
                      Text(e.value.key, style: theme.textTheme.bodySmall),
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

  Widget _buildHeatmap(ThemeData theme, WorkflowAnalyticsState state, bool isDesktop) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Peak Processing Hours', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Y-axis labels (Days)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24), // Offset for X-axis
                    ...days.map((d) => Container(
                      height: 24,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(d, style: theme.textTheme.bodySmall),
                    )),
                  ],
                ),
                // Heatmap Grid
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // X-axis labels (Hours)
                    Row(
                      children: List.generate(24, (h) => Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: Text(h % 4 == 0 ? '$h' : '', style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
                      )),
                    ),
                    // Cells
                    ...state.heatmapData.map((dayData) => Row(
                      children: dayData.map((val) => Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(val),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )).toList(),
                    )),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

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
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildTopSlowWorkflows(ThemeData theme, WorkflowAnalyticsState state) {
    return _buildListContainer(
      theme,
      'Top Slow Workflows',
      ListView.separated(
        itemCount: state.topSlowWorkflows.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final w = state.topSlowWorkflows[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(w['name'], style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            subtitle: Text('Avg: ${w['duration']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(w['trend'], style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopAutomatedProcesses(ThemeData theme, WorkflowAnalyticsState state) {
    return _buildListContainer(
      theme,
      'Top Automated Processes',
      ListView.separated(
        itemCount: state.topAutomatedProcesses.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final p = state.topAutomatedProcesses[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(p['name'], style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            subtitle: Text('${p['executions']} executions'),
            trailing: Text('Saved\n${p['savings']}', textAlign: TextAlign.right, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          );
        },
      ),
    );
  }

  Widget _buildInsights(ThemeData theme, WorkflowAnalyticsState state) {
    return _buildListContainer(
      theme,
      'AI Recommendations',
      ListView(
        children: [
          ...state.optimizationSuggestions.map((s) => _buildInsightCard(theme, s, LucideIcons.lightbulb, Colors.orange)),
          const SizedBox(height: 8),
          ...state.aiRecommendations.map((r) => _buildInsightCard(theme, r, LucideIcons.sparkles, Colors.purple)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(ThemeData theme, String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
