import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'models/roadmap_model.dart';
import 'providers/roadmap_provider.dart';

class RoadmapScreen extends ConsumerWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final items = ref.watch(roadmapProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Product Roadmap'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CoreAxis Platform Roadmap',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
            const SizedBox(height: 8),
            Text(
              'Explore our strategic vision and development pipeline for the ERP ecosystem.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: 48),

            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildPhaseColumn(context, theme, RoadmapPhase.completed, items, 0.ms)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildPhaseColumn(context, theme, RoadmapPhase.current, items, 100.ms)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildPhaseColumn(context, theme, RoadmapPhase.next, items, 200.ms)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildPhaseColumn(context, theme, RoadmapPhase.future, items, 300.ms)),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPhaseColumn(context, theme, RoadmapPhase.completed, items, 0.ms),
                  const SizedBox(height: 32),
                  _buildPhaseColumn(context, theme, RoadmapPhase.current, items, 100.ms),
                  const SizedBox(height: 32),
                  _buildPhaseColumn(context, theme, RoadmapPhase.next, items, 200.ms),
                  const SizedBox(height: 32),
                  _buildPhaseColumn(context, theme, RoadmapPhase.future, items, 300.ms),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseColumn(BuildContext context, ThemeData theme, RoadmapPhase phase, List<RoadmapItemModel> items, Duration delay) {
    final phaseItems = items.where((item) => item.phase == phase).toList();

    String title;
    IconData icon;
    Color color;

    switch (phase) {
      case RoadmapPhase.completed:
        title = 'Completed';
        icon = LucideIcons.checkCircle2;
        color = Colors.green;
        break;
      case RoadmapPhase.current:
        title = 'Current / In Progress';
        icon = LucideIcons.loader2;
        color = theme.colorScheme.primary;
        break;
      case RoadmapPhase.next:
        title = 'Next Up';
        icon = LucideIcons.arrowRightCircle;
        color = Colors.orange;
        break;
      case RoadmapPhase.future:
        title = 'Future Considerations';
        icon = LucideIcons.telescope;
        color = Colors.purple;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phase Header
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ).animate().fadeIn(delay: delay).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 16),
        
        // Phase Items
        if (phaseItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Text(
              'No items scheduled.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(delay: delay + 100.ms)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: phaseItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _buildRoadmapCard(context, theme, phaseItems[index])
                  .animate()
                  .fadeIn(delay: delay + (index * 100).ms)
                  .slideY(begin: 0.1, end: 0);
            },
          ),
      ],
    );
  }

  Widget _buildRoadmapCard(BuildContext context, ThemeData theme, RoadmapItemModel item) {
    Color trackColor;
    String trackName;

    switch (item.track) {
      case RoadmapTrack.platform:
        trackColor = Colors.blue;
        trackName = 'Platform';
        break;
      case RoadmapTrack.furniture:
        trackColor = Colors.brown;
        trackName = 'FurniFlow';
        break;
      case RoadmapTrack.steel:
        trackColor = Colors.blueGrey;
        trackName = 'SteelFlow';
        break;
      case RoadmapTrack.garment:
        trackColor = Colors.pink;
        trackName = 'GarmentFlow';
        break;
      case RoadmapTrack.ai:
        trackColor = Colors.deepPurple;
        trackName = 'AI & ML';
        break;
      case RoadmapTrack.mobile:
        trackColor = Colors.teal;
        trackName = 'Mobile';
        break;
      case RoadmapTrack.integrations:
        trackColor = Colors.orange;
        trackName = 'Integrations';
        break;
    }

    return Card(
      elevation: 0,
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
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trackColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: trackColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    trackName,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: trackColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (item.date != null)
                  Text(
                    item.date!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, size: 20, color: theme.colorScheme.onSurface),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
