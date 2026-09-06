import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../application/marketplace_providers.dart';
import '../../domain/models/marketplace_module_lifecycle_state.dart';
import '../widgets/marketplace_module_card.dart';
import '../../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../../core/presentation/widgets/empty_state_widget.dart';

class MarketplaceExplorerScreen extends ConsumerWidget {
  final bool isSelectionMode;

  const MarketplaceExplorerScreen({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final isMobile = ResponsiveBreakpoints.of(context).smallerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: isMobile ? _buildMobileAppBar(context, ref, theme) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isMobile) _buildDesktopHeader(context, ref, theme),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop) _buildDesktopSidebar(context, ref, theme),
                if (isDesktop) VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                Expanded(
                  child: Column(
                    children: [
                      if (!isDesktop) _buildMobileCategories(context, ref, theme),
                      Expanded(
                        child: _buildExplorerContent(context, ref, theme, isDesktop, isMobile),
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

  PreferredSizeWidget _buildMobileAppBar(BuildContext context, WidgetRef ref, ThemeData theme) {
    return AppBar(
      title: const Text('Explorer'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildSearchBar(context, ref, theme),
        ),
      ),
      actions: [
        _buildViewToggle(ref, theme),
      ],
    );
  }

  Widget _buildDesktopHeader(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        children: [
          Text(
            'Explore Modules',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          _buildStatusFilter(context, ref, theme),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            child: _buildSearchBar(context, ref, theme),
          ),
          const SizedBox(width: 16),
          _buildViewToggle(ref, theme),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(BuildContext context, WidgetRef ref, ThemeData theme) {
    final selectedStatus = ref.watch(marketplaceSelectedStatusProvider);
    
    return DropdownButtonHideUnderline(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: DropdownButton<MarketplaceModuleLifecycleState?>(
          value: selectedStatus,
          hint: const Text('All Statuses'),
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          isDense: true,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('All Statuses'),
            ),
            ...MarketplaceModuleLifecycleState.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.displayName),
              );
            }),
          ],
          onChanged: (value) {
            ref.read(marketplaceSelectedStatusProvider.notifier).update(value);
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref, ThemeData theme) {
    final query = ref.watch(marketplaceSearchQueryProvider);
    final controller = TextEditingController(text: query);
    
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));

    return SearchBar(
      controller: controller,
      hintText: 'Search modules...',
      leading: const Icon(LucideIcons.search, size: 20),
      trailing: [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, size: 20),
            onPressed: () {
              ref.read(marketplaceSearchQueryProvider.notifier).update('');
              controller.clear();
            },
          ),
      ],
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      onChanged: (value) {
        ref.read(marketplaceSearchQueryProvider.notifier).update(value);
      },
    );
  }

  Widget _buildViewToggle(WidgetRef ref, ThemeData theme) {
    final viewMode = ref.watch(marketplaceViewModeProvider);

    return SegmentedButton<MarketplaceViewMode>(
      segments: const [
        ButtonSegment(
          value: MarketplaceViewMode.grid,
          icon: Icon(LucideIcons.layoutGrid, size: 20),
        ),
        ButtonSegment(
          value: MarketplaceViewMode.list,
          icon: Icon(LucideIcons.list, size: 20),
        ),
      ],
      selected: {viewMode},
      onSelectionChanged: (Set<MarketplaceViewMode> newSelection) {
        ref.read(marketplaceViewModeProvider.notifier).update(newSelection.first);
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        selectedForegroundColor: theme.colorScheme.primary,
        selectedBackgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
      ),
      showSelectedIcon: false,
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, WidgetRef ref, ThemeData theme) {
    final categoriesAsync = ref.watch(marketplaceCategoriesProvider);
    final selectedCategory = ref.watch(marketplaceSelectedCategoryProvider);

    return Container(
      width: 280,
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CATEGORIES',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (selectedCategory != null)
                  TextButton(
                    onPressed: () {
                      ref.read(marketplaceSelectedCategoryProvider.notifier).update(null);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                return ListView(
                  children: [
                    ListTile(
                      title: const Text('All Modules'),
                      leading: const Icon(LucideIcons.layoutDashboard, size: 20),
                      selected: selectedCategory == null || selectedCategory == 'all',
                      selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      selectedColor: theme.colorScheme.primary,
                      onTap: () => ref.read(marketplaceSelectedCategoryProvider.notifier).update('all'),
                    ),
                    ...categories.map((cat) {
                      final isSelected = selectedCategory == cat.id;
                      return ListTile(
                        title: Text(cat.name),
                        leading: Icon(_getCategoryIcon(cat.icon), size: 20),
                        trailing: Text(
                          cat.moduleCount.toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        selected: isSelected,
                        selectedTileColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                        selectedColor: theme.colorScheme.primary,
                        onTap: () => ref.read(marketplaceSelectedCategoryProvider.notifier).update(cat.id),
                      );
                    }),
                  ],
                );
              },
              loading: () => const SkeletonSidebarLoader(),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCategories(BuildContext context, WidgetRef ref, ThemeData theme) {
    final categoriesAsync = ref.watch(marketplaceCategoriesProvider);
    final selectedCategory = ref.watch(marketplaceSelectedCategoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _buildStatusFilter(context, ref, theme),
        ),
        categoriesAsync.when(
          data: (categories) {
            return SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: selectedCategory == null || selectedCategory == 'all',
                      onSelected: (_) => ref.read(marketplaceSelectedCategoryProvider.notifier).update('all'),
                    ),
                  ),
                  ...categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat.name),
                        selected: selectedCategory == cat.id,
                        onSelected: (_) => ref.read(marketplaceSelectedCategoryProvider.notifier).update(cat.id),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
          loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
          error: (e, st) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildExplorerContent(BuildContext context, WidgetRef ref, ThemeData theme, bool isDesktop, bool isMobile) {
    final modulesAsync = ref.watch(marketplaceExplorerModulesProvider);
    final viewMode = ref.watch(marketplaceViewModeProvider);

    return modulesAsync.when(
      data: (modules) {
        if (modules.isEmpty) {
          return Center(
            child: PlatformEmptyState(
              icon: LucideIcons.searchX,
              title: 'No Modules Found',
              description: 'Try adjusting your search or filters.',
              primaryActionText: 'Clear Filters',
              onPrimaryAction: () {
                ref.read(marketplaceSearchQueryProvider.notifier).update('');
                ref.read(marketplaceSelectedCategoryProvider.notifier).update(null);
                ref.read(marketplaceSelectedStatusProvider.notifier).update(null);
              },
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Text(
                'Showing ${modules.length} results',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: viewMode == MarketplaceViewMode.grid && !isMobile
                  ? GridView.builder(
                      padding: const EdgeInsets.all(24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isDesktop ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent: 260,
                      ),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        return MarketplaceModuleCard(module: modules[index], isListMode: false);
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: modules.length,
                      itemBuilder: (context, index) {
                        return MarketplaceModuleCard(module: modules[index], isListMode: true);
                      },
                    ),
            ),
          ],
        );
      },
      loading: () {
        if (viewMode == MarketplaceViewMode.grid && !isMobile) {
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 260,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const SkeletonCardLoader(),
          );
        } else {
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: 5,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SkeletonBox(width: double.infinity, height: 100, borderRadius: 12),
            ),
          );
        }
      },
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
