import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../domain/models/entity_timeline_model.dart';
import 'providers/entity_timeline_provider.dart';

class EntityTimelineScreen extends ConsumerStatefulWidget {
  final String entityId;

  const EntityTimelineScreen({
    super.key,
    required this.entityId,
  });

  @override
  ConsumerState<EntityTimelineScreen> createState() => _EntityTimelineScreenState();
}

class _EntityTimelineScreenState extends ConsumerState<EntityTimelineScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(entityTimelineProvider.notifier).loadTimeline(widget.entityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateMap = ref.watch(entityTimelineProvider);
    final asyncState = stateMap[widget.entityId] ?? const AsyncValue.loading();
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Entity Timeline: ${widget.entityId}'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: () {},
            tooltip: 'Filter Timeline',
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.download),
            label: const Text('Export Log'),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, state),
                const SizedBox(height: 32),
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _buildTimeline(context, ref, state),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 1,
                        child: _buildSummarySidebar(context, state),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildSummarySidebar(context, state),
                      const SizedBox(height: 32),
                      _buildTimeline(context, ref, state),
                    ],
                  ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, EntityTimelineModel state) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconForType(state.entityType), size: 32, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(state.entityName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.5)),
                        ),
                        child: Text(state.status.toUpperCase(), style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${state.entityType} • ID: ${state.entityId}', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySidebar(BuildContext context, EntityTimelineModel state) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entity Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ...state.summary.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.key, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, WidgetRef ref, EntityTimelineModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Activity History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ...state.events.asMap().entries.map((entry) {
          final isLast = entry.key == state.events.length - 1;
          return _buildTimelineNode(context, ref, state.entityId, entry.value, isLast);
        }),
      ],
    );
  }

  Widget _buildTimelineNode(BuildContext context, WidgetRef ref, String entityId, TimelineEvent event, bool isLast) {
    final theme = Theme.of(context);
    final iconData = _getIconForAction(event.action);
    final colorData = _getColorForAction(event.action);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline graphics
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorData.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: colorData.withOpacity(0.5)),
                  ),
                  child: Icon(iconData, size: 16, color: colorData),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: InkWell(
                  onTap: event.metadata.isNotEmpty ? () {
                    ref.read(entityTimelineProvider.notifier).toggleEventExpanded(entityId, event.id);
                  } : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(event.action, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorData)),
                            Text(event.timestamp, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(event.details, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(LucideIcons.user, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(event.user, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                            const SizedBox(width: 16),
                            Icon(LucideIcons.box, size: 14, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(event.module, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                            const Spacer(),
                            if (event.metadata.isNotEmpty)
                              Icon(event.isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: Colors.grey),
                          ],
                        ),
                        if (event.isExpanded && event.metadata.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          ...event.metadata.entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(e.key, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ),
                                Expanded(
                                  child: Text(e.value.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'user account':
        return LucideIcons.user;
      case 'organization':
        return LucideIcons.building;
      case 'tenant':
        return LucideIcons.server;
      case 'document':
      default:
        return LucideIcons.fileText;
    }
  }

  IconData _getIconForAction(String action) {
    switch (action.toLowerCase()) {
      case 'created':
        return LucideIcons.plusCircle;
      case 'updated':
        return LucideIcons.edit2;
      case 'approved':
        return LucideIcons.checkCircle2;
      case 'rejected':
        return LucideIcons.xCircle;
      case 'shared':
        return LucideIcons.share2;
      case 'downloaded':
        return LucideIcons.download;
      case 'deleted':
        return LucideIcons.trash2;
      case 'restored':
        return LucideIcons.refreshCcw;
      default:
        return LucideIcons.activity;
    }
  }

  Color _getColorForAction(String action) {
    switch (action.toLowerCase()) {
      case 'created':
      case 'approved':
      case 'restored':
        return Colors.green;
      case 'updated':
      case 'shared':
      case 'downloaded':
        return Colors.blue;
      case 'rejected':
      case 'deleted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
