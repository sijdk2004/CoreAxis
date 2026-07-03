import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'providers/industry_scenario_provider.dart';
import 'models/industry_scenario_model.dart';

class IndustryScenarioSwitcherScreen extends ConsumerWidget {
  const IndustryScenarioSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(industryScenarioProvider);
    final isMobile = ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE);
    final isTablet = ResponsiveBreakpoints.of(context).smallerOrEqualTo(TABLET);

    int crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 4);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Industry Scenario Switcher'),
        centerTitle: false,
        actions: [
          if (state.activeScenario != null || state.previewScenario != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FilledButton.tonalIcon(
                onPressed: () {
                  ref.read(industryScenarioProvider.notifier).resetScenario();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reset to Default ERP Configuration')),
                  );
                },
                icon: const Icon(LucideIcons.rotateCcw),
                label: const Text('Reset to Default'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select an Industry Scenario',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Instantly tailor the ERP demo environment (mock data, dashboards, and workflows) for a specific vertical.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: _buildGridRows(
                    context, 
                    ref, 
                    state, 
                    theme, 
                    crossAxisCount,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioCard(
    BuildContext context,
    WidgetRef ref,
    IndustryScenarioModel scenario,
    IndustryScenarioState state,
    ThemeData theme,
  ) {
    final isActive = state.activeScenario?.id == scenario.id;
    final isPreview = state.previewScenario?.id == scenario.id;

    Color borderColor = Colors.transparent;
    if (isActive) borderColor = theme.colorScheme.primary;
    if (isPreview) borderColor = theme.colorScheme.tertiary;

    return Card(
      elevation: isActive ? 8 : (isPreview ? 4 : 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor == Colors.transparent ? theme.colorScheme.outlineVariant : borderColor,
          width: isActive || isPreview ? 2 : 1,
        ),
      ),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scenario.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(scenario.icon, color: scenario.primaryColor, size: 32),
                ),
                if (isActive)
                  Chip(
                    label: const Text('Active', style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimaryContainer),
                  )
                else if (isPreview)
                  Chip(
                    label: const Text('Preview', style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: theme.colorScheme.tertiaryContainer,
                    labelStyle: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(scenario.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              scenario.description,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: scenario.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Icon(LucideIcons.checkCircle2, size: 14, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              children: [
                FilledButton(
                  onPressed: isActive
                      ? null
                      : () {
                          ref.read(industryScenarioProvider.notifier).activateScenario(scenario);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${scenario.name} Scenario Activated!')),
                          );
                        },
                  child: const Text('Activate'),
                ),
                OutlinedButton(
                  onPressed: () {
                    if (isPreview) {
                      ref.read(industryScenarioProvider.notifier).stopPreview();
                    } else {
                      ref.read(industryScenarioProvider.notifier).previewScenario(scenario);
                    }
                  },
                  child: Text(isPreview ? 'Stop' : 'Preview'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  // Mock Compare Action
                  _showCompareDialog(context, scenario, theme);
                },
                icon: const Icon(LucideIcons.gitCompare, size: 16),
                label: const Text('Compare'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompareDialog(BuildContext context, IndustryScenarioModel scenario, ThemeData theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Compare with ${scenario.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This will compare the current active scenario with ${scenario.name}.'),
            const SizedBox(height: 16),
            const Text('Mock Comparison Results:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(LucideIcons.fileDiff, color: theme.colorScheme.primary),
              title: const Text('Dashboard Layouts: Different'),
            ),
            ListTile(
              leading: Icon(LucideIcons.fileDiff, color: theme.colorScheme.primary),
              title: const Text('Workflow Engines: 3 new triggers'),
            ),
            ListTile(
              leading: Icon(LucideIcons.fileDiff, color: theme.colorScheme.primary),
              title: const Text('AI Prompts: Vertically tuned'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGridRows(
    BuildContext context,
    WidgetRef ref,
    IndustryScenarioState state,
    ThemeData theme,
    int crossAxisCount,
  ) {
    final List<Widget> rows = [];
    final scenarios = state.availableScenarios;
    
    for (int i = 0; i < scenarios.length; i += crossAxisCount) {
      final rowChildren = <Widget>[];
      
      for (int j = 0; j < crossAxisCount; j++) {
        if (i + j < scenarios.length) {
          rowChildren.add(
            Expanded(
              child: _buildScenarioCard(context, ref, scenarios[i + j], state, theme),
            ),
          );
        } else {
          // Empty space to maintain grid alignment
          rowChildren.add(const Expanded(child: SizedBox()));
        }
        
        if (j < crossAxisCount - 1) {
          rowChildren.add(const SizedBox(width: 24));
        }
      }

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowChildren,
            ),
          ),
        ),
      );
    }
    
    return rows;
  }
}
