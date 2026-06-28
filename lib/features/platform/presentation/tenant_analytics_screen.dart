import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/tenant_analytics_provider.dart';

class TenantAnalyticsScreen extends ConsumerStatefulWidget {
  final String tenantId;
  const TenantAnalyticsScreen({super.key, required this.tenantId});

  @override
  ConsumerState<TenantAnalyticsScreen> createState() => _TenantAnalyticsScreenState();
}

class _TenantAnalyticsScreenState extends ConsumerState<TenantAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final asyncState = ref.watch(tenantAnalyticsProvider(widget.tenantId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tenant Analytics Dashboard'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/tenants/${widget.tenantId}'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting Analytics Dashboard to PDF...')));
              },
              icon: const Icon(LucideIcons.download, size: 18),
              label: const Text('Export Dashboard'),
            ),
          ),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 32),
                _buildKpiGrid(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildChartsRow1(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildChartsRow2(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildActivityHeatmapAndStorage(context, state, isDesktop),
                const SizedBox(height: 32),
                _buildInsightsRow(context, state, isDesktop),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TenantAnalyticsState state) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(state.tenant.logoUrl),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${state.tenant.name} - Deep Analytics', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('Viewing analytics data for the last 6 months', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, TenantAnalyticsState state, bool isDesktop) {
    final kpis = state.kpis;
    final cards = [
      GradientKpiCard(title: 'Revenue', value: kpis['revenue'], subtitle: 'MRR Contribution', icon: LucideIcons.dollarSign, gradientColors: [Colors.green.shade700, Colors.green.shade400]),
      GradientKpiCard(title: 'Active Users', value: kpis['users'], subtitle: 'Currently registered', icon: LucideIcons.users, gradientColors: [Colors.blue.shade700, Colors.blue.shade400]),
      GradientKpiCard(title: 'Organizations', value: kpis['organizations'], subtitle: 'Managed instances', icon: LucideIcons.building, gradientColors: [Colors.purple.shade700, Colors.purple.shade400]),
      GradientKpiCard(title: 'Storage Used', value: kpis['storage_used'], subtitle: 'Database & Assets', icon: LucideIcons.hardDrive, gradientColors: [Colors.teal.shade700, Colors.teal.shade400]),
      GradientKpiCard(title: 'API Calls', value: kpis['api_calls'], subtitle: 'Last 30 days', icon: LucideIcons.activity, gradientColors: [Colors.orange.shade700, Colors.orange.shade400]),
      GradientKpiCard(title: 'Workflows', value: kpis['workflows_executed'], subtitle: 'Executed this month', icon: LucideIcons.cpu, gradientColors: [Colors.indigo.shade700, Colors.indigo.shade400]),
    ];

    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 150,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  Widget _buildChartsRow1(BuildContext context, TenantAnalyticsState state, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildLineChartCard(context, 'Revenue Trend', state.charts['revenue_trend'], Colors.green)),
          const SizedBox(width: 24),
          Expanded(child: _buildLineChartCard(context, 'User Growth', state.charts['user_growth'], Colors.blue)),
        ],
      );
    }
    return Column(
      children: [
        _buildLineChartCard(context, 'Revenue Trend', state.charts['revenue_trend'], Colors.green),
        const SizedBox(height: 24),
        _buildLineChartCard(context, 'User Growth', state.charts['user_growth'], Colors.blue),
      ],
    );
  }

  Widget _buildChartsRow2(BuildContext context, TenantAnalyticsState state, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildBarChartCard(context, 'Login Trend (Last 7 Days)', state.charts['login_trend'], Colors.purple)),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: _buildDonutChartCard(context, 'Module Usage Distribution', state.charts['module_usage'])),
        ],
      );
    }
    return Column(
      children: [
        _buildBarChartCard(context, 'Login Trend (Last 7 Days)', state.charts['login_trend'], Colors.purple),
        const SizedBox(height: 24),
        _buildDonutChartCard(context, 'Module Usage Distribution', state.charts['module_usage']),
      ],
    );
  }
  
  Widget _buildActivityHeatmapAndStorage(BuildContext context, TenantAnalyticsState state, bool isDesktop) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: _buildActivityHeatmapCard(context, state)),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: _buildAreaChartCard(context, 'Storage Growth', state.charts['storage_growth'], Colors.teal)),
        ],
      );
    }
    return Column(
      children: [
        _buildActivityHeatmapCard(context, state),
        const SizedBox(height: 24),
        _buildAreaChartCard(context, 'Storage Growth', state.charts['storage_growth'], Colors.teal),
      ],
    );
  }

  Widget _buildInsightsRow(BuildContext context, TenantAnalyticsState state, bool isDesktop) {
    return Column(
      children: [
        if (isDesktop) Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildSimpleListCard(context, 'Most Active Users', state.activeUsers)),
            const SizedBox(width: 24),
            Expanded(child: _buildSimpleListCard(context, 'Popular Modules', state.popularModules)),
            const SizedBox(width: 24),
            Expanded(child: _buildSimpleListCard(context, 'Slowest Workflows', state.slowestWorkflows)),
          ],
        ) else ...[
          _buildSimpleListCard(context, 'Most Active Users', state.activeUsers),
          const SizedBox(height: 24),
          _buildSimpleListCard(context, 'Popular Modules', state.popularModules),
          const SizedBox(height: 24),
          _buildSimpleListCard(context, 'Slowest Workflows', state.slowestWorkflows),
        ],
        const SizedBox(height: 32),
        _buildAIInsightsCard(context, state.insights),
      ],
    );
  }

  Widget _buildLineChartCard(BuildContext context, String title, List data, Color color) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        int idx = val.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(data[idx]['label'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['value'] as num).toDouble())).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChartCard(BuildContext context, String title, List data, Color color) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        int idx = val.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(data[idx]['label'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), (e.value['value'] as num).toDouble())).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.3),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard(BuildContext context, String title, List data, Color color) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (val, meta) {
                        int idx = val.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(data[idx]['label'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: (e.value['value'] as num).toDouble(),
                      color: color,
                      width: 16,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard(BuildContext context, String title, List data) {
    final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal, Colors.red];
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: data.asMap().entries.map((e) {
                        return PieChartSectionData(
                          color: colors[e.key % colors.length],
                          value: (e.value['value'] as num).toDouble(),
                          title: '${e.value['value']}%',
                          radius: 30,
                          titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 12, 
                            height: 12, 
                            decoration: BoxDecoration(color: colors[e.key % colors.length], borderRadius: BorderRadius.circular(2)),
                          ),
                          const SizedBox(width: 8),
                          Text(e.value['label'], style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmapCard(BuildContext context, TenantAnalyticsState state) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Daily Login & Usage Heatmap (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Y-axis labels (Days)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('Mon', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Tue', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Wed', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Thu', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Fri', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Sat', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text('Sun', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 8),
                // Heatmap Grid
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(24, (hour) => Expanded(
                            child: Column(
                              children: List.generate(7, (day) {
                                final value = state.dailyActivityHeatmap[day][hour];
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.all(1.5),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(value),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          )),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // X-axis labels (Hours)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('12 AM', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          Text('6 AM', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          Text('12 PM', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          Text('6 PM', style: TextStyle(color: Colors.grey, fontSize: 10)),
                          Text('11 PM', style: TextStyle(color: Colors.grey, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleListCard(BuildContext context, String title, List<Map<String, dynamic>> items) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...items.map((item) {
            Widget? leading;
            if (item.containsKey('avatar')) {
              leading = CircleAvatar(radius: 16, backgroundImage: NetworkImage(item['avatar']));
            } else if (title.contains('Module')) {
              leading = const Icon(LucideIcons.box, color: Colors.blue, size: 20);
            } else {
              leading = const Icon(LucideIcons.clock, color: Colors.orange, size: 20);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  leading,
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(item['role'] ?? item['usage'] ?? item['avg_time'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Text(
                      item['activity'] ?? item['trend'] ?? item['status'] ?? '', 
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blueGrey)
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAIInsightsCard(BuildContext context, List<Map<String, dynamic>> insights) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Colors.purple),
              const SizedBox(width: 12),
              const Text('AI Insights & Notifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveBreakpoints.of(context).largerThan(TABLET) ? 2 : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 110,
            ),
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              Color color = Colors.blue;
              IconData icon = LucideIcons.info;
              if (insight['type'] == 'warning') { color = Colors.orange; icon = LucideIcons.alertTriangle; }
              if (insight['type'] == 'alert') { color = Colors.red; icon = LucideIcons.shieldAlert; }
              if (insight['type'] == 'success') { color = Colors.green; icon = LucideIcons.checkCircle; }
              if (insight['type'] == 'insight') { color = Colors.purple; icon = LucideIcons.lightbulb; }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  border: Border.all(color: color.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insight['title'], style: TextStyle(fontWeight: FontWeight.bold, color: color.withOpacity(0.8))),
                          const SizedBox(height: 4),
                          Text(insight['description'], style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
