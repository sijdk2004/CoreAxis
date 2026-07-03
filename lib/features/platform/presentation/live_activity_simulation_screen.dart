import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'providers/live_activity_provider.dart';

class LiveActivitySimulationScreen extends ConsumerWidget {
  const LiveActivitySimulationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(liveActivityProvider);
    final notifier = ref.read(liveActivityProvider.notifier);
    final numberFormat = NumberFormat.compact();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Live Activity Simulation'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              notifier.clearEvents();
            },
            icon: const Icon(LucideIcons.trash2),
            label: const Text('Clear'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Controls Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    // Activity Counter
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Simulated Events', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(LucideIcons.activity, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                numberFormat.format(state.totalActivityCount),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Controls
                    Expanded(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _buildSpeedToggle(theme, state, notifier),
                          const SizedBox(width: 32),
                          FloatingActionButton.extended(
                            onPressed: () {
                              notifier.togglePlayPause();
                            },
                            icon: Icon(state.isRunning ? LucideIcons.pause : LucideIcons.play),
                            label: Text(state.isRunning ? 'Pause Stream' : 'Resume Stream'),
                            backgroundColor: state.isRunning ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
                            foregroundColor: state.isRunning ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
                            elevation: 0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Live Feed List
            Expanded(
              child: Card(
                child: state.events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.listPlus, size: 48, color: theme.colorScheme.outline),
                            const SizedBox(height: 16),
                            Text('No activity generated yet.', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                            const SizedBox(height: 8),
                            Text('Press Resume Stream to start the simulation.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.events.length,
                        padding: const EdgeInsets.all(16),
                        itemBuilder: (context, index) {
                          final event = state.events[index];
                          return _buildEventTile(theme, event)
                              .animate(key: ValueKey(event.id))
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: -0.05, end: 0, curve: Curves.easeOutCubic);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedToggle(ThemeData theme, LiveActivityState state, LiveActivityNotifier notifier) {
    return SegmentedButton<double>(
      segments: const [
        ButtonSegment(value: 1.0, label: Text('1x Speed')),
        ButtonSegment(value: 2.0, label: Text('2x Speed')),
        ButtonSegment(value: 5.0, label: Text('5x Speed')),
      ],
      selected: {state.speedMultiplier},
      onSelectionChanged: (Set<double> newSelection) {
        notifier.setSpeedMultiplier(newSelection.first);
      },
    );
  }

  Widget _buildEventTile(ThemeData theme, event) {
    final timeFormat = DateFormat('HH:mm:ss');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line & icon
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: event.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: event.color.withValues(alpha: 0.5)),
                ),
                child: Icon(event.icon, size: 20, color: event.color),
              ),
              Container(
                width: 2,
                height: 40,
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text(
                          timeFormat.format(event.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(event.description, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
