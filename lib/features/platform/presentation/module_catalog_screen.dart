import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:go_router/go_router.dart';
import 'providers/module_catalog_provider.dart';
import 'models/module_catalog_model.dart';

class ModuleCatalogScreen extends ConsumerWidget {
  const ModuleCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(moduleCatalogProvider);
    final notifier = ref.read(moduleCatalogProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, theme, state, notifier),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) _buildSidebar(context, theme, state, notifier),
                if (isDesktop) VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                Expanded(
                  child: _buildModuleList(context, theme, state, notifier, isDesktop),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, ModuleCatalogState state, ModuleCatalogNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.grid, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module Catalog',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore and launch available ERP platform modules',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            child: SearchBar(
              hintText: 'Search modules...',
              leading: Icon(LucideIcons.search, color: theme.colorScheme.onSurfaceVariant),
              onChanged: notifier.setSearchQuery,
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16, vertical: 4)),
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHighest.withOpacity(0.3)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, ThemeData theme, ModuleCatalogState state, ModuleCatalogNotifier notifier) {
    final filters = [
      {'title': 'All', 'icon': LucideIcons.layoutGrid},
      {'title': 'Favorites', 'icon': LucideIcons.star},
      {'title': 'Recently Used', 'icon': LucideIcons.clock},
      {'title': 'Platform Administration', 'icon': LucideIcons.settings},
      {'title': 'Automation', 'icon': LucideIcons.workflow},
      {'title': 'Documents', 'icon': LucideIcons.fileText},
      {'title': 'Analytics', 'icon': LucideIcons.pieChart},
      {'title': 'AI', 'icon': LucideIcons.bot},
      {'title': 'Industry Packs', 'icon': LucideIcons.packageOpen},
    ];

    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'VIEWS & CATEGORIES',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = state.selectedCategory == filter['title'];
                
                // Add a divider before Platform Administration
                if (filter['title'] == 'Platform Administration') {
                  return Column(
                    children: [
                      const Divider(height: 24),
                      _buildSidebarItem(context, theme, filter, isSelected, notifier),
                    ],
                  );
                }

                return _buildSidebarItem(context, theme, filter, isSelected, notifier);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(BuildContext context, ThemeData theme, Map<String, dynamic> filter, bool isSelected, ModuleCatalogNotifier notifier) {
    return ListTile(
      leading: Icon(
        filter['icon'] as IconData,
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      title: Text(
        filter['title'] as String,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        ),
      ),
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () => notifier.setCategoryFilter(filter['title'] as String),
    );
  }

  Widget _buildModuleList(BuildContext context, ThemeData theme, ModuleCatalogState state, ModuleCatalogNotifier notifier, bool isDesktop) {
    final modules = state.filteredModules;

    if (modules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.searchX, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No Modules Found',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or category filters.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(32),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 320,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        return _buildModuleCard(context, theme, modules[index], notifier);
      },
    );
  }

  Widget _buildModuleCard(BuildContext context, ThemeData theme, ModuleCatalogModel module, ModuleCatalogNotifier notifier) {
    final isBeta = module.status == 'Beta';
    final isComingSoon = module.status == 'Coming Soon';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isComingSoon 
                        ? theme.colorScheme.surfaceContainerHighest 
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(module.iconName), 
                    color: isComingSoon 
                        ? theme.colorScheme.onSurfaceVariant 
                        : theme.colorScheme.onSecondaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(module.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _getStatusColor(module.status).withOpacity(0.3)),
                            ),
                            child: Text(
                              module.status,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _getStatusColor(module.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              module.category,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
                IconButton(
                  icon: Icon(
                    module.isFavorite ? LucideIcons.star : LucideIcons.star,
                    color: module.isFavorite ? Colors.amber : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  tooltip: module.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  onPressed: () => notifier.toggleFavorite(module.id),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              module.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEPENDENCIES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: module.dependencies.map((dep) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      child: Text(
                        dep,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'v${module.version}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (module.lastUsed != null)
                      Text(
                        'Used ${_formatTimeAgo(module.lastUsed!)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text('${module.screensCount} Screens'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.icon(
                          onPressed: isComingSoon ? null : () => context.go(module.launchRoute),
                          icon: const Icon(LucideIcons.externalLink, size: 16),
                          label: const Text('Launch'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return Colors.green;
      case 'Beta': return Colors.orange;
      case 'Coming Soon': return Colors.grey;
      default: return Colors.blue;
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'layoutDashboard': return LucideIcons.layoutDashboard;
      case 'building': return LucideIcons.building;
      case 'users': return LucideIcons.users;
      case 'workflow': return LucideIcons.workflow;
      case 'checkSquare': return LucideIcons.checkSquare;
      case 'bell': return LucideIcons.bell;
      case 'fileText': return LucideIcons.fileText;
      case 'pieChart': return LucideIcons.pieChart;
      case 'shieldCheck': return LucideIcons.shieldCheck;
      case 'bot': return LucideIcons.bot;
      case 'store': return LucideIcons.store;
      default: return LucideIcons.box;
    }
  }
  
  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
