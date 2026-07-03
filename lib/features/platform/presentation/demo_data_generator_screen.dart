import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import 'providers/demo_data_generator_provider.dart';

class DemoDataGeneratorScreen extends ConsumerWidget {
  const DemoDataGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(demoDataGeneratorProvider);
    final notifier = ref.read(demoDataGeneratorProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Demo Data Generator'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Description
            Text(
              'Generate demo datasets to simulate a fully active environment. Choose your company size profile and select the specific entities you want to populate.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildCompanySizeSection(context, theme, state, notifier),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 2,
                    child: _buildEntitiesSection(context, theme, state, notifier),
                  ),
                ],
              )
            else ...[
              _buildCompanySizeSection(context, theme, state, notifier),
              const SizedBox(height: 32),
              _buildEntitiesSection(context, theme, state, notifier),
            ],

            const SizedBox(height: 32),
            _buildActionSection(context, theme, state, notifier),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanySizeSection(BuildContext context, ThemeData theme, DemoDataGeneratorState state, DemoDataGeneratorNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.building2, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              'Company Size',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...CompanySize.values.map((size) {
          final isSelected = state.companySize == size;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: state.isGenerating ? null : () => notifier.setCompanySize(size),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : theme.colorScheme.surface,
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Radio<CompanySize>(
                      value: size,
                      groupValue: state.companySize,
                      onChanged: state.isGenerating ? null : (value) {
                        if (value != null) notifier.setCompanySize(value);
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            size.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            size.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
        }),
      ],
    );
  }

  Widget _buildEntitiesSection(BuildContext context, ThemeData theme, DemoDataGeneratorState state, DemoDataGeneratorNotifier notifier) {
    final allSelected = state.selectedEntities.length == availableEntities.length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.database, size: 24, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Entities to Generate',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: state.isGenerating ? null : () => notifier.toggleAll(!allSelected),
                  icon: Icon(allSelected ? LucideIcons.checkSquare2 : LucideIcons.square),
                  label: Text(allSelected ? 'Deselect All' : 'Select All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: availableEntities.map((entity) {
                final isSelected = state.selectedEntities.contains(entity);
                return FilterChip(
                  label: Text(entity),
                  selected: isSelected,
                  onSelected: state.isGenerating ? null : (_) => notifier.toggleEntity(entity),
                  showCheckmark: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  labelStyle: TextStyle(
                    color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, ThemeData theme, DemoDataGeneratorState state, DemoDataGeneratorNotifier notifier) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isGenerating || state.generationComplete) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.generationComplete ? 'Generation Complete' : 'Generating Data...',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: state.generationComplete ? Colors.green : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: state.generationProgress,
                            minHeight: 8,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              state.generationComplete ? Colors.green : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.generationComplete) ...[
                    const SizedBox(width: 16),
                    Icon(LucideIcons.checkCircle2, color: Colors.green, size: 32).animate().scale().fadeIn(),
                  ]
                ],
              ),
              const SizedBox(height: 24),
            ],
            
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  spacing: 16,
                  children: [
                    FilledButton.icon(
                      onPressed: (state.isGenerating || state.selectedEntities.isEmpty) ? null : () => notifier.generate(),
                      icon: state.isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(LucideIcons.play),
                      label: Text(state.isGenerating ? 'Generating...' : 'Generate Data'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.isGenerating ? null : () => notifier.reset(),
                      icon: const Icon(LucideIcons.rotateCcw),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
                if (state.generationComplete)
                  FilledButton.tonalIcon(
                    onPressed: () {
                      context.go('/platform/dashboard');
                    },
                    icon: const Icon(LucideIcons.eye),
                    label: const Text('Preview Data in Dashboard'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ).animate().fadeIn().slideX(begin: 0.1, end: 0),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
