import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'providers/demo_story_provider.dart';

class DemoStoryScreen extends ConsumerStatefulWidget {
  const DemoStoryScreen({super.key});

  @override
  ConsumerState<DemoStoryScreen> createState() => _DemoStoryScreenState();
}

class _DemoStoryScreenState extends ConsumerState<DemoStoryScreen> {
  Timer? _timer;
  int _secondsElapsed = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final demoState = ref.watch(demoStoryProvider);
    final currentStep = demoState.steps[demoState.currentStepIndex];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Demo Story Mode'),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Timer: ${_formatTime(_secondsElapsed)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: demoState.progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: isDesktop
          ? _buildDesktopLayout(theme, demoState, currentStep)
          : _buildMobileLayout(theme, demoState, currentStep),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, dynamic demoState, dynamic currentStep) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Agenda
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            border: Border(right: BorderSide(color: theme.dividerColor)),
          ),
          child: _buildAgendaColumn(theme, demoState),
        ),
        // Center Column: Current Demo
        Expanded(
          flex: 5,
          child: Container(
            color: theme.colorScheme.surface,
            child: _buildCurrentDemoColumn(theme, demoState, currentStep),
          ),
        ),
        // Right Column: Speaker Notes
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            border: Border(left: BorderSide(color: theme.dividerColor)),
          ),
          child: _buildSpeakerNotesColumn(theme, currentStep),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme, dynamic demoState, dynamic currentStep) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCurrentDemoColumn(theme, demoState, currentStep),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          _buildSpeakerNotesColumn(theme, currentStep),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          _buildAgendaColumn(theme, demoState),
        ],
      ),
    );
  }

  Widget _buildAgendaColumn(ThemeData theme, dynamic demoState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Presentation Agenda',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: demoState.steps.length,
            itemBuilder: (context, index) {
              final step = demoState.steps[index];
              final isCurrent = index == demoState.currentStepIndex;
              return Container(
                color: isCurrent ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : Colors.transparent,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: step.isCompleted 
                        ? theme.colorScheme.primary 
                        : (isCurrent ? theme.colorScheme.primary.withValues(alpha: 0.5) : theme.colorScheme.surfaceContainerHighest),
                    child: step.isCompleted 
                        ? Icon(LucideIcons.check, size: 14, color: theme.colorScheme.onPrimary)
                        : Text('${index + 1}', style: TextStyle(fontSize: 12, color: isCurrent ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant)),
                  ),
                  title: Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      decoration: step.isCompleted && !isCurrent ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  onTap: () => ref.read(demoStoryProvider.notifier).setStep(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentDemoColumn(ThemeData theme, dynamic demoState, dynamic currentStep) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${demoState.currentStepIndex + 1} of ${demoState.steps.length}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.clock, size: 14, color: theme.colorScheme.onSecondaryContainer),
                    const SizedBox(width: 6),
                    Text(currentStep.expectedDuration, style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(currentStep.title, style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(currentStep.description, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 48),
          
          Text('Talking Points', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...currentStep.talkingPoints.map<Widget>((point) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.arrowRight, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(point, style: theme.textTheme.bodyLarge)),
              ],
            ),
          )).toList(),

          const SizedBox(height: 64),
          const Divider(),
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    context.go(currentStep.targetRoute);
                  },
                  icon: const Icon(LucideIcons.externalLink),
                  label: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Open Screen'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: demoState.currentStepIndex > 0 
                  ? () => ref.read(demoStoryProvider.notifier).previousStep() 
                  : null,
                icon: const Icon(LucideIcons.arrowLeft),
                label: const Text('Previous'),
              ),
              Row(
                children: [
                  Checkbox(
                    value: currentStep.isCompleted,
                    onChanged: (val) {
                      ref.read(demoStoryProvider.notifier).markComplete(val ?? false);
                    },
                  ),
                  const Text('Mark Complete'),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: demoState.currentStepIndex < demoState.steps.length - 1
                      ? () {
                          if (!currentStep.isCompleted) {
                            ref.read(demoStoryProvider.notifier).markComplete(true);
                          }
                          ref.read(demoStoryProvider.notifier).nextStep();
                        }
                      : null,
                    icon: const Icon(LucideIcons.arrowRight),
                    label: const Text('Next Step'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerNotesColumn(ThemeData theme, dynamic currentStep) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Speaker Notes',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.bookOpen, size: 18, color: theme.colorScheme.onTertiaryContainer),
                          const SizedBox(width: 8),
                          Text('Internal Notes', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onTertiaryContainer)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentStep.notes,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onTertiaryContainer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.lightbulb, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('Pro Tip', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentStep.tips,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
