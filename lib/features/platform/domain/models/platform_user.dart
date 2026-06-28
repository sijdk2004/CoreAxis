import 'package:flutter/foundation.dart';

enum PlatformUserRole {
  systemAdmin,
  tenantAdmin,
  organizationAdmin,
  manager,
  user,
}

enum PlatformUserStatus {
  active,
  inactive,
  locked,
  pending,
}

class PlatformUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String employeeId;
  final String? mobile;
  final String? avatarUrl;
  
  final String? tenantId;
  final String? tenantName;
  final String? organizationId;
  final String? organizationName;
  final String? departmentId;
  final String? departmentName;
  
  final PlatformUserRole role;
  final PlatformUserStatus status;
  final DateTime? lastLogin;
  final bool isMfaEnabled;
  final bool isOnline;

  const PlatformUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.employeeId,
    this.mobile,
    this.avatarUrl,
    this.tenantId,
    this.tenantName,
    this.organizationId,
    this.organizationName,
    this.departmentId,
    this.departmentName,
    required this.role,
    required this.status,
    this.lastLogin,
    this.isMfaEnabled = false,
    this.isOnline = false,
  });

  String get fullName => '$firstName $lastName';

  PlatformUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? employeeId,
    String? mobile,
    String? avatarUrl,
    String? tenantId,
    String? tenantName,
    String? organizationId,
    String? organizationName,
    String? departmentId,
    String? departmentName,
    PlatformUserRole? role,
    PlatformUserStatus? status,
    DateTime? lastLogin,
    bool? isMfaEnabled,
    bool? isOnline,
  }) {
    return PlatformUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      employeeId: employeeId ?? this.employeeId,
      mobile: mobile ?? this.mobile,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      role: role ?? this.role,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
      isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
