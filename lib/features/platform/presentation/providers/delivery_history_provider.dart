import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/delivery_history_model.dart';
import 'dart:math';

enum HistoryViewMode { table, card, timeline }

class DeliveryHistoryState {
  final List<DeliveryHistoryItem> items;
  final String searchQuery;
  final String selectedStatusFilter;
  final HistoryViewMode viewMode;

  DeliveryHistoryState({
    required this.items,
    this.searchQuery = '',
    this.selectedStatusFilter = 'All',
    this.viewMode = HistoryViewMode.table,
  });

  DeliveryHistoryState copyWith({
    List<DeliveryHistoryItem>? items,
    String? searchQuery,
    String? selectedStatusFilter,
    HistoryViewMode? viewMode,
  }) {
    return DeliveryHistoryState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  List<DeliveryHistoryItem> get filteredItems {
    return items.where((i) {
      final matchesSearch = i.notificationName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            i.recipient.toLowerCase().contains(searchQuery.toLowerCase()) ||
                            i.id.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesStatus = selectedStatusFilter == 'All' || i.status == selectedStatusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }
}

class DeliveryHistoryNotifier extends Notifier<DeliveryHistoryState> {
  @override
  DeliveryHistoryState build() {
    return DeliveryHistoryState(
      items: _generateMockHistoryData(),
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatusFilter: status);
  }

  void setViewMode(HistoryViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  List<DeliveryHistoryItem> _generateMockHistoryData() {
    final List<DeliveryHistoryItem> list = [];
    final r = Random();
    
    final names = ['Welcome Email', 'Password Reset', 'Invoice PDF', 'Maintenance Alert', 'Weekly Digest', 'Login OTP'];
    final recipients = ['alice@example.com', 'bob@example.com', 'charlie@org.com', '+1234567890', '+1987654321', 'admin@system.io'];
    final channels = ['Email', 'Email', 'Email', 'Push', 'Email', 'SMS'];
    final statuses = ['Delivered', 'Read', 'Failed', 'Unread'];
    final providers = ['SendGrid', 'Twilio', 'Firebase', 'Internal'];

    for (int i = 0; i < 50; i++) {
      final status = statuses[r.nextInt(statuses.length)];
      final isRead = status == 'Read';
      final deliveredAt = DateTime.now().subtract(Duration(hours: r.nextInt(100), minutes: r.nextInt(60)));
      
      list.add(DeliveryHistoryItem(
        id: 'DH-${1000 + i}',
        notificationName: names[r.nextInt(names.length)],
        recipient: recipients[r.nextInt(recipients.length)],
        channel: channels[r.nextInt(channels.length)],
        deliveredAt: deliveredAt,
        readAt: isRead ? deliveredAt.add(Duration(minutes: r.nextInt(120))) : null,
        status: status,
        provider: providers[r.nextInt(providers.length)],
        duration: Duration(milliseconds: 100 + r.nextInt(1500)),
      ));
    }
    
    // Sort descending by delivery time
    list.sort((a, b) => b.deliveredAt.compareTo(a.deliveredAt));
    return list;
  }
}

final deliveryHistoryProvider = NotifierProvider<DeliveryHistoryNotifier, DeliveryHistoryState>(() {
  return DeliveryHistoryNotifier();
});
