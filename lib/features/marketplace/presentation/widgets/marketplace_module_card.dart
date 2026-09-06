import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/models/marketplace_module.dart';
import '../../domain/models/marketplace_module_lifecycle_state.dart';
import '../../domain/models/marketplace_module_visibility.dart';
import '../../domain/models/marketplace_module_draft.dart';
import '../../application/marketplace_providers.dart';

class MarketplaceModuleCard extends ConsumerWidget {
  final MarketplaceModule module;
  final bool isListMode;
  final bool isSelectionMode;
  final VoidCallback? onTap;

  const MarketplaceModuleCard({
    super.key,
    required this.module,
    this.isListMode = false,
    this.isSelectionMode = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(marketplaceFavoritesProvider).contains(module.id);
    
    if (isListMode) {
      return _buildListCard(context, ref, theme, isFavorite);
    }
    return _buildGridCard(context, ref, theme, isFavorite);
  }

  Widget _buildGridCard(BuildContext context, WidgetRef ref, ThemeData theme, bool isFavorite) {
    final isInstalled = module.lifecycleState == MarketplaceModuleLifecycleState.installed || 
                        module.lifecycleState == MarketplaceModuleLifecycleState.updateAvailable;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.go('/marketplace/${module.id}'),
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
                      color: isInstalled 
                          ? theme.colorScheme.primaryContainer 
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIcon(module.icon), 
                      color: isInstalled 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      ref.read(marketplaceFavoritesProvider.notifier).toggleFavorite(module.id);
                    },
                    tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        module.moduleCode,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          module.categoryIds.isNotEmpty ? module.categoryIds.first.toUpperCase() : 'APP',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                module.shortDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: module.capabilities.take(2).map((cap) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      cap,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const Spacer(),
            const Divider(height: 1),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.surfaceContainerLowest,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.tag, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'v${module.releases.isNotEmpty ? module.latestPublishedVersion : module.draft?.version ?? '0.0.0'}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  _buildStateBadge(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, WidgetRef ref, ThemeData theme, bool isFavorite) {
    final isInstalled = module.lifecycleState == MarketplaceModuleLifecycleState.installed || 
                        module.lifecycleState == MarketplaceModuleLifecycleState.updateAvailable;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () => context.go('/marketplace/${module.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isInstalled 
                      ? theme.colorScheme.primaryContainer 
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(module.icon), 
                  color: isInstalled 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            module.name,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () {
                            ref.read(marketplaceFavoritesProvider.notifier).toggleFavorite(module.id);
                          },
                          visualDensity: VisualDensity.compact,
                          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          module.moduleCode,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'v${module.releases.isNotEmpty ? module.latestPublishedVersion : module.draft?.version ?? '0.0.0'}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStateBadge(theme),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      module.shortDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStateBadge(ThemeData theme) {
    if (module.visibility == MarketplaceModuleVisibility.deprecated) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.orange),
        ),
        child: Text(
          'Deprecated',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.orange,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (module.visibility == MarketplaceModuleVisibility.retired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey),
        ),
        child: Text(
          'Retired',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (module.draft != null) {
      Color bgColor;
      Color textColor;
      String text;
      
      switch (module.draft!.state) {
        case MarketplaceDraftState.drafting:
          bgColor = theme.colorScheme.surfaceContainerHighest;
          textColor = theme.colorScheme.onSurfaceVariant;
          text = 'Draft';
          break;
        case MarketplaceDraftState.validated:
          bgColor = theme.colorScheme.primaryContainer;
          textColor = theme.colorScheme.onPrimaryContainer;
          text = 'Validated';
          break;
        case MarketplaceDraftState.validationFailed:
          bgColor = theme.colorScheme.errorContainer;
          textColor = theme.colorScheme.onErrorContainer;
          text = 'Validation Failed';
          break;
      }
      
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text,
          style: theme.textTheme.labelSmall?.copyWith(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    switch (module.lifecycleState) {
      case MarketplaceModuleLifecycleState.installed:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.checkCircle2, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              'Installed',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      case MarketplaceModuleLifecycleState.updateAvailable:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Update Available',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onTertiaryContainer,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case MarketplaceModuleLifecycleState.incompatible:
      case MarketplaceModuleLifecycleState.blocked:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            module.lifecycleState.displayName,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case MarketplaceModuleLifecycleState.available:
        return Text(
          'Explore',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        );
    }
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'users': return LucideIcons.users;
      case 'box': return LucideIcons.box;
      case 'shoppingCart': return LucideIcons.shoppingCart;
      case 'fileText': return LucideIcons.fileText;
      case 'truck': return LucideIcons.truck;
      case 'shoppingBag': return LucideIcons.shoppingBag;
      case 'layers': return LucideIcons.layers;
      case 'home': return LucideIcons.home;
      case 'settings': return LucideIcons.settings;
      case 'gitMerge': return LucideIcons.gitMerge;
      case 'checkCircle': return LucideIcons.checkCircle;
      case 'dollarSign': return LucideIcons.dollarSign;
      case 'briefcase': return LucideIcons.briefcase;
      case 'gitBranch': return LucideIcons.gitBranch;
      case 'bell': return LucideIcons.bell;
      case 'barChart2': return LucideIcons.barChart2;
      case 'sparkles': return LucideIcons.sparkles;
      case 'folder': return LucideIcons.folder;
      case 'shield': return LucideIcons.shield;
      case 'contact': return LucideIcons.contact;
      case 'factory': return LucideIcons.factory;
      case 'bot': return LucideIcons.bot;
      case 'package': return LucideIcons.package;
      default: return LucideIcons.package;
    }
  }
}
