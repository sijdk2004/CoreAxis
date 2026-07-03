import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/delivery_history_model.dart';
import 'providers/delivery_history_provider.dart';

class DeliveryHistoryScreen extends ConsumerWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(deliveryHistoryProvider);
    final notifier = ref.read(deliveryHistoryProvider.notifier);

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
                  _buildContentArea(context, theme, state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, DeliveryHistoryState state, DeliveryHistoryNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Delivery History', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        Row(
          children: [
            SegmentedButton<HistoryViewMode>(
              segments: const [
                ButtonSegment(value: HistoryViewMode.table, icon: Icon(LucideIcons.table)),
                ButtonSegment(value: HistoryViewMode.card, icon: Icon(LucideIcons.layoutGrid)),
                ButtonSegment(value: HistoryViewMode.timeline, icon: Icon(LucideIcons.gitCommit)),
              ],
              selected: {state.viewMode},
              onSelectionChanged: (Set<HistoryViewMode> newSelection) {
                notifier.setViewMode(newSelection.first);
              },
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting CSV...')));
              },
              icon: const Icon(LucideIcons.download, size: 16),
              label: const Text('Export'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, DeliveryHistoryState state, DeliveryHistoryNotifier notifier) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            onChanged: notifier.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search by Notification, Recipient, or ID...',
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
              items: ['All', 'Delivered', 'Failed', 'Read', 'Unread']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(BuildContext context, ThemeData theme, DeliveryHistoryState state) {
    int delivered = 0, failed = 0, read = 0, unread = 0;

    for (var i in state.items) {
      if (i.status == 'Failed') failed++;
      else {
        delivered++; // Read/Unread are subsets of delivered
        if (i.status == 'Read') read++;
        if (i.status == 'Unread') unread++;
        if (i.status == 'Delivered') unread++; // Assume Delivered but not read is unread.
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildStatCard('Delivered', delivered.toString(), LucideIcons.send, Colors.blue, theme),
            _buildStatCard('Read', read.toString(), LucideIcons.mailOpen, Colors.green, theme),
            _buildStatCard('Unread', unread.toString(), LucideIcons.mail, Colors.orange, theme),
            _buildStatCard('Failed', failed.toString(), LucideIcons.xCircle, Colors.red, theme),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, ThemeData theme) {
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
              child: Icon(icon, color: color),
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

  Widget _buildContentArea(BuildContext context, ThemeData theme, DeliveryHistoryState state) {
    if (state.filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Column(
            children: [
              Icon(LucideIcons.search, size: 48, color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 16),
              Text('No history records found', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    switch (state.viewMode) {
      case HistoryViewMode.table:
        return _buildTableView(theme, state);
      case HistoryViewMode.card:
        return _buildCardView(theme, state);
      case HistoryViewMode.timeline:
        return _buildTimelineView(theme, state);
    }
  }

  Widget _buildTableView(ThemeData theme, DeliveryHistoryState state) {
    final format = DateFormat('MMM dd, HH:mm:ss');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          columns: const [
            DataColumn(label: Text('Notification')),
            DataColumn(label: Text('Recipient')),
            DataColumn(label: Text('Channel')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Delivered At')),
            DataColumn(label: Text('Read At')),
            DataColumn(label: Text('Provider')),
            DataColumn(label: Text('Duration')),
            DataColumn(label: Text('Actions')),
          ],
          rows: state.filteredItems.map((item) {
            return DataRow(
              cells: [
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(item.notificationName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(item.id, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                DataCell(Text(item.recipient)),
                DataCell(Text(item.channel)),
                DataCell(_buildStatusBadge(item.status, theme)),
                DataCell(Text(format.format(item.deliveredAt))),
                DataCell(Text(item.readAt != null ? format.format(item.readAt!) : '-')),
                DataCell(Text(item.provider)),
                DataCell(Text('${item.duration.inMilliseconds} ms')),
                DataCell(
                  IconButton(
                    icon: const Icon(LucideIcons.eye, size: 18),
                    onPressed: () {},
                    tooltip: 'View Details',
                  )
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardView(ThemeData theme, DeliveryHistoryState state) {
    final format = DateFormat('MMM dd, yyyy HH:mm:ss');
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 220,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: state.filteredItems.length,
      itemBuilder: (context, index) {
        final item = state.filteredItems[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(item.notificationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
                    _buildStatusBadge(item.status, theme),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.id, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(LucideIcons.user, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item.recipient, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 16),
                    const SizedBox(width: 8),
                    Text(format.format(item.deliveredAt)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(LucideIcons.server, size: 16),
                    const SizedBox(width: 8),
                    Text('${item.provider} (${item.duration.inMilliseconds}ms)'),
                  ],
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(LucideIcons.eye, size: 14),
                    label: const Text('Details'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineView(ThemeData theme, DeliveryHistoryState state) {
    final format = DateFormat('MMM dd, yyyy HH:mm:ss');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: theme.colorScheme.outlineVariant)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.filteredItems.length,
          itemBuilder: (context, index) {
            final item = state.filteredItems[index];
            final isLast = index == state.filteredItems.length - 1;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 150,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                      child: Text(
                        format.format(item.deliveredAt),
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(item.status),
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.colorScheme.surface, width: 2),
                        ),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(item.notificationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 8),
                              _buildStatusBadge(item.status, theme),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Sent to ${item.recipient} via ${item.channel} (${item.provider})', style: theme.textTheme.bodyMedium),
                          if (item.readAt != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text('Read at ${format.format(item.readAt!)}', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                            )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered': return Colors.blue;
      case 'Read': return Colors.green;
      case 'Failed': return Colors.red;
      case 'Unread': return Colors.orange;
      default: return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    final color = _getStatusColor(status);
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
