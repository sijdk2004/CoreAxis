import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

// --- MOCK MODEL & STATE ---
class IndustryPackDetail {
  final String id;
  final String name;
  final String industry;
  final String version;
  final String status;
  final Color themeColor;
  final IconData icon;
  final int activeScreens;
  final int activeUsers;
  final String storageUsage;
  final DateTime lastUpdated;
  final String healthStatus;

  IndustryPackDetail({
    required this.id,
    required this.name,
    required this.industry,
    required this.version,
    required this.status,
    required this.themeColor,
    required this.icon,
    required this.activeScreens,
    required this.activeUsers,
    required this.storageUsage,
    required this.lastUpdated,
    required this.healthStatus,
  });
}

final _mockDetails = {
  'inst_furni': IndustryPackDetail(
    id: 'inst_furni',
    name: 'FurniFlow',
    industry: 'Furniture Manufacturing',
    version: '1.2.4',
    status: 'Enabled',
    themeColor: const Color(0xFF2563EB),
    icon: LucideIcons.sofa,
    activeScreens: 12,
    activeUsers: 45,
    storageUsage: '1.2 GB',
    lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
    healthStatus: 'Healthy',
  ),
};

final industryPackDetailProvider = Provider.family<IndustryPackDetail?, String>((ref, id) {
  // Return the mock detail, or a generic fallback if not found
  return _mockDetails[id] ?? IndustryPackDetail(
    id: id,
    name: 'Industry Pack $id',
    industry: 'Unknown',
    version: '1.0.0',
    status: 'Installed',
    themeColor: const Color(0xFF64748B),
    icon: LucideIcons.package,
    activeScreens: 0,
    activeUsers: 0,
    storageUsage: '0 MB',
    lastUpdated: DateTime.now(),
    healthStatus: 'Unknown',
  );
});

// --- SCREEN ---
class IndustryPackDetailsScreen extends ConsumerStatefulWidget {
  final String packId;

  const IndustryPackDetailsScreen({super.key, required this.packId});

  @override
  ConsumerState<IndustryPackDetailsScreen> createState() => _IndustryPackDetailsScreenState();
}

class _IndustryPackDetailsScreenState extends ConsumerState<IndustryPackDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pack = ref.watch(industryPackDetailProvider(widget.packId));
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    if (pack == null) {
      return const Scaffold(body: Center(child: Text('Pack not found.')));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('${pack.name} Details'),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(theme, pack, isDesktop),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Modules'),
              Tab(text: 'Dependencies'),
              Tab(text: 'Permissions'),
              Tab(text: 'Release Notes'),
              Tab(text: 'Settings'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme, pack, isDesktop),
                _buildPlaceholderTab(theme, 'Modules'),
                _buildPlaceholderTab(theme, 'Dependencies'),
                _buildPlaceholderTab(theme, 'Permissions'),
                _buildPlaceholderTab(theme, 'Release Notes'),
                _buildPlaceholderTab(theme, 'Settings'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, IndustryPackDetail pack, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: pack.themeColor.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: pack.themeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(pack.icon, color: Colors.white, size: 48),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(pack.name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: pack.themeColor)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(pack.status, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${pack.industry} • v${pack.version}', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            context.go('/platform/industry-packs/${pack.id}/dashboard');
                          },
                          icon: const Icon(LucideIcons.rocket, size: 16),
                          label: const Text('Launch'),
                          style: FilledButton.styleFrom(backgroundColor: pack.themeColor),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.push('/platform/industry-packs/${pack.id}/configuration');
                          },
                          icon: const Icon(LucideIcons.sliders, size: 16),
                          label: const Text('Configure Pack'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.go('/platform/industry-packs/${pack.id}/modules');
                          },
                          icon: const Icon(LucideIcons.blocks, size: 16),
                          label: const Text('Modules'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            context.go('/platform/industry-packs/${pack.id}/branding');
                          },
                          icon: const Icon(LucideIcons.palette, size: 16),
                          label: const Text('Branding'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(LucideIcons.arrowUpCircle, size: 16),
                          label: const Text('Upgrade'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(ThemeData theme, IndustryPackDetail pack, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Health & Metrics', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isDesktop ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildMetricCard(theme, 'Health Status', pack.healthStatus, LucideIcons.activity, Colors.green),
                  _buildMetricCard(theme, 'Active Users', pack.activeUsers.toString(), LucideIcons.users, Colors.blue),
                  _buildMetricCard(theme, 'Storage Usage', pack.storageUsage, LucideIcons.database, Colors.purple),
                  _buildMetricCard(theme, 'Active Screens', pack.activeScreens.toString(), LucideIcons.layoutTemplate, Colors.orange),
                  _buildMetricCard(theme, 'Last Updated', '${pack.lastUpdated.month}/${pack.lastUpdated.day}/${pack.lastUpdated.year}', LucideIcons.clock, Colors.grey),
                  _buildMetricCard(theme, 'Modules Configured', '7 / 10', LucideIcons.settings2, Colors.teal),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          Text('Module Summary', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final modules = ['CRM', 'Quotations', 'Production', 'Inventory'];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: pack.themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.box, color: pack.themeColor, size: 20),
                  ),
                  title: Text(modules[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Fully configured and active.'),
                  trailing: const Icon(LucideIcons.checkCircle, color: Colors.green, size: 20),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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

  Widget _buildPlaceholderTab(ThemeData theme, String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.construction, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text('$title Data', style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 8),
          Text('Mock data for $title will be displayed here.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        ],
      ),
    );
  }
}
