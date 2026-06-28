import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/tenant.dart';
import '../../data/mock_tenant_repository.dart';

final tenantRepositoryProvider = Provider<MockTenantRepository>((ref) {
  return MockTenantRepository();
});

class TenantListState {
  final List<Tenant> allTenants;
  final List<Tenant> filteredTenants;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String filterStatus;
  final String sortColumn;
  final bool sortAscending;
  final Set<String> selectedTenantIds;

  TenantListState({
    required this.allTenants,
    required this.filteredTenants,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterStatus = 'All',
    this.sortColumn = 'name',
    this.sortAscending = true,
    required this.selectedTenantIds,
  });

  TenantListState copyWith({
    List<Tenant>? allTenants,
    List<Tenant>? filteredTenants,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? filterStatus,
    String? sortColumn,
    bool? sortAscending,
    Set<String>? selectedTenantIds,
  }) {
    return TenantListState(
      allTenants: allTenants ?? this.allTenants,
      filteredTenants: filteredTenants ?? this.filteredTenants,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      selectedTenantIds: selectedTenantIds ?? this.selectedTenantIds,
    );
  }
}

class TenantListNotifier extends Notifier<TenantListState> {
  @override
  TenantListState build() {
    // Initial fetch
    Future.microtask(() => loadTenants());
    return TenantListState(allTenants: [], filteredTenants: [], selectedTenantIds: {});
  }

  Future<void> loadTenants() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(tenantRepositoryProvider);
      final tenants = await repo.getTenants();
      state = state.copyWith(allTenants: tenants, isLoading: false);
      _applyFiltersAndSort();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFiltersAndSort();
  }

  void setFilterStatus(String status) {
    state = state.copyWith(filterStatus: status, selectedTenantIds: {}); // Clear selection on filter change
    _applyFiltersAndSort();
  }

  void setSort(String column, bool ascending) {
    state = state.copyWith(sortColumn: column, sortAscending: ascending);
    _applyFiltersAndSort();
  }

  void toggleSelection(String id) {
    final selected = Set<String>.from(state.selectedTenantIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    state = state.copyWith(selectedTenantIds: selected);
  }

  void selectAll(bool select) {
    if (select) {
      state = state.copyWith(selectedTenantIds: state.filteredTenants.map((t) => t.id).toSet());
    } else {
      state = state.copyWith(selectedTenantIds: {});
    }
  }

  Future<void> bulkUpdateStatus(String newStatus) async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(tenantRepositoryProvider);
    await repo.updateTenantStatus(state.selectedTenantIds.toList(), newStatus);
    state = state.copyWith(selectedTenantIds: {});
    await loadTenants();
  }

  Future<void> bulkDelete() async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(tenantRepositoryProvider);
    await repo.deleteTenants(state.selectedTenantIds.toList());
    state = state.copyWith(selectedTenantIds: {});
    await loadTenants();
  }

  void _applyFiltersAndSort() {
    List<Tenant> result = List.from(state.allTenants);

    // Apply Search
    if (state.searchQuery.isNotEmpty) {
      final q = state.searchQuery.toLowerCase();
      result = result.where((t) => t.name.toLowerCase().contains(q) || t.code.toLowerCase().contains(q)).toList();
    }

    // Apply Quick Filter
    if (state.filterStatus != 'All') {
      if (['Active', 'Trial', 'Suspended', 'Expired'].contains(state.filterStatus)) {
        result = result.where((t) => t.status == state.filterStatus).toList();
      } else if (state.filterStatus == 'Inactive') {
         result = result.where((t) => t.status == 'Suspended' || t.status == 'Expired').toList();
      } else if (state.filterStatus == 'Paid') {
        result = result.where((t) => t.subscriptionPlan != 'Trial').toList();
      }
    }

    // Apply Sort
    result.sort((a, b) {
      int cmp = 0;
      switch (state.sortColumn) {
        case 'name': cmp = a.name.compareTo(b.name); break;
        case 'code': cmp = a.code.compareTo(b.code); break;
        case 'orgs': cmp = a.organizationCount.compareTo(b.organizationCount); break;
        case 'users': cmp = a.userCount.compareTo(b.userCount); break;
        case 'plan': cmp = a.subscriptionPlan.compareTo(b.subscriptionPlan); break;
        case 'status': cmp = a.status.compareTo(b.status); break;
        case 'created': cmp = a.createdAt.compareTo(b.createdAt); break;
        case 'activity': cmp = a.lastActivity.compareTo(b.lastActivity); break;
      }
      return state.sortAscending ? cmp : -cmp;
    });

    state = state.copyWith(filteredTenants: result);
  }
}

final tenantListProvider = NotifierProvider<TenantListNotifier, TenantListState>(() {
  return TenantListNotifier();
});
