import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/platform_user.dart';
import '../../domain/models/role.dart';

class ActionSimulationResult {
  final String actionName; // e.g. "Create"
  final bool isAllowed;
  final String primaryReason; // e.g. "Inherited from Tenant Admin"
  final List<String> contributingRoles;
  final bool hasConflict; // e.g. Role A says Yes, Role B says No

  const ActionSimulationResult({
    required this.actionName,
    required this.isAllowed,
    required this.primaryReason,
    required this.contributingRoles,
    required this.hasConflict,
  });
}

class ModuleSimulation {
  final String moduleId;
  final String moduleName;
  final String iconName; // lucide icon string map in UI
  final List<ActionSimulationResult> actions;
  final bool isFullyAccessible;

  const ModuleSimulation({
    required this.moduleId,
    required this.moduleName,
    required this.iconName,
    required this.actions,
    required this.isFullyAccessible,
  });
}

class PermissionSimulatorState {
  final List<PlatformUser> users;
  final List<Role> roles;
  
  final String simulationTargetType; // 'user' or 'role'
  final String? selectedTargetId;
  final String? selectedModuleId;
  
  final List<ModuleSimulation> simulatedModules;
  final bool isLoading;

  const PermissionSimulatorState({
    this.users = const [],
    this.roles = const [],
    this.simulationTargetType = 'user',
    this.selectedTargetId,
    this.selectedModuleId,
    this.simulatedModules = const [],
    this.isLoading = true,
  });

  PermissionSimulatorState copyWith({
    List<PlatformUser>? users,
    List<Role>? roles,
    String? simulationTargetType,
    String? selectedTargetId,
    String? selectedModuleId,
    List<ModuleSimulation>? simulatedModules,
    bool? isLoading,
  }) {
    return PermissionSimulatorState(
      users: users ?? this.users,
      roles: roles ?? this.roles,
      simulationTargetType: simulationTargetType ?? this.simulationTargetType,
      selectedTargetId: selectedTargetId ?? this.selectedTargetId,
      selectedModuleId: selectedModuleId ?? this.selectedModuleId,
      simulatedModules: simulatedModules ?? this.simulatedModules,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PermissionSimulatorNotifier extends Notifier<PermissionSimulatorState> {
  bool _initialized = false;

  @override
  PermissionSimulatorState build() {
    if (!_initialized) {
      _initialized = true;
      Future.microtask(() => init());
    }
    return const PermissionSimulatorState(isLoading: true);
  }

  void init() async {
    state = const PermissionSimulatorState(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    final mockUsers = _generateMockUsers();
    final mockRoles = _generateMockRoles();
    
    state = state.copyWith(
      users: mockUsers,
      roles: mockRoles,
      isLoading: false,
    );
  }

  void setSimulationType(String type) {
    state = PermissionSimulatorState(
      users: state.users,
      roles: state.roles,
      simulationTargetType: type,
      selectedTargetId: null,
      selectedModuleId: null,
      simulatedModules: const [],
      isLoading: state.isLoading,
    );
  }

  void selectTarget(String id) {
    state = PermissionSimulatorState(
      users: state.users,
      roles: state.roles,
      simulationTargetType: state.simulationTargetType,
      selectedTargetId: id,
      selectedModuleId: null,
      simulatedModules: state.simulatedModules,
      isLoading: state.isLoading,
    );
    _runSimulation(id);
  }

  void selectModule(String moduleId) {
    state = state.copyWith(selectedModuleId: moduleId);
  }

  void _runSimulation(String targetId) {
    // Highly randomized mock simulation algorithm to provide visual variety for demos.
    // In a real app, this would deeply traverse RBAC relations.
    
    final random = Random(targetId.hashCode);
    
    String primaryRoleName = 'Base Employee';
    if (state.simulationTargetType == 'role') {
      final role = state.roles.firstWhere((r) => r.id == targetId);
      primaryRoleName = role.name;
    } else {
      // Mock logic: User has Base Employee + 1 random role
      final role = state.roles[random.nextInt(state.roles.length)];
      primaryRoleName = role.name;
    }

    final modules = [
      {'id': 'm1', 'name': 'Dashboard', 'icon': 'layout-dashboard'},
      {'id': 'm2', 'name': 'Users & Identity', 'icon': 'users'},
      {'id': 'm3', 'name': 'Financial Reports', 'icon': 'bar-chart-3'},
      {'id': 'm4', 'name': 'Workflow Engine', 'icon': 'git-merge'},
      {'id': 'm5', 'name': 'Stellar AI Copilot', 'icon': 'sparkles'},
      {'id': 'm6', 'name': 'Inventory Matrix', 'icon': 'package'},
      {'id': 'm7', 'name': 'Sales Pipelines', 'icon': 'trending-up'},
      {'id': 'm8', 'name': 'Audit Logs', 'icon': 'shield-alert'},
    ];

    final defaultActions = ['View', 'Create', 'Update', 'Delete'];
    
    final simulatedModules = modules.map((m) {
      bool allAllowed = true;
      final actions = <ActionSimulationResult>[];
      
      for (var action in defaultActions) {
        // AI usually only has Access/Use
        if (m['id'] == 'm5' && action != 'View') continue;
        
        final actionName = m['id'] == 'm5' ? 'Access' : action;
        
        // Randomize logic to simulate complex permissions
        bool isAllowed = random.nextDouble() > 0.3; // 70% chance of allowance
        
        // Hardcode some logic for wow-factor conflict viewing
        bool hasConflict = false;
        String reason = '';
        List<String> roles = [primaryRoleName];
        
        if (isAllowed) {
          reason = 'Inherited via $primaryRoleName';
          if (random.nextDouble() > 0.8) {
            reason = 'Directly assigned to user';
            roles.add('Direct Assignment');
          }
        } else {
          reason = 'Denied by default policy';
          
          if (random.nextDouble() > 0.7) {
            hasConflict = true;
            isAllowed = false;
            reason = 'Conflict: $primaryRoleName allows, but Security Policy denies';
            roles.add('Security Policy (Deny)');
          }
        }
        
        if (!isAllowed) allAllowed = false;
        
        actions.add(ActionSimulationResult(
          actionName: actionName,
          isAllowed: isAllowed,
          primaryReason: reason,
          contributingRoles: roles,
          hasConflict: hasConflict,
        ));
      }
      
      return ModuleSimulation(
        moduleId: m['id']!,
        moduleName: m['name']!,
        iconName: m['icon']!,
        actions: actions,
        isFullyAccessible: allAllowed,
      );
    }).toList();

    state = state.copyWith(simulatedModules: simulatedModules);
  }

  // Same mock data as other providers for consistency
  List<PlatformUser> _generateMockUsers() {
    final depts = ['Engineering', 'Sales', 'HR', 'Finance'];
    final random = Random(101);
    return List.generate(10, (index) {
      return PlatformUser(
        id: 'usr_$index',
        firstName: 'Simulated',
        lastName: 'User ${index + 1}',
        email: 'user${index + 1}@example.com',
        employeeId: 'EMP-${index.toString().padLeft(4, '0')}',
        mobile: '+1555000${index.toString().padLeft(4, '0')}',
        departmentId: 'dept_${random.nextInt(depts.length)}',
        departmentName: depts[random.nextInt(depts.length)],
        organizationId: 'org_1',
        organizationName: 'Stellar HQ',
        status: PlatformUserStatus.active,
        role: PlatformUserRole.user,
        isMfaEnabled: true,
        isOnline: false,
      );
    });
  }

  List<Role> _generateMockRoles() {
    return [
      Role(id: 'r1', name: 'Platform Admin', code: 'SYS_ADMIN', scope: 'Global', description: '', usersAssigned: 0, permissionCount: 85, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r2', name: 'Tenant Admin', code: 'TEN_ADMIN', scope: 'Tenant', description: '', usersAssigned: 0, permissionCount: 45, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r3', name: 'Sales Manager', code: 'SALES_MGR', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 20, status: 'Active', createdDate: DateTime.now()),
      Role(id: 'r4', name: 'HR Manager', code: 'HR_MGR', scope: 'Organization', description: '', usersAssigned: 0, permissionCount: 25, status: 'Active', createdDate: DateTime.now()),
    ];
  }
}

final permissionSimulatorProvider = NotifierProvider<PermissionSimulatorNotifier, PermissionSimulatorState>(
  PermissionSimulatorNotifier.new,
);
