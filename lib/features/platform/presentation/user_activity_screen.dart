import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/user_activity.dart';
import 'providers/user_activity_provider.dart';

class UserActivityScreen extends ConsumerWidget {
  final String userId;

  const UserActivityScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Call init once when screen loads (safe to call multiple times — init checks userId)
    final notifier = ref.read(userActivityProvider.notifier);
    final currentState = ref.read(userActivityProvider);
    if (currentState.userId != userId) {
      Future.microtask(() => notifier.init(userId));
    }
    final state = ref.watch(userActivityProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('User Activity Log'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/users/$userId'),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatsCards(context, state, isDesktop),
                  const SizedBox(height: 24),
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildLineChart(context, state)),
                            const SizedBox(width: 24),
                            Expanded(flex: 2, child: _buildModuleUsageChart(context, state)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLineChart(context, state),
                            const SizedBox(height: 24),
                            _buildModuleUsageChart(context, state),
                          ],
                        ),
                  const SizedBox(height: 24),
                  _buildToolbar(context, state, ref),
                  const SizedBox(height: 16),
                  _buildMainContent(context, state, ref),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards(BuildContext context, UserActivityState state, bool isDesktop) {
    final cards = [
      _buildStatCard(context, 'Recent Activity', '${state.stats['recentCount'] ?? 0}', LucideIcons.activity, Colors.blue),
      _buildStatCard(context, 'Most Used', state.stats['mostUsedModule'] as String? ?? 'N/A', LucideIcons.box, Colors.purple),
      _buildStatCard(context, 'Primary Location', state.stats['primaryLocation'] as String? ?? 'N/A', LucideIcons.mapPin, Colors.orange),
      _buildStatCard(context, 'Primary Device', state.stats['primaryDevice'] as String? ?? 'N/A', LucideIcons.laptop, Colors.green),
    ];

    if (isDesktop) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i < cards.length - 1) const SizedBox(width: 16),
          ],
        ],
      );
    }
    return Column(
      children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16), child: c)).toList(),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return PremiumCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey)),
                Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildToolbar(BuildContext context, UserActivityState state, WidgetRef ref) {
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Today', label: Text('Today')),
            ButtonSegment(value: 'This Week', label: Text('Week')),
            ButtonSegment(value: 'This Month', label: Text('Month')),
          ],
          selected: {state.timeFilter},
          onSelectionChanged: (set) => ref.read(userActivityProvider.notifier).setTimeFilter(set.first),
        ),
        DropdownMenu<String>(
          initialSelection: state.typeFilter,
          label: const Text('Activity Type'),
          onSelected: (val) {
            if (val != null) ref.read(userActivityProvider.notifier).setTypeFilter(val);
          },
          dropdownMenuEntries: [
            const DropdownMenuEntry(value: 'All', label: 'All Activities'),
            ...ActivityType.values.map((t) => DropdownMenuEntry(
              value: t.toString().split('.').last,
              label: _formatEnumName(t.toString().split('.').last),
            )),
          ],
        ),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'timeline', icon: Icon(LucideIcons.list), label: Text('Timeline')),
            ButtonSegment(value: 'table', icon: Icon(LucideIcons.table2), label: Text('Table')),
          ],
          selected: {state.viewMode},
          onSelectionChanged: (set) => ref.read(userActivityProvider.notifier).setViewMode(set.first),
        ),
      ],
    );
  }

  String _formatEnumName(String name) {
    return name.replaceAllMapped(RegExp(r'[A-Z]'), (m) => ' ${m.group(0)!}')
        .trim()
        .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m.group(0)!.toUpperCase());
  }

  Widget _buildMainContent(BuildContext context, UserActivityState state, WidgetRef ref) {
    if (state.filteredActivities.isEmpty) {
      return PremiumCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: Text('No activities found for the selected filters.'),
          ),
        ),
      );
    }
    return state.viewMode == 'timeline'
        ? _buildTimelineView(context, state)
        : _buildTableView(context, state);
  }

  Widget _buildTimelineView(BuildContext context, UserActivityState state) {
    return PremiumCard(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.filteredActivities.length,
        itemBuilder: (context, index) {
          final activity = state.filteredActivities[index];
          final isLast = index == state.filteredActivities.length - 1;
          final color = _getColorForType(activity.type);
          final icon = _getIconForType(activity.type);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(DateFormat.MMMEd().format(activity.timestamp), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      Text(DateFormat.jm().format(activity.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                      child: Icon(icon, size: 16, color: color),
                    ),
                    if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.withOpacity(0.2))),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                              child: Text(_formatEnumName(activity.type.toString().split('.').last), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            if (activity.status == 'failed')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: const Text('FAILED', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(activity.description, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 16,
                          children: [
                            if (activity.deviceInfo != null)
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(LucideIcons.smartphone, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(activity.deviceInfo!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ]),
                            if (activity.location != null)
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(LucideIcons.mapPin, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(activity.location!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ]),
                            if (activity.ipAddress != null)
                              Row(mainAxisSize: MainAxisSize.min, children: [
                                const Icon(LucideIcons.globe, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(activity.ipAddress!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).animate().fade().slideY();
  }

  Widget _buildTableView(BuildContext context, UserActivityState state) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                Expanded(flex: 14, child: Text('Timestamp', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 12, child: Text('Type', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 24, child: Text('Description', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 16, child: Text('Device', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 10, child: Text('IP', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
                Expanded(flex: 8, child: Text('Status', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Divider(height: 1),
          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.filteredActivities.length,
            separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withOpacity(0.3)),
            itemBuilder: (context, index) {
              final a = state.filteredActivities[index];
              final color = _getColorForType(a.type);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Row(
                  children: [
                    Expanded(flex: 14, child: Text(DateFormat('MMM dd, HH:mm').format(a.timestamp), style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(
                      flex: 12,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getIconForType(a.type), size: 14, color: color),
                          const SizedBox(width: 6),
                          Expanded(child: Text(_formatEnumName(a.type.toString().split('.').last), style: TextStyle(fontSize: 12, color: color), overflow: TextOverflow.ellipsis)),
                        ],
                      ),
                    ),
                    Expanded(flex: 24, child: Text(a.description, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 16, child: Text(a.deviceInfo ?? '-', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 10, child: Text(a.ipAddress ?? '-', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 8, child: _buildStatusChip(a.status)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fade().slideY();
  }

  Widget _buildStatusChip(String status) {
    final color = status == 'failed' ? Colors.red : status == 'warning' ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.4))),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  IconData _getIconForType(ActivityType type) {
    if (type == ActivityType.login) return LucideIcons.logIn;
    if (type == ActivityType.logout) return LucideIcons.logOut;
    if (type == ActivityType.passwordChange) return LucideIcons.key;
    if (type == ActivityType.roleAssignment) return LucideIcons.shield;
    if (type == ActivityType.documentAccess) return LucideIcons.fileText;
    if (type == ActivityType.workflowApproval) return LucideIcons.checkCircle;
    if (type == ActivityType.reportDownload) return LucideIcons.download;
    if (type == ActivityType.aiUsage) return LucideIcons.bot;
    return LucideIcons.activity;
  }

  Color _getColorForType(ActivityType type) {
    if (type == ActivityType.login) return Colors.green;
    if (type == ActivityType.logout) return Colors.grey;
    if (type == ActivityType.passwordChange) return Colors.orange;
    if (type == ActivityType.roleAssignment) return Colors.purple;
    if (type == ActivityType.documentAccess) return Colors.blue;
    if (type == ActivityType.workflowApproval) return Colors.teal;
    if (type == ActivityType.reportDownload) return Colors.indigo;
    if (type == ActivityType.aiUsage) return Colors.pink;
    return Colors.blue;
  }

  Widget _buildLineChart(BuildContext context, UserActivityState state) {
    final theme = Theme.of(context);
    final data = state.charts['activity_trend'] as List<dynamic>? ?? [];
    if (data.isEmpty) return const SizedBox.shrink();

    List<FlSpot> spots = [];
    double maxY = 0;
    for (int i = 0; i < data.length; i++) {
      final y = (data[i]['count'] as num).toDouble();
      if (y > maxY) maxY = y;
      spots.add(FlSpot(i.toDouble(), y));
    }
    if (maxY == 0) maxY = 10;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activity Trend (7 Days)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i >= 0 && i < data.length) {
                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(data[i]['day'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)));
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0, maxX: (data.length - 1).toDouble(), minY: 0, maxY: maxY * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(colors: [Colors.blue.withOpacity(0.3), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    ).animate().fade().slideY();
  }

  Widget _buildModuleUsageChart(BuildContext context, UserActivityState state) {
    final theme = Theme.of(context);
    final data = state.charts['module_usage'] as List<dynamic>? ?? [];
    if (data.isEmpty) return const SizedBox.shrink();

    List<BarChartGroupData> barGroups = [];
    List<String> labels = [];
    double maxY = 0;

    for (int i = 0; i < data.length; i++) {
      final y = (data[i]['value'] as num).toDouble();
      if (y > maxY) maxY = y;
      barGroups.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: y, color: Colors.purple, width: 22, borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)))]));
      labels.add(data[i]['module'] as String);
    }
    if (maxY == 0) maxY = 10;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Module Usage', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1)),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final i = value.toInt();
                      if (i >= 0 && i < labels.length) {
                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(labels[i].split(' ')[0], style: const TextStyle(fontSize: 10, color: Colors.grey)));
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
              maxY: maxY * 1.2,
            )),
          ),
        ],
      ),
    ).animate().fade().slideY();
  }
}
