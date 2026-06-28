import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/platform_user.dart';
import '../../domain/models/role.dart';

class AssignmentAuditLog {
  final String id;
  final String action; // e.g. "Assigned Role", "Removed Role"
  final String details;
  final DateTime timestamp;
  final String performedBy;

  const AssignmentAuditLog({
    required this.id,
    required this.action,
    required this.details,
    required this.timestamp,
    required this.performedBy,
  });
}

class UserRoleAssignmentState {
  final List<PlatformUser> users;
  final List<PlatformUser> filteredUsers;
  final List<Role> roles;
  final Map<String, List<String>> assignedRoles; // userId -> list of roleIds
  final Map<String, List<AssignmentAuditLog>> auditLogs; // userId -> list of logs
  
  final String? selectedUserId;
  final String userSearchQuery;
  final Set<String> selectedUserIdsForBulk;
  
  final bool isLoading;

  const UserRoleAssignmentState({
    this.users = const [],
    this.filteredUsers = const [],
    this.roles = const [],
    this.assignedRoles = const {},
    this.auditLogs = const {},
    this.selectedUserId,
    this.userSearchQuery = '',
    this.selectedUserIdsForBulk = const {},
    this.isLoading = true,
  });

  UserRoleAssignmentState copyWith({
    List<PlatformUser>? users,
    List<PlatformUser>? filteredUsers,
    List<Role>? roles,
    Map<String, List<String>>? assignedRoles,
    Map<String, List<AssignmentAuditLog>>? auditLogs,
    String? selectedUserId,
    String? userSearchQuery,
    Set<String>? selectedUserIdsForBulk,
    bool? isLoading,
    bool clearSelectedUser = false,
  }) {
    return UserRoleAssignmentState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      roles: roles ?? this.roles,
      assignedRoles: assignedRoles ?? this.assignedRoles,
      auditLogs: auditLogs ?? this.auditLogs,
      selectedUserId: clearSelectedUser ? null : (selectedUserId ?? this.selectedUserId),
      userSearchQuery: userSearchQuery ?? this.userSearchQuery,
      selectedUserIdsForBulk: selectedUserIdsForBulk ?? this.selectedUserIdsForBulk,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserRoleAssignmentNotifier extends Notifier<UserRoleAssignmentState> {
  bool _initialized = false;

  @override
  UserRoleAssignmentState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => init());
    }
    return const UserRoleAssignmentState(isLoading: true);
  }

  void init() async {
    state = const UserRoleAssignmentState(isLoading: true);
    
    await Future.delayed(const Duration(milliseconds: 600));

    final mockUsers = _generateMockUsers();
    final mockRoles = _generateMockRoles();
    final assignments = _generateMockAssignments(mockUsers, mockRoles);
    final logs = _generateMockLogs(mockUsers, mockRoles, assignments);
    
    state = state.copyWith(
      users: mockUsers,
      filteredUsers: mockUsers,
      roles: mockRoles,
      assignedRoles: assignments,
      auditLogs: logs,
      isLoading: false,
    );
  }

  void selectUser(String userId) {
    state = state.copyWith(selectedUserId: userId);
  }
  
  void clearSelection() {
    state = state.copyWith(clearSelectedUser: true);
  }

  void searchUsers(String query) {
    final filtered = state.users.where((u) {
      final q = query.toLowerCase();
      return u.firstName.toLowerCase().contains(q) || 
             u.lastName.toLowerCase().contains(q) || 
             u.email.toLowerCase().contains(q);
    }).toList();

    state = state.copyWith(
      userSearchQuery: query,
      filteredUsers: filtered,
    );
  }

  void toggleBulkSelection(String userId) {
    final newSelection = Set<String>.from(state.selectedUserIdsForBulk);
    if (newSelection.contains(userId)) {
      newSelection.remove(userId);
    } else {
      newSelection.add(userId);
    }
    state = state.copyWith(selectedUserIdsForBulk: newSelection);
  }

  void clearBulkSelection() {
    state = state.copyWith(selectedUserIdsForBulk: {});
  }

  void assignRoles(String userId, List<String> roleIds) {
    final newAssignments = Map<String, List<String>>.from(state.assignedRoles);
    final currentRoles = List<String>.from(newAssignments[userId] ?? []);
    
    final newLogs = Map<String, List<AssignmentAuditLog>>.from(state.auditLogs);
    final userLogs = List<AssignmentAuditLog>.from(newLogs[userId] ?? []);

    for (var rId in roleIds) {
      if (!currentRoles.contains(rId)) {
        currentRoles.add(rId);
        final roleName = state.roles.firstWhere((r) => r.id == rId).name;
        userLogs.insert(0, AssignmentAuditLog(
          id: DateTime.now().millisecondsSinceEpoch.toString() + rId,
          action: 'Assigned Role',
          details: 'Assigned role "$roleName"',
          timestamp: DateTime.now(),
          performedBy: 'Current Admin',
        ));
      }
    }

    newAssignments[userId] = currentRoles;
    newLogs[userId] = userLogs;
    
    state = state.copyWith(assignedRoles: newAssignments, auditLogs: newLogs);
  }

  void removeRole(String userId, String roleId) {
    final newAssignments = Map<String, List<String>>.from(state.assignedRoles);
    final currentRoles = List<String>.from(newAssignments[userId] ?? []);
    
    if (currentRoles.contains(roleId)) {
      currentRoles.remove(roleId);
      
      final newLogs = Map<String, List<AssignmentAuditLog>>.from(state.auditLogs);
      final userLogs = List<AssignmentAuditLog>.from(newLogs[userId] ?? []);
      
      final roleName = state.roles.firstWhere((r) => r.id == roleId).name;
      userLogs.insert(0, AssignmentAuditLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        action: 'Removed Role',
        details: 'Removed role "$roleName"',
        timestamp: DateTime.now(),
        performedBy: 'Current Admin',
      ));
      
      newAssignments[userId] = currentRoles;
      newLogs[userId] = userLogs;
      
      state = state.copyWith(assignedRoles: newAssignments, auditLogs: newLogs);
    }
  }

  List<PlatformUser> _generateMockUsers() {
    final depts = ['Engineering', 'Sales', 'HR', 'Finance', 'Operations', 'Marketing'];
    final orgs = ['Stellar HQ', 'North Branch', 'South Branch', 'East Branch'];
    final random = Random(42);
    
    return List.generate(20, (index) {
      return PlatformUser(
        id: 'usr_$index',
        firstName: 'User',
        lastName: '${index + 1}',
        email: 'user${index + 1}@example.com',
        employeeId: 'EMP-${index.toString().padLeft(4, '0')}',
        mobile: '+1555000${index.toString().padLeft(4, '0')}',
        departmentId: 'dept_${random.nextInt(depts.length)}',
        departmentName: depts[random.nextInt(depts.length)],
        organizationId: 'org_${random.nextInt(orgs.length)}',
        organizationName: orgs[random.nextInt(orgs.length)],
        status: random.nextDouble() > 0.1 ? PlatformUserStatus.active : PlatformUserStatus.inactive,
        role: PlatformUserRole.user,
        isMfaEnabled: true,
        isOnline: random.nextDouble() > 0.5,
      );
    });
  }

  List<Role> _generateMockRoles() {
    return [
      Role(id: 'r1', name: 'Platform Admin', code: 'SYS_ADMIN', scope: 'Global', description: '', usersAssigned: 0, permissionCount: 85, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r2', name: 'Tenant Admin', code: 'TEN_ADMIN', scope: 'Tenant', description: '', usersAssigned: 0, permissionCount: 45, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r3', name: 'Org Admin', code: 'ORG_ADMIN', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 30, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r4', name: 'Sales Manager', code: 'SALES_MGR', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 20, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r5', name: 'HR Manager', code: 'HR_MGR', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 25, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r6', name: 'Finance Controller', code: 'FIN_CTRL', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 35, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r7', name: 'Support Agent', code: 'SUP_AGENT', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 15, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r8', name: 'Employee (Base)', code: 'EMP_BASE', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 5, status: 'Active', createdDate: DateTime.now()),
    ];
  }

  Map<String, List<String>> _generateMockAssignments(List<PlatformUser> users, List<Role> roles) {
    final random = Random(123);
    final Map<String, List<String>> map = {};
    for (var u in users) {
      final numRoles = random.nextInt(3) + 1; // 1 to 3 roles
      final userRoles = <String>{};
      
      // Always give them EMP_BASE
      userRoles.add('r8');
      
      while(userRoles.length < numRoles) {
        userRoles.add(roles[random.nextInt(roles.length)].id);
      }
      map[u.id] = userRoles.toList();
    }
    return map;
  }
  
  Map<String, List<AssignmentAuditLog>> _generateMockLogs(List<PlatformUser> users, List<Role> roles, Map<String, List<String>> assignments) {
    final random = Random(456);
    final Map<String, List<AssignmentAuditLog>> map = {};
    for (var u in users) {
      final logs = <AssignmentAuditLog>[];
      final assigned = assignments[u.id] ?? [];
      
      for (var rId in assigned) {
        final roleName = roles.firstWhere((r) => r.id == rId).name;
        logs.add(AssignmentAuditLog(
          id: 'log_${random.nextInt(10000)}',
          action: 'Assigned Role',
          details: 'Assigned role "$roleName"',
          timestamp: DateTime.now().subtract(Duration(days: random.nextInt(60))),
          performedBy: 'System Auto-provision',
        ));
      }
      
      if (random.nextDouble() > 0.7) {
        logs.add(AssignmentAuditLog(
          id: 'log_${random.nextInt(10000)}',
          action: 'Removed Role',
          details: 'Removed role "Contractor"',
          timestamp: DateTime.now().subtract(Duration(days: random.nextInt(60) + 60)),
          performedBy: 'Admin User',
        ));
      }
      
      logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      map[u.id] = logs;
    }
    return map;
  }
}

final userRoleAssignmentProvider = NotifierProvider<UserRoleAssignmentNotifier, UserRoleAssignmentState>(
  UserRoleAssignmentNotifier.new,
);
