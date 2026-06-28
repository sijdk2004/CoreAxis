class PermissionGroup {
  final String id;
  final String name;
  final String description;
  final int permissionCount;
  final int assignedRolesCount;
  final String status;
  final DateTime createdDate;
  final List<String> mockTopPermissions; // Added for UI display

  const PermissionGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.permissionCount,
    required this.assignedRolesCount,
    required this.status,
    required this.createdDate,
    required this.mockTopPermissions,
  });

  PermissionGroup copyWith({
    String? id,
    String? name,
    String? description,
    int? permissionCount,
    int? assignedRolesCount,
    String? status,
    DateTime? createdDate,
    List<String>? mockTopPermissions,
  }) {
    return PermissionGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissionCount: permissionCount ?? this.permissionCount,
      assignedRolesCount: assignedRolesCount ?? this.assignedRolesCount,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
      mockTopPermissions: mockTopPermissions ?? this.mockTopPermissions,
    );
  }
}
