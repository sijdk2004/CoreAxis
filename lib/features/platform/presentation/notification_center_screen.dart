import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../domain/models/notification_center_model.dart';
import 'providers/notification_center_provider.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  NotificationMessage? _selectedNotification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationCenterProvider);
    final notifier = ref.read(notificationCenterProvider.notifier);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.background,
      endDrawer: _buildDetailDrawer(theme, notifier),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme, state, notifier),
                  const SizedBox(height: 24),
                  _buildQuickFilters(theme, state, notifier),
                  const SizedBox(height: 24),
                  _buildBulkActions(theme, state, notifier),
                  const SizedBox(height: 16),
                  if (state.isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(64.0), child: CircularProgressIndicator()))
                  else if (state.filteredItems.isEmpty)
                    _buildEmptyState(theme)
                  else
                    _buildContentView(theme, state, notifier),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, NotificationCenterState state, NotificationCenterNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notification Center', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildToolbar(theme, state, notifier),
            ],
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Notification Center', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            _buildToolbar(theme, state, notifier),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(ThemeData theme, NotificationCenterState state, NotificationCenterNotifier notifier) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 250,
          child: TextField(
            onChanged: notifier.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search notifications...',
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(LucideIcons.filter, size: 16),
          label: const Text('Advanced'),
        ),
        IconButton(
          onPressed: () => notifier.refresh(),
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          tooltip: 'Refresh',
        ),
        Container(
          height: 24,
          width: 1,
          color: theme.colorScheme.outlineVariant,
          margin: const EdgeInsets.symmetric(horizontal: 4),
        ),
        SegmentedButton<NotificationViewType>(
          segments: const [
            ButtonSegment(value: NotificationViewType.table, icon: Icon(LucideIcons.table, size: 16)),
            ButtonSegment(value: NotificationViewType.card, icon: Icon(LucideIcons.grid, size: 16)),
            ButtonSegment(value: NotificationViewType.timeline, icon: Icon(LucideIcons.clock, size: 16)),
          ],
          selected: {state.viewType},
          onSelectionChanged: (Set<NotificationViewType> newSelection) {
            notifier.setViewType(newSelection.first);
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFilters(ThemeData theme, NotificationCenterState state, NotificationCenterNotifier notifier) {
    final filters = ['All', 'Unread', 'Read', 'High Priority', 'Workflow', 'Approval', 'System', 'Finance', 'Production', 'Inventory'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = state.activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) notifier.setActiveFilter(filter);
              },
              showCheckmark: false,
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBulkActions(ThemeData theme, NotificationCenterState state, NotificationCenterNotifier notifier) {
    final count = state.selectedIds.length;
    if (count == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primaryContainer),
      ),
      child: Row(
        children: [
          Text('$count selected', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => notifier.markAsRead(state.selectedIds.toList()),
            icon: const Icon(LucideIcons.check, size: 16),
            label: const Text('Mark Read'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => notifier.archiveItems(state.selectedIds.toList()),
            icon: const Icon(LucideIcons.archive, size: 16),
            label: const Text('Archive'),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => notifier.deleteItems(state.selectedIds.toList()),
            icon: const Icon(LucideIcons.trash2, size: 16),
            label: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0),
        child: Column(
          children: [
            Icon(LucideIcons.inbox, size: 64, color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text('No notifications found', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Try adjusting your search or filters.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView(ThemeData theme, NotificationCenterState state, NotificationCenterNotifier notifier) {
    switch (state.viewType) {
      case NotificationViewType.table:
        return _buildTableView(theme, state, notifier);
      case NotificationViewType.card:
        return _buildCardView(theme, state, notifier);
      case NotificationViewType.timeline:
        return _buildTimelineView(theme, state, notifier);
    }
  }

  Widget _buildTableView(ThemeData theme, NotificationCenterState state, NotificationCenterNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
          dataRowMinHeight: 56,
          dataRowMaxHeight: 56,
          columns: [
            DataColumn(
              label: Checkbox(
                value: state.selectedIds.length == state.filteredItems.length && state.filteredItems.isNotEmpty,
                onChanged: (v) => notifier.toggleSelectAll(),
              ),
            ),
            const DataColumn(label: Text('Status')),
            const DataColumn(label: Text('Title')),
            const DataColumn(label: Text('Module')),
            const DataColumn(label: Text('Priority')),
            const DataColumn(label: Text('Created')),
            const DataColumn(label: Text('Actions')),
          ],
          rows: state.filteredItems.map((item) {
            final isUnread = item.status == 'Unread';
            final textStyle = isUnread ? const TextStyle(fontWeight: FontWeight.bold) : null;
            return DataRow(
              selected: state.selectedIds.contains(item.id),
              onSelectChanged: (v) => notifier.toggleSelection(item.id),
              cells: [
                DataCell(
                  Checkbox(
                    value: state.selectedIds.contains(item.id),
                    onChanged: (v) => notifier.toggleSelection(item.id),
                  )
                ),
                DataCell(_buildStatusBadge(item.status, theme)),
                DataCell(
                  SizedBox(
                    width: 300,
                    child: Text(item.title, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                  )
                ),
                DataCell(Text(item.module, style: textStyle)),
                DataCell(_buildPriorityBadge(item.priority, theme)),
                DataCell(Text(DateFormat('MMM dd, HH:mm').format(item.createdTime), style: textStyle)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.eye, size: 18),
                        onPressed: () => _openDetailDrawer(item, notifier),
                        tooltip: 'View Details',
                      ),
                      if (isUnread)
                        IconButton(
                          icon: const Icon(LucideIcons.check, size: 18),
                          onPressed: () => notifier.markAsRead([item.id]),
                          tooltip: 'Mark Read',
                        ),
                    ],
                  )
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardView(ThemeData theme, NotificationCenterState state, NotificationCenterNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200 ? 3 : (constraints.maxWidth > 800 ? 2 : 1);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: state.filteredItems.length,
          itemBuilder: (context, index) {
            final item = state.filteredItems[index];
            final isSelected = state.selectedIds.contains(item.id);
            final isUnread = item.status == 'Unread';
            
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              color: isUnread ? theme.colorScheme.surface : theme.colorScheme.surfaceVariant.withOpacity(0.3),
              child: InkWell(
                onTap: () => notifier.toggleSelection(item.id),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(item.status, theme),
                          Text(DateFormat('MMM dd, HH:mm').format(item.createdTime), style: theme.textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(item.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: isUnread ? FontWeight.bold : FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(item.message, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.box, size: 14, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(item.module, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(LucideIcons.eye, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _openDetailDrawer(item, notifier),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    );
  }

  Widget _buildTimelineView(ThemeData theme, NotificationCenterState state, NotificationCenterNotifier notifier) {
    // Group by Date
    final Map<String, List<NotificationMessage>> grouped = {};
    for (var item in state.filteredItems) {
      final dateStr = DateFormat('yyyy-MM-dd').format(item.createdTime);
      grouped.putIfAbsent(dateStr, () => []).add(item);
    }
    
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedKeys.map((dateStr) {
        final items = grouped[dateStr]!;
        
        // Pretty date
        final date = DateTime.parse(dateStr);
        final now = DateTime.now();
        String displayDate;
        if (date.year == now.year && date.month == now.month && date.day == now.day) {
          displayDate = 'Today';
        } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
          displayDate = 'Yesterday';
        } else {
          displayDate = DateFormat('MMMM dd, yyyy').format(date);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(displayDate, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ),
            ...items.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12, left: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(LucideIcons.bell, color: theme.colorScheme.onPrimaryContainer),
                  ),
                  title: Text(item.title, style: TextStyle(fontWeight: item.status == 'Unread' ? FontWeight.bold : FontWeight.normal)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.message),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatusBadge(item.status, theme),
                            const SizedBox(width: 8),
                            _buildPriorityBadge(item.priority, theme),
                            const SizedBox(width: 8),
                            Text(DateFormat('HH:mm').format(item.createdTime), style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: OutlinedButton(
                    onPressed: () => _openDetailDrawer(item, notifier),
                    child: const Text('View'),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }

  void _openDetailDrawer(NotificationMessage item, NotificationCenterNotifier notifier) {
    if (item.status == 'Unread') {
      notifier.markAsRead([item.id]);
    }
    setState(() {
      // Find the updated item from state to ensure we get the read status
      _selectedNotification = ref.read(notificationCenterProvider).allItems.firstWhere((e) => e.id == item.id, orElse: () => item);
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Widget _buildDetailDrawer(ThemeData theme, NotificationCenterNotifier notifier) {
    if (_selectedNotification == null) return const Drawer(child: SizedBox());
    
    final item = _selectedNotification!;
    
    return Drawer(
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notification Details', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildStatusBadge(item.status, theme),
                      const SizedBox(width: 8),
                      _buildPriorityBadge(item.priority, theme),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(item.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('ID: ${item.id} • ${DateFormat('MMM dd, yyyy HH:mm').format(item.createdTime)}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  const Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(item.message, style: theme.textTheme.bodyMedium),
                  ),
                  const SizedBox(height: 24),
                  
                  _buildDetailRow('Related Module', item.module),
                  _buildDetailRow('Recipient', item.recipient),
                  _buildDetailRow('Channel', item.channel),
                  if (item.readTime != null)
                    _buildDetailRow('Read Time', DateFormat('MMM dd, yyyy HH:mm').format(item.readTime!)),
                  
                  const SizedBox(height: 24),
                  const Text('Delivery Information', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(item.deliveryInfo, style: theme.textTheme.bodyMedium),
                  
                  if (item.attachments.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text('Attachments', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: item.attachments.map((att) => Chip(
                        avatar: const Icon(LucideIcons.file, size: 16),
                        label: Text(att),
                      )).toList(),
                    )
                  ],

                  const SizedBox(height: 24),
                  const Text('Timeline & History', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ...item.history.map((h) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Container(width: 2, height: 40, color: theme.colorScheme.outlineVariant),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(h.status, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(DateFormat('HH:mm:ss').format(h.timestamp), style: theme.textTheme.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(h.description, style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      notifier.deleteItems([item.id]);
                      Navigator.pop(context);
                    },
                    icon: const Icon(LucideIcons.trash2, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Mock Resend
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification resent successfully.')));
                    },
                    icon: const Icon(LucideIcons.send, size: 18),
                    label: const Text('Resend'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color color;
    if (status == 'Read') color = Colors.green;
    else if (status == 'Unread') color = Colors.orange;
    else color = Colors.grey;

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

  Widget _buildPriorityBadge(String priority, ThemeData theme) {
    Color color;
    if (priority == 'Critical') color = Colors.red;
    else if (priority == 'High') color = Colors.orange;
    else if (priority == 'Normal') color = Colors.blue;
    else color = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
