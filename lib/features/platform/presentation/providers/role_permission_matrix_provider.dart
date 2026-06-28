import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/permission.dart';
import '../../domain/models/role.dart';

class MatrixState {
  final List<Role> roles;
  final List<Permission> allPermissions;
  final List<Permission> filteredPermissions;
  final Map<String, Map<String, bool>> grid; // [permissionId][roleId] = bool
  final bool isLoading;
  final bool isSaving;
  final String searchQuery;
  final String selectedCategory;

  const MatrixState({
    this.roles = const [],
    this.allPermissions = const [],
    this.filteredPermissions = const [],
    this.grid = const {},
    this.isLoading = true,
    this.isSaving = false,
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  MatrixState copyWith({
    List<Role>? roles,
    List<Permission>? allPermissions,
    List<Permission>? filteredPermissions,
    Map<String, Map<String, bool>>? grid,
    bool? isLoading,
    bool? isSaving,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return MatrixState(
      roles: roles ?? this.roles,
      allPermissions: allPermissions ?? this.allPermissions,
      filteredPermissions: filteredPermissions ?? this.filteredPermissions,
      grid: grid ?? this.grid,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class RolePermissionMatrixNotifier extends Notifier<MatrixState> {
  bool _initialized = false;

  @override
  MatrixState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => init());
    }
    return const MatrixState(isLoading: true);
  }

  void init() async {
    state = const MatrixState(isLoading: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final mockRoles = _generateMockRoles();
    final mockPermissions = _generateMockPermissions();
    final mockGrid = _generateMockGrid(mockRoles, mockPermissions);
    
    state = state.copyWith(
      roles: mockRoles,
      allPermissions: mockPermissions,
      filteredPermissions: mockPermissions,
      grid: mockGrid,
      isLoading: false,
    );
  }

  void togglePermission(String permissionId, String roleId, bool value) {
    final newGrid = Map<String, Map<String, bool>>.from(state.grid);
    if (!newGrid.containsKey(permissionId)) {
      newGrid[permissionId] = {};
    }
    final newRow = Map<String, bool>.from(newGrid[permissionId]!);
    newRow[roleId] = value;
    newGrid[permissionId] = newRow;

    state = state.copyWith(grid: newGrid);
  }

  Future<void> saveChanges() async {
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(isSaving: false);
  }

  void setSearchQuery(String query) {
    _applyFilters(query, state.selectedCategory);
  }

  void setCategoryFilter(String category) {
    _applyFilters(state.searchQuery, category);
  }

  void _applyFilters(String query, String category) {
    var filtered = state.allPermissions;

    if (category != 'All') {
      filtered = filtered.where((p) => p.category == category).toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(q) || 
        p.code.toLowerCase().contains(q)
      ).toList();
    }

    state = state.copyWith(
      filteredPermissions: filtered,
      searchQuery: query,
      selectedCategory: category,
    );
  }

  List<Role> _generateMockRoles() {
    return [
      Role(id: 'r1', name: 'Platform Admin', code: 'SYS_ADMIN', scope: 'Global', description: '', usersAssigned: 0, permissionCount: 0, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r2', name: 'Tenant Admin', code: 'TEN_ADMIN', scope: 'Tenant', description: '', usersAssigned: 0, permissionCount: 0, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r3', name: 'Org Admin', code: 'ORG_ADMIN', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 0, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r4', name: 'Sales Manager', code: 'SALES_MGR', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 0, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r5', name: 'HR Manager', code: 'HR_MGR', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 0, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r6', name: 'Finance Controller', code: 'FIN_CTRL', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 0, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r7', name: 'Support Agent', code: 'SUP_AGENT', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 0, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r8', name: 'Employee (Base)', code: 'EMP_BASE', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 0, status: 'Active', createdDate: DateTime.now()),
    ];
  }

  List<Permission> _generateMockPermissions() {
    final categories = ['Identity', 'Users', 'Reports', 'Sales', 'Finance', 'Inventory', 'System'];
    final actions = ['View', 'Create', 'Update', 'Delete', 'Export'];
    
    final List<Permission> perms = [];
    int idCounter = 1;

    for (var category in categories) {
      for (var action in actions) {
        perms.add(Permission(
          id: 'p_$idCounter',
          code: '${category.toUpperCase()}_${action.toUpperCase()}',
          name: '$action $category',
          module: 'Platform',
          category: category,
          description: 'Allows $action on $category',
          assignedRolesCount: 0,
          status: 'Active',
          createdDate: DateTime.now(),
        ));
        idCounter++;
      }
    }
    return perms;
  }

  Map<String, Map<String, bool>> _generateMockGrid(List<Role> roles, List<Permission> perms) {
    final random = Random(123);
    final grid = <String, Map<String, bool>>{};

    for (var p in perms) {
      grid[p.id] = {};
      for (var r in roles) {
        if (r.code == 'SYS_ADMIN') {
          grid[p.id]![r.id] = true;
        } else if (r.code == 'EMP_BASE') {
          grid[p.id]![r.id] = p.name.contains('View') && random.nextDouble() > 0.5;
        } else {
          grid[p.id]![r.id] = random.nextDouble() > 0.6;
        }
      }
    }
    return grid;
  }
}

final rolePermissionMatrixProvider = NotifierProvider<RolePermissionMatrixNotifier, MatrixState>(
  RolePermissionMatrixNotifier.new,
);
