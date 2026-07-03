import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'providers/ai_dashboard_provider.dart';
import '../domain/ai_dashboard_model.dart';

class AiExecutiveDashboardScreen extends ConsumerWidget {
  const AiExecutiveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiDashboardProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);
    final isTablet = ResponsiveBreakpoints.of(context).largerOrEqualTo(TABLET);

    return Scaffold(
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : state.kpis == null 
          ? _buildErrorState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, ref, state),
                  const SizedBox(height: 24),
                  
                  // KPI Grid
                  GridView.extent(
                    maxCrossAxisExtent: 280,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 130,
                    children: [
                      _buildKpiCard(context, 'AI Requests Today', state.kpis!.requestsToday.toString(), LucideIcons.messageSquare, Colors.blue),
                      _buildKpiCard(context, 'Active AI Users', state.kpis!.activeUsers.toString(), LucideIcons.users, Colors.green),
                      _buildKpiCard(context, 'Automation Hours Saved', state.kpis!.automationHoursSaved.toString(), LucideIcons.clock, Colors.orange),
                      _buildKpiCard(context, 'AI Recommendations', state.kpis!.recommendations.toString(), LucideIcons.lightbulb, Colors.purple),
                      _buildKpiCard(context, 'Reports Generated', state.kpis!.reportsGenerated.toString(), LucideIcons.fileText, Colors.indigo),
                      _buildKpiCard(context, 'Workflows Triggered', state.kpis!.workflowsTriggered.toString(), LucideIcons.zap, Colors.amber),
                      _buildKpiCard(context, 'Predictions Generated', state.kpis!.predictionsGenerated.toString(), LucideIcons.trendingUp, Colors.teal),
                      _buildKpiCard(context, 'AI Success Rate', '${state.kpis!.successRate}%', LucideIcons.checkCircle, Colors.blueGrey),
                    ],
                  ).animate().fade().slideY(begin: 0.1),
                  const SizedBox(height: 24),

                  // Charts Row
                  Flex(
                    direction: isDesktop ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isDesktop ? 2 : 0,
                        child: _buildChartCard(
                          context, 
                          'AI Usage Trend', 
                          _buildUsageChart(theme, state.usageTrends),
                        ),
                      ),
                      if (isDesktop) const SizedBox(width: 16),
                      if (!isDesktop) const SizedBox(height: 16),
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: _buildChartCard(
                          context, 
                          'Department Usage', 
                          _buildDepartmentChart(theme, state.departmentUsage),
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),

                  // Widgets Row
                  Flex(
                    direction: isDesktop ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: _buildRecentConversations(context, state.recentConversations),
                      ),
                      if (isDesktop) const SizedBox(width: 16),
                      if (!isDesktop) const SizedBox(height: 16),
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: _buildPendingSuggestions(context, state.pendingSuggestions),
                      ),
                      if (isDesktop) const SizedBox(width: 16),
                      if (!isDesktop) const SizedBox(height: 16),
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: _buildHealthStatus(context, state.healthStatus),
                      ),
                    ],
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: 24),

                  // Quick Actions & More Insights
                  Flex(
                    direction: isDesktop ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isDesktop ? 2 : 0,
                        child: _buildQuickActions(context),
                      ),
                      if (isDesktop) const SizedBox(width: 16),
                      if (!isDesktop) const SizedBox(height: 16),
                      Expanded(
                        flex: isDesktop ? 1 : 0,
                        child: _buildPopularPrompts(context, state.popularPrompts),
                      ),
                    ],
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1),
                ],
              ),
            ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.alertTriangle, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text('Failed to load AI Dashboard', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AiDashboardState state) {
    final theme = Theme.of(context);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Executive Dashboard', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Overview of AI capabilities and usage.', style: theme.textTheme.bodyMedium),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterDropdown(
              context,
              value: state.timeFilter,
              items: ['Today', 'This Week', 'This Month'],
              onChanged: (val) {
                if (val != null) {
                  ref.read(aiDashboardProvider.notifier).updateFilters(time: val);
                }
              },
            ),
            const SizedBox(width: 8),
            _buildFilterDropdown(
              context,
              value: state.departmentFilter,
              items: ['All', 'Finance', 'HR', 'Operations', 'IT'],
              onChanged: (val) {
                if (val != null) {
                  ref.read(aiDashboardProvider.notifier).updateFilters(dept: val);
                }
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.sparkles, size: 18),
              label: const Text('Ask ERP'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(BuildContext context, {required String value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.textTheme.bodySmall?.color), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(BuildContext context, String title, Widget chart) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(height: 250, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageChart(ThemeData theme, List<AiUsageTrend> trends) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1)),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < trends.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(trends[value.toInt()].date, style: const TextStyle(fontSize: 12)),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text('${(value / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 12));
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: trends.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.requests.toDouble())).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentChart(ThemeData theme, List<DepartmentUsage> data) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.asMap().entries.map((e) {
          return PieChartSectionData(
            color: colors[e.key % colors.length],
            value: e.value.usageCount.toDouble(),
            title: '${(e.value.usageCount / 1000).toStringAsFixed(1)}k',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentConversations(BuildContext context, List<RecentConversation> conversations) {
    final theme = Theme.of(context);
    return _buildListCard(
      context,
      'Recent AI Conversations',
      conversations.map((c) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(LucideIcons.messageCircle, color: Colors.white, size: 16)),
        title: Text(c.topic, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(c.user),
        trailing: Text(c.time, style: theme.textTheme.bodySmall),
      )).toList(),
    );
  }

  Widget _buildPendingSuggestions(BuildContext context, List<PendingSuggestion> suggestions) {
    return _buildListCard(
      context,
      'Pending AI Suggestions',
      suggestions.map((s) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(backgroundColor: Colors.amber, child: Icon(LucideIcons.lightbulb, color: Colors.white, size: 16)),
        title: Text(s.description, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('Impact: ${s.impact}', style: const TextStyle(color: Colors.green)),
        trailing: const Icon(LucideIcons.chevronRight, size: 16),
      )).toList(),
    );
  }

  Widget _buildHealthStatus(BuildContext context, List<AiHealthStatus> statusList) {
    return _buildListCard(
      context,
      'AI Health Status',
      statusList.map((s) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          s.status == 'Operational' ? LucideIcons.checkCircle : LucideIcons.alertTriangle,
          color: s.status == 'Operational' ? Colors.green : Colors.orange,
        ),
        title: Text(s.service, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Text('${s.uptime}%', style: TextStyle(fontWeight: FontWeight.bold, color: s.uptime < 100 ? Colors.orange : Colors.green)),
      )).toList(),
    );
  }

  Widget _buildListCard(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Actions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionChip(context, 'Ask ERP', LucideIcons.messageSquare),
                _buildActionChip(context, 'Generate Report', LucideIcons.fileText),
                _buildActionChip(context, 'Create Workflow', LucideIcons.gitCommit),
                _buildActionChip(context, 'Analyze Data', LucideIcons.barChart2),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      onPressed: () {},
    );
  }

  Widget _buildPopularPrompts(BuildContext context, List<String> prompts) {
    return _buildListCard(
      context,
      'Popular Prompts',
      prompts.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Row(
          children: [
            const Icon(LucideIcons.terminal, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text(p, style: const TextStyle(fontStyle: FontStyle.italic))),
          ],
        ),
      )).toList(),
    );
  }
}
