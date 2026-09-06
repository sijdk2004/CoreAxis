import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/mock_coreaxis_environment.dart';
import '../../domain/models/marketplace_module.dart';
import '../../application/marketplace_providers.dart';

class ModuleInstallationDialog extends ConsumerStatefulWidget {
  final MarketplaceModule module;
  final bool isUpdate;

  const ModuleInstallationDialog({
    super.key,
    required this.module,
    this.isUpdate = false,
  });

  @override
  ConsumerState<ModuleInstallationDialog> createState() => _ModuleInstallationDialogState();
}

class _ModuleInstallationDialogState extends ConsumerState<ModuleInstallationDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(marketplaceLifecycleControllerProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // We fetch these from repo for initial validation display
    final isCompatible = ref.watch(marketplaceRepositoryProvider).validateCompatibility(widget.module);
    final missingDeps = ref.watch(marketplaceRepositoryProvider).getMissingDependencies(widget.module, onlyRequired: true);
    final hasMissingRequiredDeps = missingDeps.isNotEmpty;
    
    final canProceed = isCompatible && !hasMissingRequiredDeps;
    
    final operation = ref.watch(marketplaceLifecycleControllerProvider);
    
    // Handle success
    if (operation.state == MarketplaceOperationState.success) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(true);
      });
    }

    final isWorking = operation.state == MarketplaceOperationState.validating || 
                      operation.state == MarketplaceOperationState.installing ||
                      operation.state == MarketplaceOperationState.updating;

    return AlertDialog(
      title: Text(
        widget.isUpdate ? 'Update ${widget.module.name}' : 'Install ${widget.module.name}',
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (operation.state == MarketplaceOperationState.failure)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertTriangle, color: theme.colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        operation.error ?? 'Unknown error occurred',
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),

            if (widget.isUpdate) ...[
              Text('Current Version: ${widget.module.currentVersion}'),
              const SizedBox(height: 4),
            ],
            Text('Target Version: ${widget.module.latestPublishedVersion}'),
            const SizedBox(height: 16),
            
            Text(
              'Compatibility',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCompatible ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
                  color: isCompatible ? theme.colorScheme.primary : theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCompatible 
                        ? 'Compatible with CoreAxis v${MockCoreAxisEnvironment.currentVersion}.'
                        : 'Incompatible. Requires CoreAxis v${widget.module.minCoreAxisVersion}${widget.module.maxCoreAxisVersion != null ? ' to v${widget.module.maxCoreAxisVersion}' : ' or higher'}.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isCompatible ? theme.colorScheme.onSurface : theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Dependencies',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (widget.module.dependencies.isEmpty)
              const Text('No dependencies.')
            else ...[
              ...widget.module.dependencies.map((dep) {
                final isMissing = missingDeps.any((d) => d.moduleId == dep.moduleId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        isMissing ? (dep.isRequired ? LucideIcons.xCircle : LucideIcons.alertTriangle) : LucideIcons.checkCircle2,
                        color: isMissing ? (dep.isRequired ? theme.colorScheme.error : Colors.orange) : theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${dep.moduleCode} (v${dep.requiredVersion}+) ${dep.isRequired ? '' : '(Optional)'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isMissing ? (dep.isRequired ? theme.colorScheme.error : theme.colorScheme.onSurface) : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            
            if (isWorking) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _getStatusText(operation.state),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isWorking ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: (canProceed && !isWorking) ? () {
            if (widget.isUpdate) {
              ref.read(marketplaceLifecycleControllerProvider.notifier).updateModule(widget.module.id);
            } else {
              ref.read(marketplaceLifecycleControllerProvider.notifier).installModule(widget.module.id);
            }
          } : null,
          icon: Icon(widget.isUpdate ? LucideIcons.refreshCw : LucideIcons.download),
          label: Text(widget.isUpdate ? 'Update Module' : 'Install Module'),
        ),
      ],
    );
  }
  
  String _getStatusText(MarketplaceOperationState state) {
    switch (state) {
      case MarketplaceOperationState.validating: return 'Validating...';
      case MarketplaceOperationState.installing: return 'Installing module...';
      case MarketplaceOperationState.updating: return 'Updating module...';
      default: return 'Working...';
    }
  }
}
