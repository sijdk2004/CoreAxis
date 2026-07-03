import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/notification_center_model.dart';
import 'dart:math';

class NotificationCenterState {
  final List<NotificationMessage> allItems;
  final String searchQuery;
  final String activeFilter; // 'All', 'Unread', 'Read', 'High Priority', 'Workflow', 'Approval', 'System', etc.
  final NotificationViewType viewType;
  final Set<String> selectedIds;
  final bool isLoading;

  NotificationCenterState({
    required this.allItems,
    this.searchQuery = '',
    this.activeFilter = 'All',
    this.viewType = NotificationViewType.table,
    this.selectedIds = const {},
    this.isLoading = false,
  });

  NotificationCenterState copyWith({
    List<NotificationMessage>? allItems,
    String? searchQuery,
    String? activeFilter,
    NotificationViewType? viewType,
    Set<String>? selectedIds,
    bool? isLoading,
  }) {
    return NotificationCenterState(
      allItems: allItems ?? this.allItems,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilter: activeFilter ?? this.activeFilter,
      viewType: viewType ?? this.viewType,
      selectedIds: selectedIds ?? this.selectedIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<NotificationMessage> get filteredItems {
    return allItems.where((item) {
      // 1. Search Query
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!item.title.toLowerCase().contains(query) &&
            !item.message.toLowerCase().contains(query) &&
            !item.id.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 2. Active Filter
      switch (activeFilter) {
        case 'Unread':
          if (item.status != 'Unread') return false;
          break;
        case 'Read':
          if (item.status != 'Read') return false;
          break;
        case 'High Priority':
          if (item.priority != 'High') return false;
          break;
        case 'Workflow':
        case 'Approval':
        case 'System':
        case 'Finance':
        case 'Production':
        case 'Inventory':
          if (item.module != activeFilter) return false;
          break;
        case 'All':
        default:
          break;
      }
      return true;
    }).toList();
  }
}

class NotificationCenterNotifier extends Notifier<NotificationCenterState> {
  @override
  NotificationCenterState build() {
    return NotificationCenterState(allItems: _generateMockData());
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, selectedIds: {});
  }

  void setActiveFilter(String filter) {
    state = state.copyWith(activeFilter: filter, selectedIds: {});
  }

  void setViewType(NotificationViewType type) {
    state = state.copyWith(viewType: type);
  }

  void toggleSelection(String id) {
    final newSelection = Set<String>.from(state.selectedIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    state = state.copyWith(selectedIds: newSelection);
  }

  void toggleSelectAll() {
    final filtered = state.filteredItems;
    if (state.selectedIds.length == filtered.length) {
      state = state.copyWith(selectedIds: {});
    } else {
      state = state.copyWith(selectedIds: filtered.map((e) => e.id).toSet());
    }
  }

  void markAsRead(List<String> ids) {
    final updated = state.allItems.map((e) {
      if (ids.contains(e.id) && e.status == 'Unread') {
        return e.copyWith(status: 'Read', readTime: DateTime.now());
      }
      return e;
    }).toList();
    state = state.copyWith(allItems: updated, selectedIds: {});
  }

  void archiveItems(List<String> ids) {
    // Mock archiving: we just delete from the main list for now
    deleteItems(ids);
  }

  void deleteItems(List<String> ids) {
    final updated = state.allItems.where((e) => !ids.contains(e.id)).toList();
    state = state.copyWith(allItems: updated, selectedIds: {});
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    // Prepend a new notification
    final newItem = _generateSingleMock(state.allItems.length + 1000);
    state = state.copyWith(
      allItems: [newItem, ...state.allItems],
      isLoading: false,
    );
  }

  List<NotificationMessage> _generateMockData() {
    final rand = Random();
    return List.generate(45, (index) => _generateSingleMock(1000 + index, rand: rand));
  }

  NotificationMessage _generateSingleMock(int idSequence, {Random? rand}) {
    final r = rand ?? Random();
    final modules = ['Workflow', 'Approval', 'System', 'Finance', 'Production', 'Inventory'];
    final channels = ['Email', 'Push', 'SMS', 'In-App'];
    final priorities = ['Low', 'Normal', 'High', 'Critical'];
    
    final module = modules[r.nextInt(modules.length)];
    final priority = priorities[r.nextInt(priorities.length)];
    final isUnread = r.nextDouble() > 0.6;
    final created = DateTime.now().subtract(Duration(hours: r.nextInt(120), minutes: r.nextInt(60)));
    
    String title = '';
    String msg = '';
    switch (module) {
      case 'Workflow':
        title = 'Task Assigned: Review Document';
        msg = 'You have been assigned to review the quarterly financial report.';
        break;
      case 'Approval':
        title = 'PO-2023-${r.nextInt(9000)+1000} Requires Approval';
        msg = 'Purchase order from IT department is pending your final sign-off.';
        break;
      case 'System':
        title = 'Scheduled Maintenance Alert';
        msg = 'The system will undergo scheduled maintenance at 02:00 AM UTC.';
        break;
      case 'Finance':
        title = 'Invoice #INV-${r.nextInt(5000)} Overdue';
        msg = 'Payment for the Acme Corp invoice is now 5 days overdue.';
        break;
      case 'Production':
        title = 'Line 4 Stopped Unexpectedly';
        msg = 'Sensors detect a fault in conveyor belt motor on Line 4.';
        break;
      case 'Inventory':
        title = 'Low Stock Warning: Part A34';
        msg = 'Inventory levels for Part A34 have fallen below the minimum threshold.';
        break;
    }

    return NotificationMessage(
      id: 'MSG-$idSequence',
      title: title,
      message: msg,
      module: module,
      recipient: 'current_user@example.com',
      channel: channels[r.nextInt(channels.length)],
      priority: priority,
      status: isUnread ? 'Unread' : 'Read',
      createdTime: created,
      readTime: isUnread ? null : created.add(Duration(minutes: r.nextInt(120) + 1)),
      attachments: r.nextDouble() > 0.8 ? ['report.pdf'] : [],
      deliveryInfo: 'Delivered to SMTP gateway successfully.',
      history: [
        NotificationHistoryEvent(created, 'Created', 'Message generated by $module module.'),
        NotificationHistoryEvent(created.add(const Duration(seconds: 2)), 'Sent', 'Dispatched via provider.'),
        if (!isUnread)
          NotificationHistoryEvent(created.add(Duration(minutes: r.nextInt(120) + 1)), 'Read', 'User opened the message.'),
      ]
    );
  }
}

final notificationCenterProvider = NotifierProvider<NotificationCenterNotifier, NotificationCenterState>(() {
  return NotificationCenterNotifier();
});
