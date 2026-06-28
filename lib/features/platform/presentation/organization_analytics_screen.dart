import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/presentation/widgets/premium_dashboard_widgets.dart';

class OrganizationAnalyticsScreen extends ConsumerStatefulWidget {
  final String orgId;

  const OrganizationAnalyticsScreen({
    Key? key,
    required this.orgId,
  }) : super(key: key);

  @override
  ConsumerState<OrganizationAnalyticsScreen> createState() => _OrganizationAnalyticsScreenState();
}

class _OrganizationAnalyticsScreenState extends ConsumerState<OrganizationAnalyticsScreen> {
  String _selectedDateRange = 'Last 30 Days';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Organization Analytics', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/organizations/${widget.orgId}'),
        ),
        actions: [
          DropdownButton<String>(
            value: _selectedDateRange,
            icon: const Icon(LucideIcons.calendar, size: 16),
            underline: const SizedBox(),
            alignment: Alignment.centerRight,
            items: ['Last 7 Days', 'Last 30 Days', 'Last Quarter', 'Year to Date'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(value),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                if (newValue != null) _selectedDateRange = newValue;
              });
            },
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting Dashboard to PDF...')));
            },
            icon: const Icon(LucideIcons.download, size: 16),
            label: const Text('Export Dashboard'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildKpiRow(isDesktop),
            const SizedBox(height: 24),
            _buildChartsRow1(isDesktop),
            const SizedBox(height: 24),
            _buildChartsRow2(isDesktop),
            const SizedBox(height: 24),
            _buildWidgetsRow(isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRow(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = isDesktop ? 6 : (ResponsiveBreakpoints.of(context).largerThan(MOBILE) ? 3 : 2);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isDesktop ? 1.2 : 1.1,
          children: [
            _buildKpiCard('Employees', '1,245', '+12%', LucideIcons.users, [Colors.blue.shade700, Colors.blue.shade500]),
            _buildKpiCard('Branches', '12', '+1', LucideIcons.gitBranch, [Colors.purple.shade700, Colors.purple.shade500]),
            _buildKpiCard('Departments', '24', '0', LucideIcons.network, [Colors.orange.shade700, Colors.orange.shade500]),
            _buildKpiCard('Active Users', '892', '+5%', LucideIcons.userCheck, [Colors.teal.shade700, Colors.teal.shade500]),
            _buildKpiCard('Storage', '450 GB', '+20 GB', LucideIcons.hardDrive, [Colors.red.shade700, Colors.red.shade500]),
            _buildKpiCard('Logins/Day', '3.4K', '+15%', LucideIcons.logIn, [Colors.indigo.shade700, Colors.indigo.shade500]),
          ],
        );
      }
    );
  }

  Widget _buildKpiCard(String title, String value, String trend, IconData icon, List<Color> colors) {
    return GradientKpiCard(
      title: title,
      value: value,
      subtitle: trend,
      icon: icon,
      gradientColors: colors,
    );
  }

  Widget _buildChartsRow1(bool isDesktop) {
    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: _buildEmployeeGrowthChart()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildDepartmentDistributionChart()),
            ],
          )
        : Column(
            children: [
              _buildEmployeeGrowthChart(),
              const SizedBox(height: 24),
              _buildDepartmentDistributionChart(),
            ],
          );
  }

  Widget _buildEmployeeGrowthChart() {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.trendingUp, size: 20, color: Colors.blue),
              const SizedBox(width: 12),
              const Text('Employee Growth', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
        height: 300,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(months[value.toInt()], style: const TextStyle(fontSize: 12)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}', style: const TextStyle(fontSize: 12));
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
                  FlSpot(0, 1000), FlSpot(1, 1050), FlSpot(2, 1080), FlSpot(3, 1100),
                  FlSpot(4, 1150), FlSpot(5, 1180), FlSpot(6, 1200), FlSpot(7, 1220),
                  FlSpot(8, 1230), FlSpot(9, 1240), FlSpot(10, 1245),
                ],
                isCurved: true,
                color: Colors.blue,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.blue.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildDepartmentDistributionChart() {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.pieChart, size: 20, color: Colors.purple),
              const SizedBox(width: 12),
              const Text('Department Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
        height: 300,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 60,
            sections: [
              PieChartSectionData(value: 35, color: Colors.blue, title: 'Production (35%)', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              PieChartSectionData(value: 25, color: Colors.purple, title: 'Sales (25%)', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              PieChartSectionData(value: 15, color: Colors.orange, title: 'Finance (15%)', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              PieChartSectionData(value: 15, color: Colors.teal, title: 'HR (15%)', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              PieChartSectionData(value: 10, color: Colors.red, title: 'IT (10%)', radius: 40, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildChartsRow2(bool isDesktop) {
    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildBranchComparisonChart()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildStorageUsageChart()),
            ],
          )
        : Column(
            children: [
              _buildBranchComparisonChart(),
              const SizedBox(height: 24),
              _buildStorageUsageChart(),
            ],
          );
  }

  Widget _buildBranchComparisonChart() {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChart2, size: 20, color: Colors.orange),
              const SizedBox(width: 12),
              const Text('Branch Comparison (Employees)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 500,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const titles = ['New York', 'London', 'Tokyo', 'Berlin', 'Sydney'];
                    if (value.toInt() >= 0 && value.toInt() < titles.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 12)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}', style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 420, color: Colors.purple, width: 16, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 310, color: Colors.purple, width: 16, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 215, color: Colors.purple, width: 16, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 180, color: Colors.purple, width: 16, borderRadius: BorderRadius.circular(4))]),
              BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 120, color: Colors.purple, width: 16, borderRadius: BorderRadius.circular(4))]),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildStorageUsageChart() {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.hardDrive, size: 20, color: Colors.red),
              const SizedBox(width: 12),
              const Text('Storage Usage Over Time (GB)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true, drawVerticalLine: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(months[value.toInt()], style: const TextStyle(fontSize: 12)),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}', style: const TextStyle(fontSize: 12));
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
                  FlSpot(0, 100), FlSpot(1, 150), FlSpot(2, 220), FlSpot(3, 310),
                  FlSpot(4, 380), FlSpot(5, 450),
                ],
                isCurved: false,
                color: Colors.red,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildWidgetsRow(bool isDesktop) {
    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildAiInsightsWidget()),
              const SizedBox(width: 24),
              Expanded(flex: 1, child: _buildRecentActivitiesWidget()),
            ],
          )
        : Column(
            children: [
              _buildAiInsightsWidget(),
              const SizedBox(height: 24),
              _buildRecentActivitiesWidget(),
            ],
          );
  }

  Widget _buildAiInsightsWidget() {
    final insights = [
      {'icon': LucideIcons.trendingUp, 'color': Colors.green, 'text': 'Employee count grew by 12% this quarter, highest in New York branch.'},
      {'icon': LucideIcons.alertTriangle, 'color': Colors.orange, 'text': 'Storage usage is projected to reach 500GB limit within 45 days. Consider upgrading plan.'},
      {'icon': LucideIcons.zap, 'color': Colors.blue, 'text': 'User engagement (logins/day) increased after the new UI rollout last week.'},
    ];

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, size: 20, color: Colors.blue),
              const SizedBox(width: 12),
              const Text('AI Insights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: (insight['color'] as Color).withOpacity(0.1),
              child: Icon(insight['icon'] as IconData, color: insight['color'] as Color, size: 20),
            ),
            title: Text(insight['text'] as String, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesWidget() {
    final activities = [
      {'title': 'New branch opened in Sydney', 'time': '2 hours ago', 'icon': LucideIcons.gitBranch},
      {'title': '15 new employees onboarded in Production', 'time': '5 hours ago', 'icon': LucideIcons.userPlus},
      {'title': 'System upgrade completed for Organization', 'time': '1 day ago', 'icon': LucideIcons.server},
      {'title': 'Storage limit warning issued', 'time': '2 days ago', 'icon': LucideIcons.hardDrive},
    ];

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.activity, size: 20, color: Colors.indigo),
              const SizedBox(width: 12),
              const Text('Recent Activities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          ...activities.map((activity) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(activity['icon'] as IconData, color: Colors.grey.shade600),
            title: Text(activity['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            subtitle: Text(activity['time'] as String, style: const TextStyle(fontSize: 12)),
          );
        }).toList(),
        ],
      ),
    );
  }
}
