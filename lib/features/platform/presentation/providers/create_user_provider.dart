import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/platform_user.dart';

class CreateUserState {
  final int currentStep;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  // Step 1: Basic Info
  final String firstName;
  final String lastName;
  final String employeeId;
  final String gender;
  final DateTime? dob;

  // Step 2: Contact Info
  final String email;
  final String mobile;
  final String altMobile;

  // Step 3: Organization Assignment
  final String? tenantId;
  final String? orgId;
  final String? branchId;
  final String? departmentId;
  final String designation;

  // Step 4: Security
  final String username;
  final String tempPassword;
  final bool requirePasswordChange;
  final bool enableMfa;
  final PlatformUserStatus status;

  // Step 5: Roles
  final Set<PlatformUserRole> selectedRoles;

  CreateUserState({
    this.currentStep = 0,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.firstName = '',
    this.lastName = '',
    this.employeeId = '',
    this.gender = 'Male',
    this.dob,
    this.email = '',
    this.mobile = '',
    this.altMobile = '',
    this.tenantId,
    this.orgId,
    this.branchId,
    this.departmentId,
    this.designation = '',
    this.username = '',
    this.tempPassword = '',
    this.requirePasswordChange = true,
    this.enableMfa = false,
    this.status = PlatformUserStatus.active,
    this.selectedRoles = const {},
  });

  CreateUserState copyWith({
    int? currentStep,
    bool? isLoading,
    bool? isSuccess,
    String? error,
    String? firstName,
    String? lastName,
    String? employeeId,
    String? gender,
    DateTime? dob,
    String? email,
    String? mobile,
    String? altMobile,
    String? tenantId,
    String? orgId,
    String? branchId,
    String? departmentId,
    String? designation,
    String? username,
    String? tempPassword,
    bool? requirePasswordChange,
    bool? enableMfa,
    PlatformUserStatus? status,
    Set<PlatformUserRole>? selectedRoles,
  }) {
    return CreateUserState(
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      employeeId: employeeId ?? this.employeeId,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      altMobile: altMobile ?? this.altMobile,
      tenantId: tenantId ?? this.tenantId,
      orgId: orgId ?? this.orgId,
      branchId: branchId ?? this.branchId,
      departmentId: departmentId ?? this.departmentId,
      designation: designation ?? this.designation,
      username: username ?? this.username,
      tempPassword: tempPassword ?? this.tempPassword,
      requirePasswordChange: requirePasswordChange ?? this.requirePasswordChange,
      enableMfa: enableMfa ?? this.enableMfa,
      status: status ?? this.status,
      selectedRoles: selectedRoles ?? this.selectedRoles,
    );
  }
}

class CreateUserNotifier extends Notifier<CreateUserState> {
  @override
  CreateUserState build() => CreateUserState();

  void setStep(int step) {
    if (step >= 0 && step <= 5) {
      state = state.copyWith(currentStep: step);
    }
  }

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateBasicInfo({
    String? firstName,
    String? lastName,
    String? employeeId,
    String? gender,
    DateTime? dob,
  }) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      employeeId: employeeId,
      gender: gender,
      dob: dob,
    );
  }

  void updateContactInfo({
    String? email,
    String? mobile,
    String? altMobile,
  }) {
    state = state.copyWith(
      email: email,
      mobile: mobile,
      altMobile: altMobile,
    );
  }

  void updateOrganization({
    String? tenantId,
    String? orgId,
    String? branchId,
    String? departmentId,
    String? designation,
  }) {
    state = state.copyWith(
      tenantId: tenantId,
      orgId: orgId,
      branchId: branchId,
      departmentId: departmentId,
      designation: designation,
    );
  }

  void updateSecurity({
    String? username,
    String? tempPassword,
    bool? requirePasswordChange,
    bool? enableMfa,
    PlatformUserStatus? status,
  }) {
    state = state.copyWith(
      username: username,
      tempPassword: tempPassword,
      requirePasswordChange: requirePasswordChange,
      enableMfa: enableMfa,
      status: status,
    );
  }

  void toggleRole(PlatformUserRole role) {
    final roles = Set<PlatformUserRole>.from(state.selectedRoles);
    if (roles.contains(role)) {
      roles.remove(role);
    } else {
      roles.add(role);
    }
    state = state.copyWith(selectedRoles: roles);
  }

  void reset() {
    state = CreateUserState();
  }

  Future<void> submit() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Mock network request
      await Future.delayed(const Duration(seconds: 2));
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final createUserProvider = NotifierProvider<CreateUserNotifier, CreateUserState>(CreateUserNotifier.new);
