import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'providers/business_journey_provider.dart';

class BusinessJourneyScreen extends ConsumerWidget {
  const BusinessJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final state = ref.watch(businessJourneyProvider);
    final notifier = ref.read(businessJourneyProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Guided Business Journey'),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTimeline(context, theme, state, notifier),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    flex: 2,
                    child: _buildStepDetails(context, theme, state, notifier),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildStepDetails(context, theme, state, notifier),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    flex: 3,
                    child: _buildTimeline(context, theme, state, notifier),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, ThemeData theme, BusinessJourneyState state, BusinessJourneyNotifier notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: businessJourneySteps.length,
        itemBuilder: (context, index) {
          final step = businessJourneySteps[index];
          final isActive = index == state.activeStepIndex;
          final isCompleted = index < state.activeStepIndex;

          return InkWell(
            onTap: () => notifier.setActiveStep(index),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isActive ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
                border: Border.all(
                  color: isActive ? theme.colorScheme.primary : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  // Step Indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : (isActive ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest),
                      border: Border.all(
                        color: isActive || isCompleted ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                      ),
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(LucideIcons.check, size: 16, color: theme.colorScheme.onPrimary)
                          : Text(
                              '${index + 1}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Step Title
                  Expanded(
                    child: Text(
                      step.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepDetails(BuildContext context, ThemeData theme, BusinessJourneyState state, BusinessJourneyNotifier notifier) {
    final step = businessJourneySteps[state.activeStepIndex];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Icon + Title
                    Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(step.icon, size: 32, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step ${state.activeStepIndex + 1} of ${businessJourneySteps.length}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.title,
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Description
            Text(
              step.description,
              style: theme.textTheme.titleMedium?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Badges
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildBadge(theme, 'Platform Module', step.platformModule, LucideIcons.box),
                _buildBadge(theme, 'Industry', step.industryModule, LucideIcons.building2),
              ],
            ),
            const SizedBox(height: 32),

            // Business Value Highlight
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.tertiaryContainer),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.lightbulb, color: theme.colorScheme.tertiary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Value',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.businessValue,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Wrap(
                  spacing: 16,
                  children: [
                    OutlinedButton.icon(
                      onPressed: state.activeStepIndex > 0 ? () => notifier.previousStep() : null,
                      icon: const Icon(LucideIcons.arrowLeft),
                      label: const Text('Previous'),
                    ),
                    OutlinedButton.icon(
                      onPressed: state.activeStepIndex < businessJourneySteps.length - 1 ? () => notifier.nextStep() : null,
                      icon: const Icon(LucideIcons.arrowRight),
                      label: const Text('Next'),
                      iconAlignment: IconAlignment.end,
                    ),
                  ],
                ),
                FilledButton.icon(
                  onPressed: () {
                    context.go(step.route);
                  },
                  icon: const Icon(LucideIcons.externalLink),
                  label: Text('Open ${step.title} Module'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate(key: ValueKey(step.id)).fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildBadge(ThemeData theme, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
