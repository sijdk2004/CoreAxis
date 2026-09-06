import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/marketplace_providers.dart';
import '../widgets/marketplace_module_card.dart';
import '../../../../core/presentation/widgets/empty_state_widget.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MarketplaceInstalledScreen extends ConsumerWidget {
  const MarketplaceInstalledScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installedAsync = ref.watch(marketplaceInstalledModulesProvider);

    return installedAsync.when(
      data: (modules) {
        if (modules.isEmpty) {
          return const Center(
            child: PlatformEmptyState(
              icon: LucideIcons.box,
              title: 'No Modules Installed',
              description: 'You haven\'t installed any modules yet. Visit the Marketplace to explore available modules.',
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(24.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  mainAxisExtent: 220,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return MarketplaceModuleCard(module: modules[index]);
                  },
                  childCount: modules.length,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error loading installed modules: $e')),
    );
  }
}
