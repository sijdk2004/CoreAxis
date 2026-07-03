import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import 'providers/ai_insights_center_provider.dart';
import '../domain/ai_insights_center_model.dart';

class AiInsightsCenterScreen extends ConsumerStatefulWidget {
  const AiInsightsCenterScreen({super.key});

  @override
  ConsumerState<AiInsightsCenterScreen> createState() => _AiInsightsCenterScreenState();
}

class _AiInsightsCenterScreenState extends ConsumerState<AiInsightsCenterScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiInsightsCenterProvider);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);
    
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(context, state),
          _buildFilterBar(context, state),
          const Divider(height: 1),
          Expanded(
            child: state.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildInsightsList(context, state, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AiInsightsCenterState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.lightbulb, size: 28, color: Colors.amber),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Insights Center', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Proactive recommendations and anomaly detection.', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.download, size: 18),
            label: const Text('Export Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, AiInsightsCenterState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: theme.colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search insights...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) {
                ref.read(aiInsightsCenterProvider.notifier).updateFilters(search: val);
              },
            ),
          ),
          const SizedBox(width: 16),
          _buildDropdown(
            context,
            'Priority',
            state.selectedPriority,
            ['All', 'Critical', 'High', 'Medium', 'Low'],
            (val) => ref.read(aiInsightsCenterProvider.notifier).updateFilters(priority: val),
          ),
          const SizedBox(width: 16),
          _buildDropdown(
            context,
            'Module',
            state.selectedCategory,
            ['All', 'Operations', 'Security', 'Finance', 'Workflow', 'Reporting', 'Users', 'Documents', 'Notifications'],
            (val) => ref.read(aiInsightsCenterProvider.notifier).updateFilters(category: val),
          ),
          const SizedBox(width: 16),
          _buildDropdown(
            context,
            'Date',
            state.selectedDate,
            ['Any Time', 'Today', 'Last 7 Days', 'Last 30 Days'],
            (val) => ref.read(aiInsightsCenterProvider.notifier).updateFilters(date: val),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context, String hint, String value, List<String> items, Function(String?) onChanged) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          icon: const Icon(LucideIcons.chevronDown, size: 16),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInsightsList(BuildContext context, AiInsightsCenterState state, bool isDesktop) {
    final insights = state.filteredInsights;
    
    if (insights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.checkCircle, size: 64, color: Colors.green.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No actionable insights right now.', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('You are all caught up!', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: insights.length,
      itemBuilder: (context, index) {
        final insight = insights[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildInsightCard(context, insight, isDesktop).animate().fade(delay: Duration(milliseconds: 50 * index)).slideX(),
        );
      },
    );
  }

  Widget _buildInsightCard(BuildContext context, AiInsight insight, bool isDesktop) {
    final theme = Theme.of(context);
    
    Color priorityColor;
    IconData priorityIcon;
    switch (insight.priority) {
      case InsightPriority.critical:
        priorityColor = Colors.red;
        priorityIcon = LucideIcons.alertOctagon;
        break;
      case InsightPriority.high:
        priorityColor = Colors.orange;
        priorityIcon = LucideIcons.alertTriangle;
        break;
      case InsightPriority.medium:
        priorityColor = Colors.amber;
        priorityIcon = LucideIcons.alertCircle;
        break;
      case InsightPriority.low:
        priorityColor = Colors.blue;
        priorityIcon = LucideIcons.info;
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Icon(priorityIcon, color: priorityColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    insight.title, 
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: priorityColor),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Text(
                    '${insight.category.name.toUpperCase()}',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: theme.textTheme.bodySmall?.color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(DateFormat('MMM d, HH:mm').format(insight.date), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          
          // Card Body
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Flex(
              direction: isDesktop ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: isDesktop ? 2 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Insight:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(insight.description, style: const TextStyle(height: 1.5)),
                      const SizedBox(height: 16),
                      Text('Impact:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(insight.impact, style: TextStyle(height: 1.5, color: theme.colorScheme.error)),
                    ],
                  ),
                ),
                if (isDesktop) const SizedBox(width: 32),
                if (!isDesktop) const SizedBox(height: 16),
                Expanded(
                  flex: isDesktop ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.sparkles, size: 16, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('AI Recommendation', style: theme.textTheme.titleSmall?.copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(insight.recommendation, style: const TextStyle(height: 1.4)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Confidence:', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: insight.confidence / 100,
                                backgroundColor: theme.dividerColor,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${insight.confidence}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Card Footer (Actions)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(aiInsightsCenterProvider.notifier).dismissInsight(insight.id);
                  },
                  child: const Text('Dismiss'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {},
                  child: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(aiInsightsCenterProvider.notifier).applyRecommendation(insight.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Applied recommendation for: ${insight.title}')),
                    );
                  },
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: const Text('Apply Recommendation'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
