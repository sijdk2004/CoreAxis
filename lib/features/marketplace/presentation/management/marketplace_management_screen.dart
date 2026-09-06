import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/marketplace_publishing_providers.dart';
import '../widgets/marketplace_module_card.dart';

class MarketplaceManagementScreen extends ConsumerWidget {
  const MarketplaceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final modulesAsync = ref.watch(marketplaceManagementModulesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Module Management'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton.icon(
              onPressed: () => context.go('/marketplace/manage/create'),
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Create Module'),
            ),
          ),
        ],
      ),
      body: modulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.alertTriangle, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text('Error loading modules: $err'),
            ],
          ),
        ),
        data: (modules) {
          if (modules.isEmpty) {
            return const Center(
              child: Text('No modules found. Create one to get started.'),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    // Navigate to edit screen
                    context.go('/marketplace/manage/${module.id}/edit');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AbsorbPointer(
                    child: MarketplaceModuleCard(
                      module: module,
                      isListMode: true,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
