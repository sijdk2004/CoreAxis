class Permission {
  final String id;
  final String code;
  final String name;
  final String module;
  final String category;
  final String description;
  final int assignedRolesCount;
  final String status;
  final DateTime createdDate;

  const Permission({
    required this.id,
    required this.code,
    required this.name,
    required this.module,
    required this.category,
    required this.description,
    required this.assignedRolesCount,
    required this.status,
    required this.createdDate,
  });

  Permission copyWith({
    String? id,
    String? code,
    String? name,
    String? module,
    String? category,
    String? description,
    int? assignedRolesCount,
    String? status,
    DateTime? createdDate,
  }) {
    return Permission(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      module: module ?? this.module,
      category: category ?? this.category,
      description: description ?? this.description,
      assignedRolesCount: assignedRolesCount ?? this.assignedRolesCount,
      status: status ?? this.status,
      createdDate: createdDate ?? this.createdDate,
    );
  }
}
