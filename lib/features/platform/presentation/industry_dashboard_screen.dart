import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'industry_pack_details_screen.dart';

// --- MOCK DATA ---
class ActivityLog {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  ActivityLog(this.title, this.subtitle, this.timestamp, this.icon, this.color);
}

final _mockActivities = [
  ActivityLog('New Production Order', 'Order #PO-2039 created by John Doe', DateTime.now().subtract(const Duration(minutes: 5)), LucideIcons.box, Colors.blue),
  ActivityLog('System Warning', 'Inventory stock low for Raw Oak Wood', DateTime.now().subtract(const Duration(minutes: 42)), LucideIcons.alertTriangle, Colors.orange),
  ActivityLog('Invoice Paid', 'Invoice #INV-4921 paid by Acme Corp', DateTime.now().subtract(const Duration(hours: 2)), LucideIcons.fileCheck, Colors.green),
  ActivityLog('User Login', 'Admin user authenticated successfully', DateTime.now().subtract(const Duration(hours: 5)), LucideIcons.userCheck, Colors.grey),
];

// --- SCREEN ---
class IndustryDashboardScreen extends ConsumerWidget {
  final String packId;
  const IndustryDashboardScreen({super.key, required this.packId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(industryPackDetailProvider(packId));
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    if (pack == null) {
      return const Scaffold(body: Center(child: Text('Pack not found')));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('${pack.name} Launchpad'),
        backgroundColor: pack.themeColor.withValues(alpha: 0.1),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(icon: const Icon(LucideIcons.bell), onPressed: () {}),
          IconButton(
            icon: const Icon(LucideIcons.settings), 
            onPressed: () {
              context.push('/platform/industry-packs/${pack.id}/settings');
            }
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: pack.themeColor.withValues(alpha: 0.1),
                border: Border(bottom: BorderSide(color: pack.themeColor.withValues(alpha: 0.2))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: pack.themeColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: pack.themeColor.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(pack.icon, color: Colors.white, size: 48),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome to ${pack.name}', style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: pack.themeColor)),
                        const SizedBox(height: 8),
                        Text('Version ${pack.version} • ${pack.industry} • Environment: Production', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (isDesktop)
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.play),
                      label: const Text('Start Day'),
                      style: FilledButton.styleFrom(
                        backgroundColor: pack.themeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: isDesktop 
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildQuickLaunch(theme, pack),
                            const SizedBox(height: 24),
                            _buildMetricsRow(theme, pack),
                            const SizedBox(height: 24),
                            _buildInstalledModules(theme),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildRecentActivity(theme),
                            const SizedBox(height: 24),
                            _buildSystemStatusCard(theme, pack),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildQuickLaunch(theme, pack),
                      const SizedBox(height: 24),
                      _buildMetricsRow(theme, pack),
                      const SizedBox(height: 24),
                      _buildRecentActivity(theme),
                      const SizedBox(height: 24),
                      _buildInstalledModules(theme),
                      const SizedBox(height: 24),
                      _buildSystemStatusCard(theme, pack),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLaunch(ThemeData theme, IndustryPackDetail pack) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Launch', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildLaunchCard(context, theme, 'Open CRM', 'Manage clients and leads', LucideIcons.users, Colors.blue),
                _buildLaunchCard(context, theme, 'Open Production', 'Manufacturing orders', LucideIcons.factory, Colors.orange),
                _buildLaunchCard(context, theme, 'Open Inventory', 'Stock and warehouse', LucideIcons.packageSearch, Colors.green),
                _buildLaunchCard(context, theme, 'Open Reports', 'Analytics and data', LucideIcons.barChart3, Colors.purple),
                _buildLaunchCard(context, theme, 'Open AI', 'Predictive analytics', LucideIcons.sparkles, Colors.pink),
                _buildSettingsLaunchCard(context, theme, 'Open Settings', 'System configuration', LucideIcons.settings, Colors.grey, pack),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLaunchCard(BuildContext context, ThemeData theme, String title, String subtitle, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Simulated launch: $title')));
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsLaunchCard(BuildContext context, ThemeData theme, String title, String subtitle, IconData icon, Color color, IndustryPackDetail pack) {
    return InkWell(
      onTap: () {
        context.push('/platform/industry-packs/${pack.id}/settings');
      },
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsRow(ThemeData theme, IndustryPackDetail pack) {
    return Row(
      children: [
        Expanded(child: _buildMetricCard(theme, 'Active Users', pack.activeUsers.toString(), LucideIcons.users, Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard(theme, 'Active Screens', pack.activeScreens.toString(), LucideIcons.layoutTemplate, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildMetricCard(theme, 'Open Issues', '3', LucideIcons.alertCircle, Colors.red)),
      ],
    );
  }

  Widget _buildMetricCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title, 
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildInstalledModules(ThemeData theme) {
    final modules = ['Inventory', 'Production', 'Sales', 'Finance', 'CRM'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Installed Modules', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: modules.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: Icon(LucideIcons.packageCheck, color: theme.colorScheme.primary, size: 18),
                ),
                title: Text(modules[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Running smoothly'),
                trailing: const Icon(LucideIcons.checkCircle2, color: Colors.green),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Recent Activity', 
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mockActivities.length,
            separatorBuilder: (context, index) => const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
            itemBuilder: (context, index) {
              final act = _mockActivities[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: act.color.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(act.icon, size: 16, color: act.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(act.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(act.subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('${act.timestamp.hour}:${act.timestamp.minute.toString().padLeft(2, '0')}', style: theme.textTheme.bodySmall),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSystemStatusCard(ThemeData theme, IndustryPackDetail pack) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [pack.themeColor, pack.themeColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: pack.themeColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.activity, color: Colors.white),
              const SizedBox(width: 12),
              const Text('System Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Text('Live', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('All systems operational. Network latency is minimal and database replicas are synced.', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: pack.themeColor,
            ),
            child: const Text('View Detailed Metrics'),
          ),
        ],
      ),
    );
  }
}
