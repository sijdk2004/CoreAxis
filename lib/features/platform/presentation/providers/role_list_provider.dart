import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/role.dart';

class RoleListState {
  final List<Role> allRoles;
  final List<Role> filteredRoles;
  final Set<String> selectedRoleIds;
  final bool isLoading;
  final String searchQuery;
  final String selectedFilter; // 'All', 'Platform Roles', 'Tenant Roles', 'System Roles', 'Custom Roles', 'Active', 'Inactive'
  
  const RoleListState({
    this.allRoles = const [],
    this.filteredRoles = const [],
    this.selectedRoleIds = const {},
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedFilter = 'All',
  });

  RoleListState copyWith({
    List<Role>? allRoles,
    List<Role>? filteredRoles,
    Set<String>? selectedRoleIds,
    bool? isLoading,
    String? searchQuery,
    String? selectedFilter,
  }) {
    return RoleListState(
      allRoles: allRoles ?? this.allRoles,
      filteredRoles: filteredRoles ?? this.filteredRoles,
      selectedRoleIds: selectedRoleIds ?? this.selectedRoleIds,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class RoleListNotifier extends Notifier<RoleListState> {
  bool _initialized = false;

  @override
  RoleListState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => init());
    }
    return const RoleListState(isLoading: true);
  }

  void init() async {
    state = const RoleListState(isLoading: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final mockRoles = _generateMockRoles();
    
    state = state.copyWith(
      allRoles: mockRoles,
      isLoading: false,
    );
    _applyFilters();
  }

  List<Role> _generateMockRoles() {
    final random = Random(123);
    
    final predefined = [
      Role(id: 'r_1', name: 'Platform Administrator', code: 'PLATFORM_ADMIN', scope: 'System', description: 'Full access to all platform features and tenants.', usersAssigned: 5, permissionCount: 250, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 365))),
      Role(id: 'r_2', name: 'Platform Support', code: 'PLATFORM_SUPPORT', scope: 'System', description: 'Read-only access across tenants for troubleshooting.', usersAssigned: 12, permissionCount: 85, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 300))),
      Role(id: 'r_3', name: 'Implementation Consultant', code: 'IMPL_CONSULTANT', scope: 'Platform', description: 'Setup and configure new tenant environments.', usersAssigned: 8, permissionCount: 150, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 250))),
      Role(id: 'r_4', name: 'Auditor', code: 'AUDITOR', scope: 'Platform', description: 'Access to platform audit logs and compliance reports.', usersAssigned: 3, permissionCount: 45, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 200))),
      
      Role(id: 'r_5', name: 'Tenant Admin', code: 'TENANT_ADMIN', scope: 'System', description: 'Full access to a specific tenant environment.', usersAssigned: 145, permissionCount: 180, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 365))),
      Role(id: 'r_6', name: 'Sales Manager', code: 'SALES_MGR', scope: 'Tenant', description: 'Manage sales pipelines, quotes, and sales representatives.', usersAssigned: 450, permissionCount: 95, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 350))),
      Role(id: 'r_7', name: 'Production Manager', code: 'PROD_MGR', scope: 'Tenant', description: 'Manage manufacturing processes and shop floor operations.', usersAssigned: 320, permissionCount: 88, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 340))),
      Role(id: 'r_8', name: 'Purchase Manager', code: 'PURCHASE_MGR', scope: 'Tenant', description: 'Manage procurement, vendors, and purchase orders.', usersAssigned: 280, permissionCount: 92, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 330))),
      Role(id: 'r_9', name: 'Inventory Manager', code: 'INV_MGR', scope: 'Tenant', description: 'Manage warehouses, stock movements, and inventory valuation.', usersAssigned: 410, permissionCount: 105, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 320))),
      Role(id: 'r_10', name: 'Finance Manager', code: 'FIN_MGR', scope: 'Tenant', description: 'Manage accounting, invoicing, and financial reporting.', usersAssigned: 180, permissionCount: 140, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 310))),
      Role(id: 'r_11', name: 'HR Manager', code: 'HR_MGR', scope: 'Tenant', description: 'Manage employee records, payroll, and recruitment.', usersAssigned: 150, permissionCount: 110, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 300))),
      Role(id: 'r_12', name: 'Employee', code: 'EMPLOYEE', scope: 'System', description: 'Base access for all users in a tenant.', usersAssigned: 4500, permissionCount: 15, status: 'Active', createdDate: DateTime.now().subtract(const Duration(days: 365))),
    ];

    // Add some random custom roles
    final customNames = ['Approver', 'Reviewer', 'Coordinator'];
    for (int i = 0; i < 8; i++) {
      predefined.add(Role(
        id: 'r_custom_$i',
        name: 'Custom ${customNames[random.nextInt(3)]} $i',
        code: 'CUSTOM_ROLE_$i',
        scope: 'Custom',
        description: 'A custom role created for specific tenant needs.',
        usersAssigned: random.nextInt(50),
        permissionCount: random.nextInt(60) + 10,
        status: random.nextBool() ? 'Active' : 'Inactive',
        createdDate: DateTime.now().subtract(Duration(days: random.nextInt(200))),
      ));
    }

    return predefined;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, selectedRoleIds: {}); // Clear selection on search
    _applyFilters();
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter, selectedRoleIds: {}); // Clear selection on filter change
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List<Role>.from(state.allRoles);

    // Apply Filter Tab
    if (state.selectedFilter != 'All') {
      if (state.selectedFilter == 'Active' || state.selectedFilter == 'Inactive') {
        filtered = filtered.where((r) => r.status == state.selectedFilter).toList();
      } else if (state.selectedFilter == 'Platform Roles') {
        filtered = filtered.where((r) => r.scope == 'Platform').toList();
      } else if (state.selectedFilter == 'Tenant Roles') {
        filtered = filtered.where((r) => r.scope == 'Tenant').toList();
      } else if (state.selectedFilter == 'System Roles') {
        filtered = filtered.where((r) => r.scope == 'System').toList();
      } else if (state.selectedFilter == 'Custom Roles') {
        filtered = filtered.where((r) => r.scope == 'Custom').toList();
      }
    }

    // Apply Search
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((r) =>
        r.name.toLowerCase().contains(query) ||
        r.code.toLowerCase().contains(query) ||
        r.description.toLowerCase().contains(query)
      ).toList();
    }

    state = state.copyWith(filteredRoles: filtered);
  }

  // --- Actions ---

  void toggleRoleSelection(String id, bool selected) {
    final updatedIds = Set<String>.from(state.selectedRoleIds);
    if (selected) {
      updatedIds.add(id);
    } else {
      updatedIds.remove(id);
    }
    state = state.copyWith(selectedRoleIds: updatedIds);
  }

  void selectAll(bool selected) {
    if (selected) {
      state = state.copyWith(selectedRoleIds: state.filteredRoles.map((r) => r.id).toSet());
    } else {
      state = state.copyWith(selectedRoleIds: {});
    }
  }

  void activateRole(String id) {
    _updateStatus([id], 'Active');
  }

  void deactivateRole(String id) {
    _updateStatus([id], 'Inactive');
  }

  void deleteRole(String id) {
    final updated = state.allRoles.where((r) => r.id != id).toList();
    state = state.copyWith(allRoles: updated);
    _applyFilters();
  }

  void bulkUpdateStatus(String newStatus) {
    _updateStatus(state.selectedRoleIds.toList(), newStatus);
    state = state.copyWith(selectedRoleIds: {}); // Clear selection after bulk action
  }
  
  void bulkDelete() {
    final updated = state.allRoles.where((r) => !state.selectedRoleIds.contains(r.id)).toList();
    state = state.copyWith(allRoles: updated, selectedRoleIds: {});
    _applyFilters();
  }

  void _updateStatus(List<String> ids, String newStatus) {
    final updated = state.allRoles.map((r) {
      if (ids.contains(r.id)) {
        return r.copyWith(status: newStatus);
      }
      return r;
    }).toList();
    state = state.copyWith(allRoles: updated);
    _applyFilters();
  }
}

final roleListProvider = NotifierProvider<RoleListNotifier, RoleListState>(
  RoleListNotifier.new,
);
