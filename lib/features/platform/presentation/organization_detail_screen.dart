import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/organization_detail_provider.dart';
import '../domain/models/organization.dart';

class OrganizationDetailScreen extends ConsumerStatefulWidget {
  final String orgId;
  const OrganizationDetailScreen({super.key, required this.orgId});

  @override
  ConsumerState<OrganizationDetailScreen> createState() => _OrganizationDetailScreenState();
}

class _OrganizationDetailScreenState extends ConsumerState<OrganizationDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final asyncState = ref.watch(organizationDetailProvider(widget.orgId));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Organization Details'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/organizations'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: _buildQuickActions(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Branches'),
            Tab(text: 'Departments'),
            Tab(text: 'Users'),
            Tab(text: 'Documents'),
            Tab(text: 'Audit Logs'),
            Tab(text: 'Timeline'),
            Tab(text: 'Analytics'),
          ],
        ),
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (org) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, org, isDesktop),
              _buildBranchesTab(context, org),
              _buildDepartmentsTab(context, org),
              _buildPlaceholderTab('Users', LucideIcons.users),
              _buildPlaceholderTab('Documents', LucideIcons.fileText),
              _buildPlaceholderTab('Audit Logs', LucideIcons.shield),
              _buildPlaceholderTab('Timeline', LucideIcons.clock),
              _buildAnalyticsTab(context, org),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical),
      onSelected: (val) {
        if (val == 'manage_branches') {
          context.go('/platform/organizations/${widget.orgId}/branches');
        } else if (val == 'manage_departments') {
          context.go('/platform/organizations/${widget.orgId}/departments');
        } else if (val == 'view_analytics') {
          context.go('/platform/organizations/${widget.orgId}/analytics');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mock Action: $val')));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(leading: Icon(LucideIcons.edit), title: Text('Edit')),
        ),
        const PopupMenuItem<String>(
          value: 'manage_branches',
          child: ListTile(leading: Icon(LucideIcons.gitBranch), title: Text('Manage Branches')),
        ),
        const PopupMenuItem<String>(
          value: 'manage_departments',
          child: ListTile(leading: Icon(LucideIcons.network), title: Text('Manage Departments')),
        ),
        const PopupMenuItem<String>(
          value: 'view_analytics',
          child: ListTile(leading: Icon(LucideIcons.barChart2), title: Text('Analytics Dashboard')),
        ),
        const PopupMenuItem<String>(
          value: 'view_users',
          child: ListTile(leading: Icon(LucideIcons.users), title: Text('View Users')),
        ),
        const PopupMenuItem<String>(
          value: 'documents',
          child: ListTile(leading: Icon(LucideIcons.fileText), title: Text('Documents')),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'settings',
          child: ListTile(leading: Icon(LucideIcons.settings), title: Text('Settings')),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, Organization org, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, org),
          const SizedBox(height: 24),
          _buildKpiRow(isDesktop),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildEmployeeGrowthChart(context)),
                const SizedBox(width: 24),
                Expanded(child: _buildDepartmentDistribution(context)),
              ],
            )
          else ...[
            _buildEmployeeGrowthChart(context),
            const SizedBox(height: 24),
            _buildDepartmentDistribution(context),
          ],
          const SizedBox(height: 24),
          _buildSummaryCards(context, isDesktop),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, Organization org) {
    final theme = Theme.of(context);
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(org.logoUrl),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(org.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                      child: Text(org.status, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Code: ${org.code} • Tenant: ${org.tenantName} • Industry: ${org.industry}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                const SizedBox(height: 4),
                Text('Created on ${DateFormat.yMMMd().format(org.createdAt)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(bool isDesktop) {
    final cards = [
      const GradientKpiCard(title: 'Business Health', value: '98%', subtitle: 'Operational efficiency', icon: LucideIcons.activity, gradientColors: [Colors.green, Colors.teal]),
      const GradientKpiCard(title: 'Storage Usage', value: '45 GB', subtitle: 'Of 100 GB allocated', icon: LucideIcons.hardDrive, gradientColors: [Colors.blue, Colors.indigo]),
      const GradientKpiCard(title: 'User Growth', value: '+12%', subtitle: 'Last 30 days', icon: LucideIcons.trendingUp, gradientColors: [Colors.orange, Colors.deepOrange]),
      const GradientKpiCard(title: 'Active Projects', value: '14', subtitle: 'Across 4 branches', icon: LucideIcons.briefcase, gradientColors: [Colors.purple, Colors.pink]),
    ];

    if (isDesktop) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: EdgeInsets.only(right: c == cards.last ? 0 : 16.0), child: c))).toList(),
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: c)).toList(),
      );
    }
  }

  Widget _buildSummaryCards(BuildContext context, bool isDesktop) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: PremiumCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Registration Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _buildInfoRow('Reg Number', 'REG-8493028'),
                _buildInfoRow('GST / VAT', 'GSTIN-09230495A'),
                _buildInfoRow('PAN / Tax ID', 'TAX-49320-US'),
                _buildInfoRow('Incorporation', 'Mar 14, 2020'),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: PremiumCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Primary Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                _buildInfoRow('Person', 'Sarah Jenkins'),
                _buildInfoRow('Email', 'sarah.j@example.com'),
                _buildInfoRow('Phone', '+1 (555) 019-3829'),
                _buildInfoRow('Website', 'www.example.com'),
              ],
            ),
          ),
        ),
        if (isDesktop) const SizedBox(width: 24),
        if (isDesktop)
          Expanded(
            child: PremiumCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  _buildInfoRow('Currency', 'USD (\$)'),
                  _buildInfoRow('Time Zone', 'UTC - 05:00'),
                  _buildInfoRow('Language', 'English (US)'),
                  _buildInfoRow('Fiscal Year', 'Jan - Dec'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeGrowthChart(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Employee Growth (YTD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(months[value.toInt()], style: const TextStyle(fontSize: 12)));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 100), FlSpot(1, 120), FlSpot(2, 115), FlSpot(3, 140), FlSpot(4, 155),
                      FlSpot(5, 150), FlSpot(6, 170), FlSpot(7, 190), FlSpot(8, 185), FlSpot(9, 210),
                      FlSpot(10, 230), FlSpot(11, 250),
                    ],
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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

  Widget _buildDepartmentDistribution(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Department Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          SizedBox(
            height: 300,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: [
                  PieChartSectionData(color: Colors.blue, value: 40, title: 'Eng', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.red, value: 25, title: 'Sales', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.green, value: 20, title: 'Ops', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  PieChartSectionData(color: Colors.orange, value: 15, title: 'HR', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsTab(BuildContext context, Organization org) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.network, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Manage all departments for ${org.name}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/platform/organizations/${org.id}/departments'),
            icon: const Icon(LucideIcons.settings, size: 18),
            label: const Text('Go to Department Management'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderTab(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('$title Information', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('This section will be populated with detailed grids and lists.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, Organization org) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.barChart2, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text('Organization Executive Dashboard', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/platform/organizations/${org.id}/analytics'),
            icon: const Icon(LucideIcons.barChart2),
            label: const Text('Go to Analytics Dashboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchesTab(BuildContext context, Organization org) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.gitBranch, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(height: 24),
          Text('Manage all branches for ${org.name}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/platform/organizations/${org.id}/branches'),
            icon: const Icon(LucideIcons.settings),
            label: const Text('Go to Branch Management'),
          ),
        ],
      ),
    );
  }
}
