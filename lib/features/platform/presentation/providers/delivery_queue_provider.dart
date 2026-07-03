import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/queue_item_model.dart';

class DeliveryQueueState {
  final List<QueueItem> items;
  final String searchQuery;
  final String selectedStatusFilter;
  final bool autoRefreshEnabled;

  DeliveryQueueState({
    required this.items,
    this.searchQuery = '',
    this.selectedStatusFilter = 'All',
    this.autoRefreshEnabled = true,
  });

  DeliveryQueueState copyWith({
    List<QueueItem>? items,
    String? searchQuery,
    String? selectedStatusFilter,
    bool? autoRefreshEnabled,
  }) {
    return DeliveryQueueState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
    );
  }

  List<QueueItem> get filteredItems {
    return items.where((i) {
      final matchesSearch = i.notificationName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            i.recipient.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            i.id.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = selectedStatusFilter == 'All' || i.status == selectedStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }
}

class DeliveryQueueNotifier extends Notifier<DeliveryQueueState> {
  Timer? _mockTimer;

  @override
  DeliveryQueueState build() {
    ref.onDispose(() {
      _mockTimer?.cancel();
    });
    
    final initialState = DeliveryQueueState(
      items: _generateInitialMockData(),
    );
    
    _startMockSimulation();
    
    return initialState;
  }

  void toggleAutoRefresh(bool value) {
    state = state.copyWith(autoRefreshEnabled: value);
    if (value) {
      _startMockSimulation();
    } else {
      _mockTimer?.cancel();
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatusFilter: status);
  }

  void retryItem(String id) {
    final index = state.items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final updatedList = List<QueueItem>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(
        status: 'Pending',
        retryCount: updatedList[index].retryCount + 1,
      );
      state = state.copyWith(items: updatedList);
    }
  }

  void cancelItem(String id) {
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
  }

  void _startMockSimulation() {
    _mockTimer?.cancel();
    _mockTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!state.autoRefreshEnabled) {
        timer.cancel();
        return;
      }
      
      final currentItems = List<QueueItem>.from(state.items);
      bool hasChanges = false;
      
      // Simulate processing
      for (int i = 0; i < currentItems.length; i++) {
        if (currentItems[i].status == 'Processing') {
          currentItems[i] = currentItems[i].copyWith(status: Random().nextDouble() > 0.1 ? 'Delivered' : 'Failed');
          hasChanges = true;
        } else if (currentItems[i].status == 'Pending' && Random().nextDouble() > 0.5) {
          currentItems[i] = currentItems[i].copyWith(status: 'Processing');
          hasChanges = true;
        } else if (currentItems[i].status == 'Retry Queue' && Random().nextDouble() > 0.7) {
          currentItems[i] = currentItems[i].copyWith(status: 'Pending');
          hasChanges = true;
        }
      }

      // Add a new mock item occasionally
      if (Random().nextDouble() > 0.7) {
        currentItems.insert(0, _generateRandomItem());
        if (currentItems.length > 50) currentItems.removeLast(); // Keep list size manageable
        hasChanges = true;
      }

      if (hasChanges) {
        state = state.copyWith(items: currentItems);
      }
    });
  }

  QueueItem _generateRandomItem() {
    final r = Random();
    return QueueItem(
      id: 'Q-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
      notificationName: ['Welcome Email', 'Password Reset', 'Invoice PDF', 'Maintenance Alert'][r.nextInt(4)],
      recipient: ['user@example.com', '+1234567890', 'john.doe@org.com', 'System Admin'][r.nextInt(4)],
      channel: ['Email', 'SMS', 'Push', 'In-App'][r.nextInt(4)],
      priority: ['Low', 'Normal', 'High', 'Critical'][r.nextInt(4)],
      retryCount: 0,
      status: 'Pending',
      createdAt: DateTime.now(),
    );
  }

  List<QueueItem> _generateInitialMockData() {
    return [
      QueueItem(id: 'Q-928374', notificationName: 'Password Reset', recipient: 'alice@example.com', channel: 'Email', priority: 'High', retryCount: 0, status: 'Processing', createdAt: DateTime.now().subtract(const Duration(seconds: 10))),
      QueueItem(id: 'Q-928375', notificationName: 'Welcome Email', recipient: 'bob@example.com', channel: 'Email', priority: 'Normal', retryCount: 0, status: 'Pending', createdAt: DateTime.now().subtract(const Duration(seconds: 45))),
      QueueItem(id: 'Q-928376', notificationName: 'System Maintenance', recipient: 'All Admins', channel: 'In-App', priority: 'Critical', retryCount: 0, status: 'Delivered', createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
      QueueItem(id: 'Q-928377', notificationName: 'Payment Failed', recipient: '+1987654321', channel: 'SMS', priority: 'High', retryCount: 2, status: 'Failed', createdAt: DateTime.now().subtract(const Duration(hours: 1))),
      QueueItem(id: 'Q-928378', notificationName: 'Monthly Report', recipient: 'finance@org.com', channel: 'Email', priority: 'Low', retryCount: 1, status: 'Retry Queue', createdAt: DateTime.now().subtract(const Duration(minutes: 15))),
    ];
  }
}

final deliveryQueueProvider = NotifierProvider<DeliveryQueueNotifier, DeliveryQueueState>(() {
  return DeliveryQueueNotifier();
});
