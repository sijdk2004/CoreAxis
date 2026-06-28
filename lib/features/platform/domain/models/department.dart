class Department {
  final String id;
  final String orgId;
  final String branchId;
  final String? parentId;
  final String name;
  final String code;
  final String manager;
  final String description;
  final String status;
  final int employees;
  final DateTime createdAt;

  Department({
    required this.id,
    required this.orgId,
    required this.branchId,
    this.parentId,
    required this.name,
    required this.code,
    required this.manager,
    required this.description,
    required this.status,
    required this.employees,
    required this.createdAt,
  });

  Department copyWith({
    String? id,
    String? orgId,
    String? branchId,
    String? parentId,
    String? name,
    String? code,
    String? manager,
    String? description,
    String? status,
    int? employees,
    DateTime? createdAt,
  }) {
    return Department(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      branchId: branchId ?? this.branchId,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      code: code ?? this.code,
      manager: manager ?? this.manager,
      description: description ?? this.description,
      status: status ?? this.status,
      employees: employees ?? this.employees,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orgId': orgId,
      'branchId': branchId,
      'parentId': parentId,
      'name': name,
      'code': code,
      'manager': manager,
      'description': description,
      'status': status,
      'employees': employees,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      orgId: json['orgId'],
      branchId: json['branchId'],
      parentId: json['parentId'],
      name: json['name'],
      code: json['code'],
      manager: json['manager'],
      description: json['description'] ?? '',
      status: json['status'],
      employees: json['employees'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
