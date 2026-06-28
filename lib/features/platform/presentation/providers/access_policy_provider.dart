import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoleTreeNode {
  final String id;
  final String name;
  final String iconName;
  final int level;
  final List<RoleTreeNode> children;

  const RoleTreeNode({
    required this.id,
    required this.name,
    required this.iconName,
    required this.level,
    this.children = const [],
  });
}

class AccessPolicy {
  final String id;
  final String name;
  final String description;
  final String type; // Allow, Deny, Conditional
  final String resource;
  final List<String> effectiveRoles;
  final List<String> conflicts;
  final DateTime updatedAt;

  const AccessPolicy({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.resource,
    required this.effectiveRoles,
    required this.conflicts,
    required this.updatedAt,
  });
}

class AccessPolicyState {
  final List<AccessPolicy> policies;
  final List<AccessPolicy> filteredPolicies;
  final RoleTreeNode? rootNode;
  final String? selectedPolicyId;
  final String searchQuery;
  final bool isLoading;

  const AccessPolicyState({
    this.policies = const [],
    this.filteredPolicies = const [],
    this.rootNode,
    this.selectedPolicyId,
    this.searchQuery = '',
    this.isLoading = true,
  });

  AccessPolicyState copyWith({
    List<AccessPolicy>? policies,
    List<AccessPolicy>? filteredPolicies,
    RoleTreeNode? rootNode,
    String? selectedPolicyId,
    String? searchQuery,
    bool? isLoading,
  }) {
    return AccessPolicyState(
      policies: policies ?? this.policies,
      filteredPolicies: filteredPolicies ?? this.filteredPolicies,
      rootNode: rootNode ?? this.rootNode,
      selectedPolicyId: selectedPolicyId ?? this.selectedPolicyId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AccessPolicyNotifier extends Notifier<AccessPolicyState> {
  bool _initialized = false;

  @override
  AccessPolicyState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => init());
    }
    return const AccessPolicyState(isLoading: true);
  }

  void init() async {
    state = const AccessPolicyState(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final policies = _generateMockPolicies();
    final tree = _generateMockTree();
    
    state = state.copyWith(
      policies: policies,
      filteredPolicies: policies,
      rootNode: tree,
      isLoading: false,
    );
  }

  void setSearchQuery(String query) {
    var filtered = state.policies;
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(q) || 
        p.resource.toLowerCase().contains(q)
      ).toList();
    }
    state = state.copyWith(
      filteredPolicies: filtered,
      searchQuery: query,
    );
  }

  void selectPolicy(String id) {
    state = state.copyWith(selectedPolicyId: id);
  }

  void clearSelection() {
    state = AccessPolicyState(
      policies: state.policies,
      filteredPolicies: state.filteredPolicies,
      rootNode: state.rootNode,
      selectedPolicyId: null, // explicit null
      searchQuery: state.searchQuery,
      isLoading: state.isLoading,
    );
  }

  List<AccessPolicy> _generateMockPolicies() {
    return [
      AccessPolicy(
        id: 'pol_1',
        name: 'Default Tenant Admin',
        description: 'Grants full CRUD access to all resources within the tenant boundary.',
        type: 'Allow',
        resource: 'Tenant.*',
        effectiveRoles: ['Tenant Admin'],
        conflicts: [],
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      AccessPolicy(
        id: 'pol_2',
        name: 'Strict Financial Compliance',
        description: 'Denies DELETE operations on all finalized financial ledgers, regardless of role.',
        type: 'Deny',
        resource: 'Finance.Ledger',
        effectiveRoles: ['Platform Admin', 'Tenant Admin', 'Finance Manager'],
        conflicts: ['Default Tenant Admin (Allows Delete)'],
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      AccessPolicy(
        id: 'pol_3',
        name: 'Read-Only Auditor',
        description: 'Grants universal VIEW access to all modules but strictly denies CREATE, UPDATE, DELETE.',
        type: 'Conditional',
        resource: 'Global.*',
        effectiveRoles: ['Auditor'],
        conflicts: [],
        updatedAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      AccessPolicy(
        id: 'pol_4',
        name: 'Inventory Manager Standard',
        description: 'Grants CRUD on inventory modules. View on Sales pipelines.',
        type: 'Allow',
        resource: 'Inventory.*, Sales.View',
        effectiveRoles: ['Inventory Manager'],
        conflicts: [],
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      AccessPolicy(
        id: 'pol_5',
        name: 'Sales Manager Standard',
        description: 'Grants CRUD on Sales pipelines. View on Inventory matrix.',
        type: 'Allow',
        resource: 'Sales.*, Inventory.View',
        effectiveRoles: ['Sales Manager'],
        conflicts: [],
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }

  RoleTreeNode _generateMockTree() {
    return const RoleTreeNode(
      id: 'r_platform_admin',
      name: 'Platform Admin',
      iconName: 'globe',
      level: 0,
      children: [
        RoleTreeNode(
          id: 'r_tenant_admin',
          name: 'Tenant Admin',
          iconName: 'building-2',
          level: 1,
          children: [
            RoleTreeNode(
              id: 'r_sales_mgr',
              name: 'Sales Manager',
              iconName: 'trending-up',
              level: 2,
              children: [
                RoleTreeNode(id: 'r_sales_rep', name: 'Sales Representative', iconName: 'user', level: 3),
              ]
            ),
            RoleTreeNode(
              id: 'r_inv_mgr',
              name: 'Inventory Manager',
              iconName: 'package',
              level: 2,
              children: [
                RoleTreeNode(id: 'r_wh_staff', name: 'Warehouse Staff', iconName: 'user', level: 3),
              ]
            ),
            RoleTreeNode(
              id: 'r_fin_mgr',
              name: 'Finance Manager',
              iconName: 'bar-chart-3',
              level: 2,
            ),
          ]
        ),
        RoleTreeNode(
          id: 'r_auditor',
          name: 'Auditor',
          iconName: 'shield-alert',
          level: 1,
        ),
      ]
    );
  }
}

final accessPolicyProvider = NotifierProvider<AccessPolicyNotifier, AccessPolicyState>(
  AccessPolicyNotifier.new,
);
