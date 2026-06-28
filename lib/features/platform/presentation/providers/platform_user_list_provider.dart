import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/platform_user.dart';
import '../../data/mock_platform_user_repository.dart';

final platformUserRepositoryProvider = Provider<MockPlatformUserRepository>((ref) {
  return MockPlatformUserRepository();
});

class PlatformUserListState {
  final List<PlatformUser> allUsers;
  final List<PlatformUser> filteredUsers;
  final bool isLoading;
  final String? error;
  
  final String searchQuery;
  final String filterStatus; // 'All', 'Active', 'Inactive', 'Locked', 'Pending'
  final String filterMfa; // 'All', 'Enabled', 'Disabled'
  
  final String sortColumn;
  final bool sortAscending;
  final Set<String> selectedUserIds;

  PlatformUserListState({
    required this.allUsers,
    required this.filteredUsers,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filterStatus = 'All',
    this.filterMfa = 'All',
    this.sortColumn = 'name',
    this.sortAscending = true,
    required this.selectedUserIds,
  });

  PlatformUserListState copyWith({
    List<PlatformUser>? allUsers,
    List<PlatformUser>? filteredUsers,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? filterStatus,
    String? filterMfa,
    String? sortColumn,
    bool? sortAscending,
    Set<String>? selectedUserIds,
  }) {
    return PlatformUserListState(
      allUsers: allUsers ?? this.allUsers,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
      filterMfa: filterMfa ?? this.filterMfa,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
    );
  }
}

class PlatformUserListNotifier extends Notifier<PlatformUserListState> {
  @override
  PlatformUserListState build() {
    Future.microtask(() => loadUsers());
    return PlatformUserListState(allUsers: [], filteredUsers: [], selectedUserIds: {});
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(platformUserRepositoryProvider);
      final users = await repo.getUsers();
      state = state.copyWith(allUsers: users, isLoading: false);
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
    state = state.copyWith(filterStatus: status, selectedUserIds: {});
    _applyFiltersAndSort();
  }

  void setFilterMfa(String mfaStatus) {
    state = state.copyWith(filterMfa: mfaStatus, selectedUserIds: {});
    _applyFiltersAndSort();
  }

  void setSort(String column, bool ascending) {
    state = state.copyWith(sortColumn: column, sortAscending: ascending);
    _applyFiltersAndSort();
  }

  void toggleSelection(String id) {
    final selected = Set<String>.from(state.selectedUserIds);
    if (selected.contains(id)) {
      selected.remove(id);
    } else {
      selected.add(id);
    }
    state = state.copyWith(selectedUserIds: selected);
  }
  
  void selectAll(bool select) {
    if (select) {
      state = state.copyWith(
        selectedUserIds: state.filteredUsers.map((e) => e.id).toSet()
      );
    } else {
      state = state.copyWith(selectedUserIds: {});
    }
  }

  void _applyFiltersAndSort() {
    List<PlatformUser> result = List.from(state.allUsers);

    // Filter by Status
    if (state.filterStatus != 'All') {
      final statusEnum = PlatformUserStatus.values.firstWhere(
          (e) => e.name.toLowerCase() == state.filterStatus.toLowerCase(),
          orElse: () => PlatformUserStatus.active);
      result = result.where((u) => u.status == statusEnum).toList();
    }
    
    // Filter by MFA
    if (state.filterMfa != 'All') {
      final mfaRequired = state.filterMfa == 'Enabled';
      result = result.where((u) => u.isMfaEnabled == mfaRequired).toList();
    }

    // Filter by Search Query
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      result = result.where((u) => 
        u.fullName.toLowerCase().contains(query) || 
        u.email.toLowerCase().contains(query) ||
        u.employeeId.toLowerCase().contains(query) ||
        (u.organizationName ?? '').toLowerCase().contains(query)
      ).toList();
    }

    // Sort
    result.sort((a, b) {
      int cmp = 0;
      switch (state.sortColumn) {
        case 'name':
          cmp = a.fullName.compareTo(b.fullName);
          break;
        case 'email':
          cmp = a.email.compareTo(b.email);
          break;
        case 'employeeId':
          cmp = a.employeeId.compareTo(b.employeeId);
          break;
        case 'role':
          cmp = a.role.name.compareTo(b.role.name);
          break;
        case 'organization':
          cmp = (a.organizationName ?? '').compareTo(b.organizationName ?? '');
          break;
        case 'lastLogin':
          if (a.lastLogin == null && b.lastLogin == null) cmp = 0;
          else if (a.lastLogin == null) cmp = -1;
          else if (b.lastLogin == null) cmp = 1;
          else cmp = a.lastLogin!.compareTo(b.lastLogin!);
          break;
        default:
          cmp = a.fullName.compareTo(b.fullName);
      }
      return state.sortAscending ? cmp : -cmp;
    });

    // Cleanup selection: remove selected items that are no longer in the filtered list
    final filteredIds = result.map((e) => e.id).toSet();
    final newSelection = state.selectedUserIds.intersection(filteredIds);

    state = state.copyWith(
      filteredUsers: result,
      selectedUserIds: newSelection,
    );
  }

  // Actions
  Future<void> updateStatus(String id, PlatformUserStatus status) async {
    state = state.copyWith(isLoading: true);
    await ref.read(platformUserRepositoryProvider).updateUserStatus(id, status);
    await loadUsers(); // reload
  }

  Future<void> bulkUpdateStatus(PlatformUserStatus status) async {
    if (state.selectedUserIds.isEmpty) return;
    state = state.copyWith(isLoading: true);
    await ref.read(platformUserRepositoryProvider).bulkUpdateStatus(state.selectedUserIds.toList(), status);
    await loadUsers();
  }

  Future<void> bulkDelete() async {
    if (state.selectedUserIds.isEmpty) return;
    state = state.copyWith(isLoading: true);
    await ref.read(platformUserRepositoryProvider).deleteUsers(state.selectedUserIds.toList());
    await loadUsers();
  }
}

final platformUserListProvider = NotifierProvider<PlatformUserListNotifier, PlatformUserListState>(() {
  return PlatformUserListNotifier();
});
