import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/permission.dart';

class PermissionListState {
  final List<Permission> allPermissions;
  final List<Permission> filteredPermissions;
  final bool isLoading;
  final String searchQuery;
  final String selectedCategory;

  // KPIs
  final int totalPermissions;
  final int platformPermissions;
  final int industryPermissions;
  final int assignedPermissions;

  const PermissionListState({
    this.allPermissions = const [],
    this.filteredPermissions = const [],
    this.isLoading = true,
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.totalPermissions = 0,
    this.platformPermissions = 0,
    this.industryPermissions = 0,
    this.assignedPermissions = 0,
  });

  PermissionListState copyWith({
    List<Permission>? allPermissions,
    List<Permission>? filteredPermissions,
    bool? isLoading,
    String? searchQuery,
    String? selectedCategory,
    int? totalPermissions,
    int? platformPermissions,
    int? industryPermissions,
    int? assignedPermissions,
  }) {
    return PermissionListState(
      allPermissions: allPermissions ?? this.allPermissions,
      filteredPermissions: filteredPermissions ?? this.filteredPermissions,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      totalPermissions: totalPermissions ?? this.totalPermissions,
      platformPermissions: platformPermissions ?? this.platformPermissions,
      industryPermissions: industryPermissions ?? this.industryPermissions,
      assignedPermissions: assignedPermissions ?? this.assignedPermissions,
    );
  }
}

class PermissionListNotifier extends Notifier<PermissionListState> {
  bool _initialized = false;

  @override
  PermissionListState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => init());
    }
    return const PermissionListState(isLoading: true);
  }

  void init() async {
    state = const PermissionListState(isLoading: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final mockPermissions = _generateMockPermissions();
    
    _updateStateWithFilters(mockPermissions, '', 'All');
  }

  void setSearchQuery(String query) {
    _updateStateWithFilters(state.allPermissions, query, state.selectedCategory);
  }

  void setCategoryFilter(String category) {
    _updateStateWithFilters(state.allPermissions, state.searchQuery, category);
  }

  void refresh() {
    init();
  }

  void _updateStateWithFilters(List<Permission> allPerms, String query, String category) {
    var filtered = allPerms;

    if (category != 'All') {
      filtered = filtered.where((p) => p.category == category).toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(q) || 
        p.code.toLowerCase().contains(q) || 
        p.description.toLowerCase().contains(q)
      ).toList();
    }

    final platformCategories = [
      'Identity', 'Tenant', 'Organization', 'User', 'Role', 
      'Workflow', 'Approval', 'Notification', 'Documents', 
      'Reports', 'Audit', 'AI'
    ];

    final platformCount = allPerms.where((p) => platformCategories.contains(p.category)).length;
    final industryCount = allPerms.length - platformCount;
    final assignedCount = allPerms.where((p) => p.assignedRolesCount > 0).length;

    state = state.copyWith(
      allPermissions: allPerms,
      filteredPermissions: filtered,
      searchQuery: query,
      selectedCategory: category,
      isLoading: false,
      totalPermissions: allPerms.length,
      platformPermissions: platformCount,
      industryPermissions: industryCount,
      assignedPermissions: assignedCount,
    );
  }

  List<Permission> _generateMockPermissions() {
    final random = Random(42);
    final platformCategories = [
      'Identity', 'Tenant', 'Organization', 'User', 'Role', 
      'Workflow', 'Approval', 'Notification', 'Documents', 
      'Reports', 'Audit', 'AI'
    ];
    final industryCategories = [
      'Furniture', 'Garments', 'Steel', 'Inventory', 
      'Production', 'Sales', 'Finance'
    ];
    
    final allCategories = [...platformCategories, ...industryCategories];
    final actions = ['View', 'Create', 'Update', 'Delete', 'Approve', 'Reject', 'Export', 'Import', 'Execute'];
    
    final List<Permission> perms = [];
    int idCounter = 1;

    for (var category in allCategories) {
      final numPerms = random.nextInt(6) + 4; // 4 to 9 perms per category
      for (int i = 0; i < numPerms; i++) {
        final action = actions[random.nextInt(actions.length)];
        final module = platformCategories.contains(category) ? 'Platform' : 'Industry Packs';
        final codeName = category.toUpperCase().replaceAll(' ', '_');
        final actionName = action.toUpperCase();
        
        perms.add(Permission(
          id: 'perm_$idCounter',
          code: '${module.substring(0,3).toUpperCase()}_${codeName}_$actionName',
          name: '$action $category',
          module: module,
          category: category,
          description: 'Allows the user to perform $action operations on $category entities.',
          assignedRolesCount: random.nextDouble() > 0.3 ? random.nextInt(15) + 1 : 0,
          status: random.nextDouble() > 0.1 ? 'Active' : 'Deprecated',
          createdDate: DateTime.now().subtract(Duration(days: random.nextInt(365))),
        ));
        idCounter++;
      }
    }

    return perms;
  }
}

final permissionListProvider = NotifierProvider<PermissionListNotifier, PermissionListState>(
  PermissionListNotifier.new,
);
