import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'providers/delivery_queue_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DeliveryQueueScreen extends ConsumerWidget {
  const DeliveryQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(deliveryQueueProvider);
    final notifier = ref.read(deliveryQueueProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, theme, state, notifier),
                  const SizedBox(height: 24),
                  _buildToolbar(context, theme, state, notifier),
                  const SizedBox(height: 32),
                  _buildStatisticsCards(context, theme, state),
                  const SizedBox(height: 32),
                  _buildQueueTable(context, theme, state, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, DeliveryQueueState state, DeliveryQueueNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('Delivery Queue Monitor', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            if (state.autoRefreshEnabled)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fadeOut(duration: 800.ms),
                    const SizedBox(width: 8),
                    const Text('LIVE', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
          ],
        ),
        Row(
          children: [
            Text('Auto Refresh', style: theme.textTheme.bodyMedium),
            const SizedBox(width: 8),
            Switch(
              value: state.autoRefreshEnabled,
              onChanged: notifier.toggleAutoRefresh,
            ),
          ],
        )
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, DeliveryQueueState state, DeliveryQueueNotifier notifier) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: notifier.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search queue by ID, Recipient or Name...',
              prefixIcon: const Icon(LucideIcons.search),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: state.selectedStatusFilter,
              icon: const Icon(LucideIcons.filter, size: 16),
              onChanged: (val) {
                if (val != null) notifier.setStatusFilter(val);
              },
              items: ['All', 'Pending', 'Processing', 'Delivered', 'Failed', 'Retry Queue']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(BuildContext context, ThemeData theme, DeliveryQueueState state) {
    int pending = 0, processing = 0, delivered = 0, failed = 0, retry = 0;

    for (var i in state.items) {
      if (i.status == 'Pending') pending++;
      else if (i.status == 'Processing') processing++;
      else if (i.status == 'Delivered') delivered++;
      else if (i.status == 'Failed') failed++;
      else if (i.status == 'Retry Queue') retry++;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 5 : (constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 600 ? 2 : 1));
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildStatCard('Pending', pending.toString(), LucideIcons.clock, Colors.orange, theme),
            _buildStatCard('Processing', processing.toString(), LucideIcons.loader, Colors.blue, theme, isAnimated: true),
            _buildStatCard('Delivered', delivered.toString(), LucideIcons.checkCircle, Colors.green, theme),
            _buildStatCard('Failed', failed.toString(), LucideIcons.xCircle, Colors.red, theme),
            _buildStatCard('Retry Queue', retry.toString(), LucideIcons.refreshCw, Colors.purple, theme),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme, {bool isAnimated = false}) {
    Widget iconWidget = Icon(icon, color: color);
    if (isAnimated) {
      iconWidget = iconWidget.animate(onPlay: (controller) => controller.repeat()).rotate(duration: 2.seconds);
    }
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: iconWidget,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueTable(BuildContext context, ThemeData theme, DeliveryQueueState state, DeliveryQueueNotifier notifier) {
    final format = DateFormat('HH:mm:ss');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Live Processing Queue', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              columns: const [
                DataColumn(label: Text('Queue ID')),
                DataColumn(label: Text('Notification')),
                DataColumn(label: Text('Recipient')),
                DataColumn(label: Text('Channel')),
                DataColumn(label: Text('Priority')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Retry')),
                DataColumn(label: Text('Created At')),
                DataColumn(label: Text('Actions')),
              ],
              rows: state.filteredItems.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item.id, style: const TextStyle(fontWeight: FontWeight.w600))),
                    DataCell(Text(item.notificationName)),
                    DataCell(Text(item.recipient)),
                    DataCell(Text(item.channel)),
                    DataCell(_buildPriorityBadge(item.priority, theme)),
                    DataCell(_buildStatusBadge(item.status, theme)),
                    DataCell(Text(item.retryCount > 0 ? '${item.retryCount}' : '-')),
                    DataCell(Text(format.format(item.createdAt))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.status == 'Failed' || item.status == 'Retry Queue')
                            IconButton(
                              icon: const Icon(LucideIcons.refreshCw, size: 18, color: Colors.blue),
                              onPressed: () => notifier.retryItem(item.id),
                              tooltip: 'Retry Now',
                            ),
                          if (item.status == 'Pending' || item.status == 'Retry Queue')
                            IconButton(
                              icon: const Icon(LucideIcons.xOctagon, size: 18, color: Colors.red),
                              onPressed: () => notifier.cancelItem(item.id),
                              tooltip: 'Cancel',
                            ),
                          IconButton(
                            icon: const Icon(LucideIcons.eye, size: 18),
                            onPressed: () {},
                            tooltip: 'View Details',
                          ),
                        ],
                      )
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(String priority, ThemeData theme) {
    Color color;
    switch (priority) {
      case 'Critical': color = Colors.red; break;
      case 'High': color = Colors.orange; break;
      case 'Normal': color = Colors.blue; break;
      case 'Low': color = Colors.grey; break;
      default: color = Colors.grey;
    }
    return Row(
      children: [
        Icon(LucideIcons.alertCircle, size: 14, color: color),
        const SizedBox(width: 4),
        Text(priority, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    switch (status) {
      case 'Delivered': color = Colors.green; break;
      case 'Processing': color = Colors.blue; break;
      case 'Failed': color = Colors.red; break;
      case 'Pending': color = Colors.orange; break;
      case 'Retry Queue': color = Colors.purple; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
