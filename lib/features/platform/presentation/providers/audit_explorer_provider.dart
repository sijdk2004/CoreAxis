import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/audit_explorer_model.dart';

class AuditExplorerState {
  final List<AuditExplorerItem> items;
  final String searchQuery;
  final String selectedFilter;
  final String viewMode; // 'table', 'card', 'timeline'

  const AuditExplorerState({
    this.items = const [],
    this.searchQuery = '',
    this.selectedFilter = 'All',
    this.viewMode = 'table',
  });

  AuditExplorerState copyWith({
    List<AuditExplorerItem>? items,
    String? searchQuery,
    String? selectedFilter,
    String? viewMode,
  }) {
    return AuditExplorerState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

final auditExplorerProvider = AsyncNotifierProvider<AuditExplorerNotifier, AuditExplorerState>(() {
  return AuditExplorerNotifier();
});

class AuditExplorerNotifier extends AsyncNotifier<AuditExplorerState> {
  late List<AuditExplorerItem> _allItems;

  @override
  FutureOr<AuditExplorerState> build() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _allItems = generateMockAuditExplorerItems();
    return AuditExplorerState(items: _allItems);
  }

  void setSearchQuery(String query) {
    if (state.value == null) return;
    
    final current = state.value!;
    final filtered = _allItems.where((item) {
      final matchesSearch = query.isEmpty || 
          item.id.toLowerCase().contains(query.toLowerCase()) ||
          item.user.toLowerCase().contains(query.toLowerCase()) ||
          item.module.toLowerCase().contains(query.toLowerCase()) ||
          item.action.toLowerCase().contains(query.toLowerCase());
      
      final matchesFilter = current.selectedFilter == 'All' || 
                            item.severity.toLowerCase() == current.selectedFilter.toLowerCase() ||
                            item.module.toLowerCase() == current.selectedFilter.toLowerCase();
                            
      return matchesSearch && matchesFilter;
    }).toList();
    
    state = AsyncValue.data(current.copyWith(
      searchQuery: query,
      items: filtered,
    ));
  }

  void setFilter(String filter) {
    if (state.value == null) return;
    
    final current = state.value!;
    final filtered = _allItems.where((item) {
      final matchesSearch = current.searchQuery.isEmpty || 
          item.id.toLowerCase().contains(current.searchQuery.toLowerCase()) ||
          item.user.toLowerCase().contains(current.searchQuery.toLowerCase()) ||
          item.module.toLowerCase().contains(current.searchQuery.toLowerCase()) ||
          item.action.toLowerCase().contains(current.searchQuery.toLowerCase());
      
      final matchesFilter = filter == 'All' || 
                            item.severity.toLowerCase() == filter.toLowerCase() ||
                            item.module.toLowerCase() == filter.toLowerCase();
                            
      return matchesSearch && matchesFilter;
    }).toList();
    
    state = AsyncValue.data(current.copyWith(
      selectedFilter: filter,
      items: filtered,
    ));
  }

  void setViewMode(String mode) {
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(viewMode: mode));
  }
}
