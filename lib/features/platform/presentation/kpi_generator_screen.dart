import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'providers/kpi_generator_provider.dart';

class KpiGeneratorScreen extends ConsumerStatefulWidget {
  const KpiGeneratorScreen({super.key});

  @override
  ConsumerState<KpiGeneratorScreen> createState() => _KpiGeneratorScreenState();
}

class _KpiGeneratorScreenState extends ConsumerState<KpiGeneratorScreen> {
  final _numberFormat = NumberFormat.compact();
  final _currencyFormat = NumberFormat.compactCurrency(symbol: '\$');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kpiGeneratorProvider.notifier).generate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(kpiGeneratorProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Live KPI Generator'),
        centerTitle: false,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDesktop)
            Container(
              width: 320,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
              ),
              child: _buildControls(theme, state),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isDesktop)
                    ExpansionTile(
                      title: const Text('Generator Controls'),
                      initiallyExpanded: false,
                      children: [_buildControls(theme, state)],
                    ),
                  if (!isDesktop) const SizedBox(height: 24),
                  if (state.isGenerating)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state.data.revenueData.isNotEmpty)
                    _buildDashboard(theme, state).animate(key: ValueKey(state.data.hashCode)).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ThemeData theme, KpiGeneratorState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Size', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<BusinessSize>(
            value: state.businessSize,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: BusinessSize.values.map((size) {
              return DropdownMenuItem(
                value: size,
                child: Text(size.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                ref.read(kpiGeneratorProvider.notifier).updateBusinessSize(val);
              }
            },
          ),
          const SizedBox(height: 24),
          Text('Industry Context', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: state.industry,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'Furniture', child: Text('Furniture')),
              DropdownMenuItem(value: 'Steel', child: Text('Steel')),
              DropdownMenuItem(value: 'Garments', child: Text('Garments')),
              DropdownMenuItem(value: 'Kitchenware', child: Text('Kitchenware')),
            ],
            onChanged: (val) {
              if (val != null) {
                ref.read(kpiGeneratorProvider.notifier).updateIndustry(val);
              }
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text('Growth Rates', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildSlider(
            theme,
            'Revenue Growth',
            state.revenueGrowthRate,
            (val) => ref.read(kpiGeneratorProvider.notifier).updateGrowthRate(revenue: val),
          ),
          _buildSlider(
            theme,
            'User Growth',
            state.usersGrowthRate,
            (val) => ref.read(kpiGeneratorProvider.notifier).updateGrowthRate(users: val),
          ),
          _buildSlider(
            theme,
            'Order Volume Growth',
            state.ordersGrowthRate,
            (val) => ref.read(kpiGeneratorProvider.notifier).updateGrowthRate(orders: val),
          ),
          _buildSlider(
            theme,
            'Production Volume Growth',
            state.productionGrowthRate,
            (val) => ref.read(kpiGeneratorProvider.notifier).updateGrowthRate(production: val),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isGenerating
                  ? null
                  : () {
                      ref.read(kpiGeneratorProvider.notifier).generate();
                    },
              icon: const Icon(LucideIcons.activity),
              label: const Text('Generate KPIs'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(ThemeData theme, String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.bodyMedium),
            Text('${(value * 100).toStringAsFixed(1)}%', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: -0.2,
          max: 0.5,
          divisions: 70,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDashboard(ThemeData theme, KpiGeneratorState state) {
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);
    final isTablet = ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Generated Dashboard Overview', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Chip(
              label: Text(state.industry, style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildMetricCard(theme, 'Total Revenue', _currencyFormat.format(state.data.totalRevenue), state.data.revenueGrowth, LucideIcons.circleDollarSign),
            _buildMetricCard(theme, 'Active Users', _numberFormat.format(state.data.totalUsers), state.data.usersGrowth, LucideIcons.users),
            _buildMetricCard(theme, 'Total Orders', _numberFormat.format(state.data.totalOrders), state.data.ordersGrowth, LucideIcons.shoppingCart),
            _buildMetricCard(theme, 'Production Volume', _numberFormat.format(state.data.totalProduction), state.data.productionGrowth, LucideIcons.factory),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: isMobile ? 1 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isMobile ? 1.0 : 1.4,
          children: [
            _buildChartCard(theme, 'Revenue Trend (Trailing 12M)', state.data.revenueData, theme.colorScheme.primary),
            _buildChartCard(theme, 'User Acquisition', state.data.usersData, theme.colorScheme.tertiary),
            _buildChartCard(theme, 'Order Volume', state.data.ordersData, theme.colorScheme.secondary),
            _buildChartCard(theme, 'Production Output', state.data.productionData, theme.colorScheme.error),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String value, double growth, IconData icon) {
    final isPositive = growth >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Icon(icon, size: 20, color: theme.colorScheme.primary),
              ],
            ),
            Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Icon(isPositive ? LucideIcons.trendingUp : LucideIcons.trendingDown, 
                     size: 16, 
                     color: isPositive ? Colors.green : Colors.red),
                const SizedBox(width: 4),
                Text(
                  '${growth.abs().toStringAsFixed(1)}% vs last year',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(ThemeData theme, String title, List<FlSpot> spots, Color color) {
    if (spots.isEmpty) return const SizedBox.shrink();

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2;
    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.8;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(
                    show: true,
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 2,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 11,
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
