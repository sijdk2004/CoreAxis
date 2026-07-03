import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'models/ai_demo_scenario_model.dart';
import 'providers/ai_demo_provider.dart';

class AiDemoScenariosScreen extends ConsumerWidget {
  const AiDemoScenariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(aiDemoProvider);
    final notifier = ref.read(aiDemoProvider.notifier);

    // Filter preview scenario if it's active
    final previewScenario = state.previewScenarioId != null
        ? aiDemoScenarios.firstWhere((s) => s.id == state.previewScenarioId)
        : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('AI Demo Scenarios'),
        centerTitle: false,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main Content
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore ready-made AI demonstrations showcasing the intelligence embedded throughout the CoreAxis ERP Platform.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildScenariosGrid(context, theme, state, notifier),
                ],
              ),
            ),
          ),
          
          // Side Panel (Preview / Loading)
          if (state.runningScenarioId != null || previewScenario != null)
            Container(
              width: ResponsiveBreakpoints.of(context).largerThan(TABLET) ? 500 : 350,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                border: Border(
                  left: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
              ),
              child: _buildSidePanel(context, theme, state, notifier, previewScenario),
            ).animate().slideX(begin: 1, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildScenariosGrid(BuildContext context, ThemeData theme, AiDemoState state, AiDemoNotifier notifier) {
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final crossAxisCount = isDesktop ? (state.runningScenarioId != null || state.previewScenarioId != null ? 2 : 3) : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 1.1,
      ),
      itemCount: aiDemoScenarios.length,
      itemBuilder: (context, index) {
        final scenario = aiDemoScenarios[index];
        return _buildScenarioCard(context, theme, scenario, state, notifier);
      },
    );
  }

  Widget _buildScenarioCard(BuildContext context, ThemeData theme, AiDemoScenarioModel scenario, AiDemoState state, AiDemoNotifier notifier) {
    final isRunning = state.runningScenarioId == scenario.id;
    final isCompleted = state.completedScenarios.contains(scenario.id);
    final isPreviewing = state.previewScenarioId == scenario.id;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isPreviewing || isRunning
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: isPreviewing || isRunning ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(scenario.icon, size: 24, color: theme.colorScheme.primary),
                ),
                const Spacer(),
                if (isCompleted && !isRunning)
                  Icon(LucideIcons.checkCircle2, color: Colors.green, size: 20)
                      .animate()
                      .scale(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              scenario.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                scenario.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: isRunning || state.runningScenarioId != null
                      ? null
                      : () => notifier.runDemo(scenario.id),
                  icon: isRunning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(LucideIcons.play, size: 18),
                  label: Text(isRunning ? 'Running...' : 'Run Demo'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                if (isCompleted && !isRunning)
                  OutlinedButton.icon(
                    onPressed: () => notifier.previewScenario(scenario.id),
                    icon: const Icon(LucideIcons.eye, size: 18),
                    label: const Text('Preview'),
                  ),
                IconButton.outlined(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: scenario.prompt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Prompt copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: theme.colorScheme.inverseSurface,
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.copy, size: 18),
                  tooltip: 'Copy Prompt',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, ThemeData theme, AiDemoState state, AiDemoNotifier notifier, AiDemoScenarioModel? previewScenario) {
    if (state.runningScenarioId != null) {
      final scenario = aiDemoScenarios.firstWhere((s) => s.id == state.runningScenarioId);
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            Text(
              'Running ${scenario.title}...',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Analyzing data and generating insights.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (previewScenario != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.sparkles, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'AI Response',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => notifier.closePreview(),
                  icon: const Icon(LucideIcons.x),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prompt Bubble
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prompt:',
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(previewScenario.prompt),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Response Bubble
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.bot, size: 20, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'CoreAxis AI',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SelectableText(
                          previewScenario.mockResponse,
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox();
  }
}
