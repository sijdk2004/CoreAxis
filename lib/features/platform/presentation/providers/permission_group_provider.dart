import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/permission_group.dart';

class PermissionGroupState {
  final List<PermissionGroup> groups;
  final List<PermissionGroup> filteredGroups;
  final bool isLoading;
  final String searchQuery;
  final String filterStatus;

  const PermissionGroupState({
    this.groups = const [],
    this.filteredGroups = const [],
    this.isLoading = true,
    this.searchQuery = '',
    this.filterStatus = 'All',
  });

  PermissionGroupState copyWith({
    List<PermissionGroup>? groups,
    List<PermissionGroup>? filteredGroups,
    bool? isLoading,
    String? searchQuery,
    String? filterStatus,
  }) {
    return PermissionGroupState(
      groups: groups ?? this.groups,
      filteredGroups: filteredGroups ?? this.filteredGroups,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

class PermissionGroupNotifier extends Notifier<PermissionGroupState> {
  bool _initialized = false;

  @override
  PermissionGroupState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => init());
    }
    return const PermissionGroupState(isLoading: true);
  }

  void init() async {
    state = const PermissionGroupState(isLoading: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final initialGroups = _generateMockGroups();
    
    state = state.copyWith(
      groups: initialGroups,
      filteredGroups: initialGroups,
      isLoading: false,
    );
  }

  void setSearchQuery(String query) {
    _applyFilters(query, state.filterStatus);
  }

  void setFilterStatus(String status) {
    _applyFilters(state.searchQuery, status);
  }

  void _applyFilters(String query, String status) {
    var filtered = state.groups;

    if (status != 'All') {
      filtered = filtered.where((g) => g.status == status).toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((g) => 
        g.name.toLowerCase().contains(q) || 
        g.description.toLowerCase().contains(q)
      ).toList();
    }

    state = state.copyWith(
      filteredGroups: filtered,
      searchQuery: query,
      filterStatus: status,
    );
  }

  void addGroup(PermissionGroup group) {
    final newGroups = [...state.groups, group];
    state = state.copyWith(groups: newGroups);
    _applyFilters(state.searchQuery, state.filterStatus);
  }

  void updateGroup(PermissionGroup updatedGroup) {
    final index = state.groups.indexWhere((g) => g.id == updatedGroup.id);
    if (index != -1) {
      final newGroups = [...state.groups];
      newGroups[index] = updatedGroup;
      state = state.copyWith(groups: newGroups);
      _applyFilters(state.searchQuery, state.filterStatus);
    }
  }

  void deleteGroup(String id) {
    final newGroups = state.groups.where((g) => g.id != id).toList();
    state = state.copyWith(groups: newGroups);
    _applyFilters(state.searchQuery, state.filterStatus);
  }

  List<PermissionGroup> _generateMockGroups() {
    final groupNames = [
      'Identity', 'Tenant', 'Organization', 'Workflow', 'Approval', 
      'Documents', 'Reports', 'Audit', 'AI', 'Furniture ERP', 
      'Inventory', 'Production', 'Sales', 'Finance'
    ];

    return List.generate(groupNames.length, (index) {
      final name = groupNames[index];
      return PermissionGroup(
        id: 'pg_$index',
        name: name,
        description: 'Permissions related to $name module and features.',
        permissionCount: 10 + (index * 3) % 45,
        assignedRolesCount: 2 + (index % 5),
        status: index % 7 == 0 ? 'Inactive' : 'Active', // 1 in 7 inactive
        createdDate: DateTime.now().subtract(Duration(days: index * 10)),
        mockTopPermissions: [
          '${name.toUpperCase()}_VIEW',
          '${name.toUpperCase()}_CREATE',
          '${name.toUpperCase()}_UPDATE',
          '${name.toUpperCase()}_DELETE',
          '${name.toUpperCase()}_EXPORT',
        ],
      );
    });
  }
}

final permissionGroupProvider = NotifierProvider<PermissionGroupNotifier, PermissionGroupState>(
  PermissionGroupNotifier.new,
);
