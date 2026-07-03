import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../domain/models/broadcast_campaign_model.dart';
import 'providers/broadcast_campaign_provider.dart';

class BroadcastCenterScreen extends ConsumerWidget {
  const BroadcastCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(broadcastCampaignProvider);
    final notifier = ref.read(broadcastCampaignProvider.notifier);

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
                  _buildHeader(context, theme),
                  const SizedBox(height: 24),
                  _buildToolbar(context, theme, state, notifier),
                  const SizedBox(height: 32),
                  _buildStatisticsCards(context, theme, state),
                  const SizedBox(height: 32),
                  _buildChartsSection(context, theme, state),
                  const SizedBox(height: 32),
                  _buildCampaignsTable(context, theme, state, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Campaign & Broadcast Center', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        FilledButton.icon(
          onPressed: () => context.go('/platform/notifications/broadcast/new'),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('New Campaign'),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, BroadcastCampaignState state, BroadcastCampaignNotifier notifier) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: notifier.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search campaigns...',
              prefixIcon: const Icon(LucideIcons.search),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedTypeFilter,
              icon: const Icon(LucideIcons.filter, size: 16),
              onChanged: (val) {
                if (val != null) notifier.setTypeFilter(val);
              },
              items: ['All', 'Announcement', 'Maintenance', 'Reminder', 'Marketing', 'Emergency', 'System Update']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(BuildContext context, ThemeData theme, BroadcastCampaignState state) {
    int totalRecipients = 0;
    int totalDelivered = 0;
    int totalOpened = 0;
    int totalFailed = 0;

    for (var c in state.campaigns) {
      totalRecipients += c.recipients;
      totalDelivered += c.delivered;
      totalOpened += c.opened;
      totalFailed += c.failed;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildStatCard('Total Recipients', totalRecipients.toString(), LucideIcons.users, Colors.blue, theme),
            _buildStatCard('Delivered', totalDelivered.toString(), LucideIcons.checkCircle, Colors.green, theme),
            _buildStatCard('Opened', totalOpened.toString(), LucideIcons.mailOpen, Colors.purple, theme),
            _buildStatCard('Failed', totalFailed.toString(), LucideIcons.xCircle, Colors.red, theme),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, ThemeData theme, BroadcastCampaignState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 1000;
        final engagementChart = _buildEngagementChartCard(theme);
        final channelChart = _buildChannelPerformanceChart(theme);

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: engagementChart),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: channelChart),
            ],
          );
        } else {
          return Column(
            children: [
              engagementChart,
              const SizedBox(height: 24),
              channelChart,
            ],
          );
        }
      }
    );
  }

  Widget _buildEngagementChartCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Engagement Overview', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(days[value.toInt()], style: const TextStyle(fontSize: 12)),
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
                          return Text('${value.toInt()}%', style: const TextStyle(fontSize: 12));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 95), FlSpot(1, 98), FlSpot(2, 92), FlSpot(3, 99), FlSpot(4, 96), FlSpot(5, 98), FlSpot(6, 99)
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.green.withOpacity(0.1)),
                    ),
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 65), FlSpot(1, 75), FlSpot(2, 55), FlSpot(3, 85), FlSpot(4, 70), FlSpot(5, 80), FlSpot(6, 75)
                      ],
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: true, color: Colors.purple.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Delivery Rate', Colors.green),
                const SizedBox(width: 24),
                _buildLegendItem('Open Rate', Colors.purple),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildChannelPerformanceChart(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Channel Usage', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(color: Colors.blue, value: 45, title: 'Email\n45%', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(color: Colors.purple, value: 30, title: 'Push\n30%', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(color: Colors.green, value: 15, title: 'SMS\n15%', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                    PieChartSectionData(color: Colors.orange, value: 10, title: 'In-App\n10%', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildCampaignsTable(BuildContext context, ThemeData theme, BroadcastCampaignState state, BroadcastCampaignNotifier notifier) {
    final format = DateFormat('MMM dd, yyyy HH:mm');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Recent Campaigns', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(label: Text('Campaign Name')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Channel')),
                DataColumn(label: Text('Recipients')),
                DataColumn(label: Text('Created At')),
                DataColumn(label: Text('Actions')),
              ],
              rows: state.filteredCampaigns.map((c) {
                return DataRow(
                  cells: [
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text(c.id, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    DataCell(Text(c.type)),
                    DataCell(_buildStatusBadge(c.status, theme)),
                    DataCell(Text(c.channel)),
                    DataCell(Text('${c.recipients}')),
                    DataCell(Text(format.format(c.createdAt))),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(LucideIcons.barChart, size: 18),
                            onPressed: () {},
                            tooltip: 'View Report',
                          ),
                          IconButton(
                            icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                            onPressed: () => notifier.deleteCampaign(c.id),
                            tooltip: 'Delete',
                          ),
                        ],
                      )
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    switch (status) {
      case 'Sent': color = Colors.green; break;
      case 'Scheduled': color = Colors.blue; break;
      case 'Draft': color = Colors.grey; break;
      default: color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
