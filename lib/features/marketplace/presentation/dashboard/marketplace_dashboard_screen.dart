import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../application/marketplace_providers.dart';
import '../widgets/marketplace_module_card.dart';
import '../../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../../core/presentation/widgets/empty_state_widget.dart';

class MarketplaceDashboardScreen extends ConsumerWidget {
  const MarketplaceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, theme, ref),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsSection(context, ref, theme, isDesktop),
                  const SizedBox(height: 32),
                  
                  _buildCategoriesSection(context, ref, theme),
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(context, theme, 'Featured Modules', () {
                    context.go('/marketplace/explorer');
                  }),
                  _buildModuleList(context, ref, marketplaceFeaturedModulesProvider, isDesktop),
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(context, theme, 'Recommended for You', null),
                  _buildModuleList(context, ref, marketplaceRecommendedModulesProvider, isDesktop),
                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(context, theme, 'Recently Added', () {
                    context.go('/marketplace/explorer');
                  }),
                  _buildModuleList(context, ref, marketplaceLatestModulesProvider, isDesktop),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          border: Border(bottom: BorderSide(color: theme.dividerColor)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(LucideIcons.store, color: theme.colorScheme.onPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business Marketplace',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discover reusable CoreAxis Business Modules to expand your ERP capabilities.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SearchBar(
                  hintText: 'Search modules, capabilities, or categories...',
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(LucideIcons.search),
                  ),
                  elevation: const WidgetStatePropertyAll(0),
                  backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  onSubmitted: (value) {
                    ref.read(marketplaceSearchQueryProvider.notifier).update(value);
                    context.go('/marketplace/explorer');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, WidgetRef ref, ThemeData theme, bool isDesktop) {
    final statsAsync = ref.watch(marketplaceDashboardStatsProvider);
    
    return statsAsync.when(
      data: (stats) {
        final items = [
          {'title': 'Available Modules', 'value': stats['availableModules'].toString(), 'icon': LucideIcons.packageOpen, 'color': Colors.blue, 'route': '/marketplace/explorer'},
          {'title': 'Installed Modules', 'value': stats['installedModules'].toString(), 'icon': LucideIcons.checkCircle2, 'color': Colors.green, 'route': '/marketplace/installed'},
          {'title': 'Updates Available', 'value': stats['updatesAvailable'].toString(), 'icon': LucideIcons.refreshCw, 'color': Colors.orange, 'route': '/marketplace/installed'},
          {'title': 'Categories', 'value': stats['categories'].toString(), 'icon': LucideIcons.layoutGrid, 'color': Colors.purple, 'route': '/marketplace/explorer'},
        ];
        
        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = isDesktop ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 100,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      if (item['route'] != null) {
                        context.go(item['route'] as String);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: item['color'] as Color,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  item['value'] as String,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        );
      },
      loading: () => const SkeletonDashboardLoader(),
      error: (e, st) => Center(child: Text('Error loading stats: $e')),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, WidgetRef ref, ThemeData theme) {
    final categoriesAsync = ref.watch(marketplaceCategoriesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, theme, 'Popular Categories', () {
          context.go('/marketplace/explorer');
        }),
        categoriesAsync.when(
          data: (categories) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.take(6).map((cat) {
                return ActionChip(
                  label: Text('${cat.name} (${cat.moduleCount})'),
                  avatar: Icon(_getCategoryIcon(cat.icon), size: 16),
                  onPressed: () {
                    ref.read(marketplaceSelectedCategoryProvider.notifier).update(cat.id);
                    context.go('/marketplace/explorer');
                  },
                );
              }).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, st) => Text('Error loading categories: $e'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, ThemeData theme, String title, VoidCallback? onAction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: const Text('View All'),
            ),
        ],
      ),
    );
  }

  Widget _buildModuleList(BuildContext context, WidgetRef ref, FutureProvider provider, bool isDesktop) {
    final asyncValue = ref.watch(provider);
    
    return asyncValue.when(
      data: (modules) {
        if (modules.isEmpty) {
          return const PlatformEmptyState(
            icon: LucideIcons.packageOpen,
            title: 'No Modules Found',
            description: 'There are no modules available in this section.',
          );
        }
        
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 260,
          ),
          itemCount: modules.length > 3 ? 3 : modules.length,
          itemBuilder: (context, index) {
            return MarketplaceModuleCard(module: modules[index]);
          },
        );
      },
      loading: () => GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 3 : 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          mainAxisExtent: 260,
        ),
        itemCount: 3,
        itemBuilder: (context, index) => const SkeletonCardLoader(),
      ),
      error: (e, st) => Center(child: Text('Error loading modules: $e')),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'layers': return LucideIcons.layers;
      case 'users': return LucideIcons.users;
      case 'shoppingBag': return LucideIcons.shoppingBag;
      case 'package': return LucideIcons.package;
      case 'factory': return LucideIcons.factory;
      case 'dollarSign': return LucideIcons.dollarSign;
      case 'contact': return LucideIcons.contact;
      case 'bot': return LucideIcons.bot;
      default: return LucideIcons.tag;
    }
  }
}
