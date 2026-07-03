import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../domain/models/notification_dashboard_data.dart';
import 'providers/notification_dashboard_provider.dart';

class NotificationDashboardScreen extends ConsumerStatefulWidget {
  const NotificationDashboardScreen({super.key});

  @override
  ConsumerState<NotificationDashboardScreen> createState() => _NotificationDashboardScreenState();
}

class _NotificationDashboardScreenState extends ConsumerState<NotificationDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationDashboardProvider);
    final notifier = ref.read(notificationDashboardProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 800) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notification Engine', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Centralized analytics for platform communications.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            const SizedBox(height: 16),
                            _buildToolbar(context, theme, state, notifier),
                          ],
                        );
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Notification Engine', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Centralized analytics for platform communications.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          _buildToolbar(context, theme, state, notifier),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  _buildContent(context, theme, state, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, NotificationDashboardState state, NotificationDashboardNotifier notifier) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildDropdown(theme, 'Time', state.timeFilter, ['Today', 'This Week', 'This Month'], (v) => notifier.updateFilters(timeFilter: v)),
        _buildDropdown(theme, 'Channel', state.channelFilter, ['All', 'Email', 'SMS', 'WhatsApp', 'Push'], (v) => notifier.updateFilters(channelFilter: v)),
        _buildDropdown(theme, 'Priority', state.priorityFilter, ['All', 'High', 'Normal', 'Low'], (v) => notifier.updateFilters(priorityFilter: v)),
        _buildDropdown(theme, 'Module', state.moduleFilter, ['All', 'Approvals', 'HR', 'Finance', 'Sales', 'Inventory'], (v) => notifier.updateFilters(moduleFilter: v)),
      ],
    );
  }

  Widget _buildDropdown(ThemeData theme, String hint, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          style: theme.textTheme.bodyMedium,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, NotificationDashboardState state, NotificationDashboardNotifier notifier) {
    if (state.status == DashboardState.loading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(64.0),
        child: CircularProgressIndicator(),
      ));
    }
    
    if (state.status == DashboardState.error) {
      return Center(
        child: Column(
          children: [
            Icon(LucideIcons.alertTriangle, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load notification analytics', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.updateFilters(), // Trigger reload
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (state.status == DashboardState.empty || state.data == null) {
      return Center(
        child: Column(
          children: [
            Icon(LucideIcons.inbox, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No notification data found for the selected filters', style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    final data = state.data!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildKPIGrid(context, theme, data.kpis),
        const SizedBox(height: 32),
        _buildChartsRow1(context, theme, data),
        const SizedBox(height: 32),
        _buildChartsRow2(context, theme, data),
        const SizedBox(height: 32),
        _buildWidgetsRow1(context, theme, data, notifier),
        const SizedBox(height: 32),
        _buildWidgetsRow2(context, theme, data),
      ],
    );
  }

  Widget _buildKPIGrid(BuildContext context, ThemeData theme, Map<String, String> kpis) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 4 : (constraints.maxWidth > 800 ? 2 : 1);
        final cardWidth = (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: kpis.entries.map((e) {
            IconData icon;
            Color color;
            switch (e.key) {
              case 'Notifications Sent': icon = LucideIcons.send; color = Colors.blue; break;
              case 'Pending Notifications': icon = LucideIcons.clock; color = Colors.orange; break;
              case 'Failed Deliveries': icon = LucideIcons.alertCircle; color = Colors.red; break;
              case 'Delivery Success Rate': icon = LucideIcons.checkCircle; color = Colors.green; break;
              case 'Email Sent': icon = LucideIcons.mail; color = Colors.blueAccent; break;
              case 'SMS Sent': icon = LucideIcons.messageSquare; color = Colors.greenAccent.shade700; break;
              case 'WhatsApp Sent': icon = LucideIcons.messageCircle; color = Colors.teal; break;
              case 'Push Sent': icon = LucideIcons.smartphone; color = Colors.purple; break;
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
                          Flexible(child: Text(e.key, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Icon(icon, color: color, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(e.value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
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

  Widget _buildChartsRow1(BuildContext context, ThemeData theme, NotificationDashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        
        final trendChart = _buildChartCard(
          theme: theme,
          title: 'Notification Trend',
          child: _buildTrendChart(theme, data.trendData),
        );
        
        final channelChart = _buildChartCard(
          theme: theme,
          title: 'Channel Distribution',
          child: _buildPieChart(theme, data.channelDistribution),
        );

        if (isDesktop) {
          return Row(
            children: [
              Expanded(flex: 2, child: trendChart),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: channelChart),
            ],
          );
        } else {
          return Column(
            children: [
              trendChart,
              const SizedBox(height: 16),
              channelChart,
            ],
          );
        }
      }
    );
  }

  Widget _buildChartsRow2(BuildContext context, ThemeData theme, NotificationDashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 900;
        
        final moduleChart = _buildChartCard(
          theme: theme,
          title: 'Volume by Module',
          child: _buildBarChart(theme, data.volumeByModule),
        );
        
        final successChart = _buildChartCard(
          theme: theme,
          title: 'Delivery Success Rate',
          child: _buildPieChart(theme, data.successRate), // Pie chart representing success rate
        );

        if (isDesktop) {
          return Row(
            children: [
              Expanded(flex: 2, child: moduleChart),
              const SizedBox(width: 16),
              Expanded(flex: 1, child: successChart),
            ],
          );
        } else {
          return Column(
            children: [
              moduleChart,
              const SizedBox(height: 16),
              successChart,
            ],
          );
        }
      }
    );
  }

  Widget _buildWidgetsRow1(BuildContext context, ThemeData theme, NotificationDashboardData data, NotificationDashboardNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        
        final recentWidget = _buildListCard(
          theme: theme,
          title: 'Recent Notifications',
          items: data.recentNotifications,
          icon: LucideIcons.activity,
          itemBuilder: (item) => _buildNotificationListItem(theme, item, null),
        );
        
        final failedWidget = _buildListCard(
          theme: theme,
          title: 'Failed Deliveries',
          items: data.failedDeliveries,
          icon: LucideIcons.alertOctagon,
          iconColor: Colors.red,
          itemBuilder: (item) => _buildNotificationListItem(
            theme, 
            item, 
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              onPressed: () => notifier.retryFailed(item.id),
              tooltip: 'Retry',
            ),
          ),
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: recentWidget),
              const SizedBox(width: 16),
              Expanded(child: failedWidget),
            ],
          );
        } else {
          return Column(
            children: [
              recentWidget,
              const SizedBox(height: 16),
              failedWidget,
            ],
          );
        }
      }
    );
  }

  Widget _buildWidgetsRow2(BuildContext context, ThemeData theme, NotificationDashboardData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        
        final pendingWidget = _buildListCard(
          theme: theme,
          title: 'Pending Queue',
          items: data.pendingQueue,
          icon: LucideIcons.clock,
          iconColor: Colors.orange,
          itemBuilder: (item) => _buildNotificationListItem(theme, item, null),
        );
        
        final scheduledWidget = _buildListCard(
          theme: theme,
          title: 'Upcoming Scheduled',
          items: data.upcomingScheduled,
          icon: LucideIcons.calendar,
          iconColor: Colors.blue,
          itemBuilder: (item) => _buildNotificationListItem(theme, item, null),
        );

        final templatesWidget = _buildListCard(
          theme: theme,
          title: 'Top Templates',
          items: data.topTemplates,
          icon: LucideIcons.fileText,
          iconColor: Colors.purple,
          itemBuilder: (CategoryDataPoint item) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(LucideIcons.fileCode, size: 16, color: theme.colorScheme.primary),
            ),
            title: Text(item.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            trailing: Text(NumberFormat.compact().format(item.value), style: theme.textTheme.bodyMedium),
          ),
        );

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: pendingWidget),
              const SizedBox(width: 16),
              Expanded(child: scheduledWidget),
              const SizedBox(width: 16),
              Expanded(child: templatesWidget),
            ],
          );
        } else {
          return Column(
            children: [
              pendingWidget,
              const SizedBox(height: 16),
              scheduledWidget,
              const SizedBox(height: 16),
              templatesWidget,
            ],
          );
        }
      }
    );
  }

  Widget _buildChartCard({required ThemeData theme, required String title, required Widget child}) {
    return Card(
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
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard<T>({
    required ThemeData theme,
    required String title,
    required IconData icon,
    Color? iconColor,
    required List<T> items,
    required Widget Function(T) itemBuilder,
  }) {
    return Card(
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
              children: [
                Icon(icon, color: iconColor ?? theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(child: Text('No items to display', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
              )
            else
              ...items.map((item) => itemBuilder(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationListItem(ThemeData theme, NotificationItem item, Widget? trailingAction) {
    IconData channelIcon;
    Color channelColor;
    switch (item.channel) {
      case 'Email': channelIcon = LucideIcons.mail; channelColor = Colors.blue; break;
      case 'SMS': channelIcon = LucideIcons.messageSquare; channelColor = Colors.green; break;
      case 'WhatsApp': channelIcon = LucideIcons.messageCircle; channelColor = Colors.teal; break;
      case 'Push': channelIcon = LucideIcons.smartphone; channelColor = Colors.purple; break;
      default: channelIcon = LucideIcons.bell; channelColor = Colors.grey;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: channelColor.withOpacity(0.1),
        child: Icon(channelIcon, size: 16, color: channelColor),
      ),
      title: Text(item.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(item.recipient, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(item.module, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.blueGrey)),
              const SizedBox(width: 8),
              Text(DateFormat('MMM dd, HH:mm').format(item.timestamp), style: const TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
      trailing: trailingAction ?? _buildStatusBadge(item.status, theme),
      isThreeLine: true,
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    if (status.contains('Delivered')) color = Colors.green;
    else if (status.contains('Pending') || status.contains('Scheduled')) color = Colors.orange;
    else if (status.contains('Failed') || status.contains('Bounced')) color = Colors.red;
    else color = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // --- Chart Builders ---

  Widget _buildTrendChart(ThemeData theme, List<ChartDataPoint> data) {
    if (data.isEmpty) return const SizedBox();
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[value.toInt()].label, style: theme.textTheme.bodySmall),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ThemeData theme, List<CategoryDataPoint> data) {
    if (data.isEmpty) return const SizedBox();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(data[value.toInt()].category.substring(0, min(3, data[value.toInt()].category.length)), style: theme.textTheme.bodySmall),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.value,
                color: theme.colorScheme.tertiary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(ThemeData theme, List<CategoryDataPoint> data) {
    if (data.isEmpty) return const SizedBox();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.map((e) {
          Color color;
          if (e.colorHex != null) {
            color = Color(int.parse(e.colorHex!.substring(1, 7), radix: 16) + 0xFF000000);
          } else {
            color = theme.colorScheme.primary;
          }
          
          return PieChartSectionData(
            color: color,
            value: e.value,
            title: '${e.category}\n${e.value.toInt()}',
            radius: 50,
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }
}
