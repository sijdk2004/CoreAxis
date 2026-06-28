import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/role.dart';
import 'role_list_provider.dart';

class RoleFormState {
  final int currentStep;
  final bool isSaving;
  final bool isSuccess;
  
  // Basic Info
  final String? roleId;
  final String name;
  final String code;
  final String scope;
  final String description;
  final String status;
  
  // Permissions
  final Set<String> selectedPermissions;
  
  // Users
  final Set<String> selectedUserIds;

  const RoleFormState({
    this.currentStep = 0,
    this.isSaving = false,
    this.isSuccess = false,
    this.roleId,
    this.name = '',
    this.code = '',
    this.scope = 'Tenant',
    this.description = '',
    this.status = 'Active',
    this.selectedPermissions = const {},
    this.selectedUserIds = const {},
  });

  RoleFormState copyWith({
    int? currentStep,
    bool? isSaving,
    bool? isSuccess,
    String? roleId,
    String? name,
    String? code,
    String? scope,
    String? description,
    String? status,
    Set<String>? selectedPermissions,
    Set<String>? selectedUserIds,
  }) {
    return RoleFormState(
      currentStep: currentStep ?? this.currentStep,
      isSaving: isSaving ?? this.isSaving,
      isSuccess: isSuccess ?? this.isSuccess,
      roleId: roleId ?? this.roleId,
      name: name ?? this.name,
      code: code ?? this.code,
      scope: scope ?? this.scope,
      description: description ?? this.description,
      status: status ?? this.status,
      selectedPermissions: selectedPermissions ?? this.selectedPermissions,
      selectedUserIds: selectedUserIds ?? this.selectedUserIds,
    );
  }
}

class RoleFormNotifier extends Notifier<RoleFormState> {
  @override
  RoleFormState build() {
    return const RoleFormState();
  }

  void init(String? roleId) {
    if (roleId != null && roleId != 'new') {
      // Mock loading existing role
      // In a real app, we would fetch from repository
      final existingRoles = ref.read(roleListProvider).allRoles;
      try {
        final role = existingRoles.firstWhere((r) => r.id == roleId);
        state = state.copyWith(
          roleId: role.id,
          name: role.name,
          code: role.code,
          scope: role.scope,
          description: role.description,
          status: role.status,
          selectedPermissions: {'User Management', 'Financials'}, // Mock permissions
          selectedUserIds: {'usr_1', 'usr_2'}, // Mock users
          currentStep: 0,
          isSaving: false,
          isSuccess: false,
        );
      } catch (e) {
        // Fallback if role not found in mock list
      }
    } else {
      // Reset state for new role
      state = const RoleFormState();
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      state = state.copyWith(currentStep: step);
    }
  }

  void nextStep() => setStep(state.currentStep + 1);
  void prevStep() => setStep(state.currentStep - 1);

  void updateBasicInfo({
    required String name,
    required String code,
    required String scope,
    required String description,
    required String status,
  }) {
    state = state.copyWith(
      name: name,
      code: code,
      scope: scope,
      description: description,
      status: status,
    );
  }

  void togglePermission(String permission, bool selected) {
    final updated = Set<String>.from(state.selectedPermissions);
    if (selected) {
      updated.add(permission);
    } else {
      updated.remove(permission);
    }
    state = state.copyWith(selectedPermissions: updated);
  }

  void toggleUser(String userId, bool selected) {
    final updated = Set<String>.from(state.selectedUserIds);
    if (selected) {
      updated.add(userId);
    } else {
      updated.remove(userId);
    }
    state = state.copyWith(selectedUserIds: updated);
  }

  Future<void> submit() async {
    state = state.copyWith(isSaving: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock appending the role to the RoleListProvider
    final newRole = Role(
      id: state.roleId ?? 'r_new_\${DateTime.now().millisecondsSinceEpoch}',
      name: state.name,
      code: state.code,
      scope: state.scope,
      description: state.description,
      usersAssigned: state.selectedUserIds.length,
      permissionCount: state.selectedPermissions.length * 5, // Mock multiplier
      status: state.status,
      createdDate: DateTime.now(),
    );

    // If editing, we could theoretically update the list, but it's mock data.
    // For simplicity, we just trigger success.

    state = state.copyWith(isSaving: false, isSuccess: true);
  }
}

final roleFormProvider = NotifierProvider<RoleFormNotifier, RoleFormState>(
  RoleFormNotifier.new,
);
