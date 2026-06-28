import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/role.dart';
import 'role_list_provider.dart';

class RoleDetailState {
  final Role? role;
  final bool isLoading;
  
  // Mock Data for Tabs
  final List<Map<String, dynamic>> permissions;
  final List<Map<String, dynamic>> assignedUsers;
  final List<Map<String, dynamic>> auditLogs;

  // Chart Data
  final Map<String, double> permissionDistribution;
  final Map<String, int> usersByOrganization;

  const RoleDetailState({
    this.role,
    this.isLoading = true,
    this.permissions = const [],
    this.assignedUsers = const [],
    this.auditLogs = const [],
    this.permissionDistribution = const {},
    this.usersByOrganization = const {},
  });

  RoleDetailState copyWith({
    Role? role,
    bool? isLoading,
    List<Map<String, dynamic>>? permissions,
    List<Map<String, dynamic>>? assignedUsers,
    List<Map<String, dynamic>>? auditLogs,
    Map<String, double>? permissionDistribution,
    Map<String, int>? usersByOrganization,
  }) {
    return RoleDetailState(
      role: role ?? this.role,
      isLoading: isLoading ?? this.isLoading,
      permissions: permissions ?? this.permissions,
      assignedUsers: assignedUsers ?? this.assignedUsers,
      auditLogs: auditLogs ?? this.auditLogs,
      permissionDistribution: permissionDistribution ?? this.permissionDistribution,
      usersByOrganization: usersByOrganization ?? this.usersByOrganization,
    );
  }
}

class RoleDetailNotifier extends Notifier<RoleDetailState> {
  @override
  RoleDetailState build() {
    return const RoleDetailState(isLoading: true);
  }

  Future<void> init(String roleId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final existingRoles = ref.read(roleListProvider).allRoles;
    Role? role;
    try {
      role = existingRoles.firstWhere((r) => r.id == roleId);
    } catch (e) {
      // Fallback mock role if accessed directly
      role = Role(
        id: roleId,
        name: 'Mock Role',
        code: 'MOCK_ROLE',
        scope: 'Tenant',
        description: 'Fallback mock role description.',
        usersAssigned: 12,
        permissionCount: 45,
        status: 'Active',
        createdDate: DateTime.now(),
      );
    }

    final random = Random(roleId.hashCode);
    
    // Generate Mock Permissions
    final List<Map<String, dynamic>> mockPermissions = List.generate(15, (index) {
      final categories = ['User Management', 'Financials', 'Inventory', 'Sales', 'System Settings', 'Reports'];
      final actions = ['View', 'Create', 'Edit', 'Delete', 'Approve'];
      return {
        'id': 'perm_\$index',
        'category': categories[random.nextInt(categories.length)],
        'name': '\${actions[random.nextInt(actions.length)]} \${categories[random.nextInt(categories.length)]}',
        'description': 'Allows the user to perform action on resource.',
        'isGranted': random.nextDouble() > 0.3,
      };
    });

    // Generate Mock Users
    final List<Map<String, dynamic>> mockUsers = List.generate(role.usersAssigned > 0 ? min(role.usersAssigned, 20) : 0, (index) {
      return {
        'id': 'usr_\$index',
        'name': 'User \${index + 1}',
        'email': 'user\${index + 1}@example.com',
        'organization': 'Org \${random.nextInt(5) + 1}',
        'assignedDate': DateTime.now().subtract(Duration(days: random.nextInt(100))),
      };
    });

    // Generate Mock Audit Logs
    final List<Map<String, dynamic>> mockAuditLogs = List.generate(8, (index) {
      final events = ['Role Created', 'Permissions Updated', 'User Assigned', 'User Unassigned', 'Status Changed'];
      return {
        'id': 'log_\$index',
        'action': events[random.nextInt(events.length)],
        'user': 'Admin User \${random.nextInt(3) + 1}',
        'timestamp': DateTime.now().subtract(Duration(hours: random.nextInt(72) + (index * 24))),
        'details': 'System action logged for auditing purposes.',
      };
    });
    mockAuditLogs.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));

    // Chart Data
    final mockPermDist = {
      'Read': 45.0,
      'Write': 30.0,
      'Delete': 10.0,
      'Admin': 15.0,
    };

    final mockUsersByOrg = {
      'Stellar HQ': 45,
      'North Branch': 20,
      'South Branch': 15,
      'East Branch': 10,
    };

    state = state.copyWith(
      role: role,
      isLoading: false,
      permissions: mockPermissions,
      assignedUsers: mockUsers,
      auditLogs: mockAuditLogs,
      permissionDistribution: mockPermDist,
      usersByOrganization: mockUsersByOrg,
    );
  }

  void deactivateRole() {
    if (state.role != null) {
      state = state.copyWith(
        role: state.role!.copyWith(status: 'Inactive'),
      );
      // In a real app, we would also update the global roleListProvider or call an API
    }
  }
}

final roleDetailProvider = NotifierProvider<RoleDetailNotifier, RoleDetailState>(
  RoleDetailNotifier.new,
);
