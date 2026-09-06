import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../domain/models/marketplace_module.dart';
import '../../domain/models/marketplace_module_lifecycle_state.dart';
import '../../application/marketplace_providers.dart';
import '../../../../core/presentation/widgets/empty_state_widget.dart';
import '../widgets/module_installation_dialog.dart';

class MarketplaceModuleDetailsScreen extends ConsumerWidget {
  final String moduleId;

  const MarketplaceModuleDetailsScreen({
    super.key,
    required this.moduleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final moduleAsync = ref.watch(marketplaceModuleDetailsProvider(moduleId));
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/marketplace/explorer');
            }
          },
        ),
        title: const Text('Module Details'),
      ),
      body: moduleAsync.when(
        data: (module) {
          if (module == null) {
            return Center(
              child: PlatformEmptyState(
                icon: LucideIcons.fileSearch,
                title: 'Module Not Found',
                description: 'The requested module could not be found or has been removed.',
                primaryActionText: 'Back to Explorer',
                onPrimaryAction: () => context.go('/marketplace/explorer'),
              ),
            );
          }
          return _buildContent(context, ref, theme, module, isDesktop);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading module: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ThemeData theme, MarketplaceModule module, bool isDesktop) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, ref, theme, module),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: isDesktop 
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildMainColumn(context, theme, module),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      flex: 1,
                      child: _buildSideColumn(context, ref, theme, module),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMainColumn(context, theme, module),
                    const SizedBox(height: 32),
                    _buildSideColumn(context, ref, theme, module),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, ThemeData theme, MarketplaceModule module) {
    final isFavorite = ref.watch(marketplaceFavoritesProvider).contains(module.id);
    final isInstalled = module.lifecycleState == MarketplaceModuleLifecycleState.installed || 
                        module.lifecycleState == MarketplaceModuleLifecycleState.updateAvailable;
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isInstalled 
                  ? theme.colorScheme.primaryContainer 
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIcon(module.icon), 
              color: isInstalled 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
              size: 48,
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.name,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                module.moduleCode,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  module.categoryIds.isNotEmpty ? module.categoryIds.first.toUpperCase() : 'APP',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'v${module.latestPublishedVersion}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
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
                        const SizedBox(width: 16),
                        _buildActionArea(context, ref, theme, module),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  module.shortDescription,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionArea(BuildContext context, WidgetRef ref, ThemeData theme, MarketplaceModule module) {
    switch (module.lifecycleState) {
      case MarketplaceModuleLifecycleState.installed:
        return FilledButton.icon(
          icon: const Icon(LucideIcons.checkCircle2),
          label: const Text('Installed'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.primary,
          ),
          onPressed: () {},
        );
      case MarketplaceModuleLifecycleState.updateAvailable:
        return FilledButton.icon(
          icon: const Icon(LucideIcons.refreshCw),
          label: const Text('Update Available'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.tertiaryContainer,
            foregroundColor: theme.colorScheme.onTertiaryContainer,
          ),
          onPressed: () => _showInstallDialog(context, ref, module, true),
        );
      case MarketplaceModuleLifecycleState.available:
        return FilledButton(
          child: const Text('Install Module'),
          onPressed: () => _showInstallDialog(context, ref, module, false),
        );
      case MarketplaceModuleLifecycleState.incompatible:
      case MarketplaceModuleLifecycleState.blocked:
        return FilledButton(
          onPressed: null,
          child: Text(module.lifecycleState.displayName),
        );
    }
  }

  Future<void> _showInstallDialog(BuildContext context, WidgetRef ref, MarketplaceModule module, bool isUpdate) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ModuleInstallationDialog(module: module, isUpdate: isUpdate),
    );
    
    if (result == true) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${module.name} ${isUpdate ? 'updated' : 'installed'} successfully.')));
    }
  }

  Widget _buildMainColumn(BuildContext context, ThemeData theme, MarketplaceModule module) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, theme, 'Overview'),
        Text(
          module.description,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        
        const SizedBox(height: 32),
        _buildSectionTitle(context, theme, 'Capabilities'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: module.capabilities.map((c) => _buildCapabilityChip(context, theme, c)).toList(),
        ),

        const SizedBox(height: 32),
        _buildSectionTitle(context, theme, 'Key Features'),
        ...module.features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.checkCircle2, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  f,
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface),
                ),
              ),
            ],
          ),
        )),

        const SizedBox(height: 32),
        _buildSectionTitle(context, theme, 'Included Screens'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: module.screens.map((s) => Chip(
            label: Text(s),
            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            side: BorderSide.none,
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSideColumn(BuildContext context, WidgetRef ref, ThemeData theme, MarketplaceModule module) {
    final isCompatible = ref.watch(marketplaceRepositoryProvider).validateCompatibility(module);
    final missingDeps = ref.watch(marketplaceRepositoryProvider).getMissingDependencies(module, onlyRequired: false);
  
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          context,
          theme,
          title: 'Publisher',
          content: module.publisherName,
          icon: LucideIcons.building,
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          context,
          theme,
          title: 'Status',
          content: module.lifecycleState.displayName,
          icon: LucideIcons.activity,
        ),
        
        if (module.currentVersion != null) ...[
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            theme,
            title: 'Installed Version',
            content: module.currentVersion!,
            icon: LucideIcons.tag,
          ),
        ],

        const SizedBox(height: 24),
        _buildSectionTitle(context, theme, 'Compatibility'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCompatible ? LucideIcons.shieldCheck : LucideIcons.shieldAlert, 
              size: 16, 
              color: isCompatible ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                module.maxCoreAxisVersion != null 
                    ? 'Requires CoreAxis v${module.minCoreAxisVersion} to v${module.maxCoreAxisVersion}'
                    : 'Requires CoreAxis v${module.minCoreAxisVersion} or higher', 
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isCompatible ? theme.colorScheme.onSurface : theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        _buildSectionTitle(context, theme, 'Dependencies'),
        if (module.dependencies.isEmpty)
          const Text('No dependencies required.')
        else
          ...module.dependencies.map((d) {
            final isMissing = missingDeps.any((md) => md.moduleId == d.moduleId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    isMissing ? (d.isRequired ? LucideIcons.alertTriangle : LucideIcons.info) : LucideIcons.link, 
                    size: 16, 
                    color: isMissing ? (d.isRequired ? theme.colorScheme.error : Colors.orange) : theme.colorScheme.onSurfaceVariant
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${d.moduleCode} (v${d.requiredVersion}+) ${d.isRequired ? '' : '(Optional)'}', 
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isMissing ? (d.isRequired ? theme.colorScheme.error : theme.colorScheme.onSurface) : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          
        const SizedBox(height: 24),
        _buildSectionTitle(context, theme, 'Tags'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: module.tags.map((t) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '#$t',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCapabilityChip(BuildContext context, ThemeData theme, String capability) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.zap, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            capability,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ThemeData theme, {required String title, required String content, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.onSurfaceVariant, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
