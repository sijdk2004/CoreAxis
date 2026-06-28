class Tenant {
  final String id;
  final String name;
  final String code;
  final String logoUrl;
  final int organizationCount;
  final int userCount;
  final String subscriptionPlan;
  final String status;
  final DateTime createdAt;
  final DateTime lastActivity;

  Tenant({
    required this.id,
    required this.name,
    required this.code,
    required this.logoUrl,
    required this.organizationCount,
    required this.userCount,
    required this.subscriptionPlan,
    required this.status,
    required this.createdAt,
    required this.lastActivity,
  });

  Tenant copyWith({
    String? id,
    String? name,
    String? code,
    String? logoUrl,
    int? organizationCount,
    int? userCount,
    String? subscriptionPlan,
    String? status,
    DateTime? createdAt,
    DateTime? lastActivity,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      logoUrl: logoUrl ?? this.logoUrl,
      organizationCount: organizationCount ?? this.organizationCount,
      userCount: userCount ?? this.userCount,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}
