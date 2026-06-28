class Organization {
  final String id;
  final String name;
  final String code;
  final String tenantId;
  final String tenantName;
  final String industry;
  final int branchCount;
  final int employeeCount;
  final String country;
  final String status;
  final String logoUrl;
  final DateTime createdAt;

  Organization({
    required this.id,
    required this.name,
    required this.code,
    required this.tenantId,
    required this.tenantName,
    required this.industry,
    required this.branchCount,
    required this.employeeCount,
    required this.country,
    required this.status,
    required this.logoUrl,
    required this.createdAt,
  });

  Organization copyWith({
    String? id,
    String? name,
    String? code,
    String? tenantId,
    String? tenantName,
    String? industry,
    int? branchCount,
    int? employeeCount,
    String? country,
    String? status,
    String? logoUrl,
    DateTime? createdAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      tenantId: tenantId ?? this.tenantId,
      tenantName: tenantName ?? this.tenantName,
      industry: industry ?? this.industry,
      branchCount: branchCount ?? this.branchCount,
      employeeCount: employeeCount ?? this.employeeCount,
      country: country ?? this.country,
      status: status ?? this.status,
      logoUrl: logoUrl ?? this.logoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
