import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'providers/platform_home_provider.dart';
import 'models/platform_home_model.dart';

class PlatformHomeScreen extends ConsumerWidget {
  const PlatformHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(platformHomeProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(context, theme, state),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(context, theme),
                  const SizedBox(height: 32),
                  _buildKpiGrid(context, theme, state.kpis, isDesktop),
                  const SizedBox(height: 32),
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildMainContentColumn(context, theme, state)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildSideContentColumn(context, theme, state)),
                      ],
                    )
                  else ...[
                    _buildMainContentColumn(context, theme, state),
                    const SizedBox(height: 24),
                    _buildSideContentColumn(context, theme, state),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, ThemeData theme, PlatformHomeModel state) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enterprise ERP Platform',
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.checkCircle2, color: Colors.greenAccent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      state.platformHealthStatus,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome back, ${state.currentUser}',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tenant: ${state.currentTenant}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildActionChip(context, theme, 'Launch Industry Pack', LucideIcons.package, () {}),
            _buildActionChip(context, theme, 'Open AI Assistant', LucideIcons.bot, () => context.push('/platform/ai/chat')),
            _buildActionChip(context, theme, 'Create Workflow', LucideIcons.workflow, () => context.push('/platform/workflows/designer')),
            _buildActionChip(context, theme, 'Generate Report', LucideIcons.fileBarChart2, () => context.push('/platform/reports/builder')),
            _buildActionChip(context, theme, 'Invite User', LucideIcons.userPlus, () => context.push('/platform/users/new')),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip(BuildContext context, ThemeData theme, String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: theme.colorScheme.primary),
      label: Text(label),
      backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: onTap,
    );
  }

  Widget _buildKpiGrid(BuildContext context, ThemeData theme, List<KpiMetric> kpis, bool isDesktop) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2,
      ),
      itemCount: kpis.length,
      itemBuilder: (context, index) {
        final kpi = kpis[index];
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  kpi.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      kpi.value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kpi.trend,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: kpi.isPositive ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContentColumn(BuildContext context, ThemeData theme, PlatformHomeModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlatformSections(context, theme),
        const SizedBox(height: 32),
        _buildSectionTitle(theme, 'Recent Activities'),
        _buildListCard(theme, state.recentActivities, LucideIcons.activity),
        const SizedBox(height: 32),
        _buildSectionTitle(theme, 'Announcements'),
        _buildListCard(theme, state.announcements, LucideIcons.megaphone, iconColor: Colors.orange),
      ],
    );
  }

  Widget _buildSideContentColumn(BuildContext context, ThemeData theme, PlatformHomeModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSystemHealthWidget(theme, state),
        const SizedBox(height: 32),
        _buildSectionTitle(theme, 'Favorite Modules'),
        _buildListCard(theme, state.favoriteModules, LucideIcons.star, iconColor: Colors.amber),
        const SizedBox(height: 32),
        _buildSectionTitle(theme, 'Recently Opened'),
        _buildListCard(theme, [
          'Purchase Order #PO-2023-098',
          'Sales Dashboard',
          'User Permissions Matrix',
        ], LucideIcons.clock),
      ],
    );
  }

  Widget _buildPlatformSections(BuildContext context, ThemeData theme) {
    final sections = [
      {'title': 'Administration', 'icon': LucideIcons.settings, 'color': Colors.blue},
      {'title': 'Automation', 'icon': LucideIcons.workflow, 'color': Colors.purple},
      {'title': 'Services', 'icon': LucideIcons.server, 'color': Colors.teal},
      {'title': 'Analytics', 'icon': LucideIcons.barChart2, 'color': Colors.orange},
      {'title': 'AI Engine', 'icon': LucideIcons.bot, 'color': Colors.indigo},
      {'title': 'Industry Packs', 'icon': LucideIcons.packageOpen, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(theme, 'Platform Domains'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(section['icon'] as IconData, color: section['color'] as Color, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        section['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSystemHealthWidget(ThemeData theme, PlatformHomeModel state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.activitySquare, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('System Health', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(value: 0.95, color: Colors.green),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('CPU Load: 42%', style: theme.textTheme.bodySmall),
                Text('Memory: 64%', style: theme.textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text('Version: ${state.systemVersion}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListCard(ThemeData theme, List<String> items, IconData icon, {Color? iconColor}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.primary),
            title: Text(items[index], style: theme.textTheme.bodyMedium),
            onTap: () {},
          );
        },
      ),
    );
  }
}
