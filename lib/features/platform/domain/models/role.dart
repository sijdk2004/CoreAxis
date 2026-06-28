class Role {
  final String id;
  final String name;
  final String code;
  final String scope; // 'Platform', 'Tenant', 'System', 'Custom'
  final String description;
  final int usersAssigned;
  final int permissionCount;
  final String status; // 'Active', 'Inactive'
  final DateTime createdDate;

  const Role({
    required this.id,
    required this.name,
    required this.code,
    required this.scope,
    required this.description,
    required this.usersAssigned,
    required this.permissionCount,
    required this.status,
    required this.createdDate,
  });

  Role copyWith({
    String? id,
    String? name,
    String? code,
    String? scope,
    String? description,
    int? usersAssigned,
    int? permissionCount,
    String? status,
    DateTime? createdDate,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      scope: scope ?? this.scope,
      description: description ?? this.description,
      usersAssigned: usersAssigned ?? this.usersAssigned,
      permissionCount: permissionCount ?? this.permissionCount,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
