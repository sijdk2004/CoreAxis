class Branch {
  final String id;
  final String orgId;
  final String name;
  final String code;
  final String manager;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String type; // e.g. Warehouse, Office
  final String status; // Active, Inactive
  final int departments;
  final int employees;
  final DateTime createdAt;

  Branch({
    required this.id,
    required this.orgId,
    required this.name,
    required this.code,
    required this.manager,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.type,
    required this.status,
    required this.departments,
    required this.employees,
    required this.createdAt,
  });

  Branch copyWith({
    String? id,
    String? orgId,
    String? name,
    String? code,
    String? manager,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? type,
    String? status,
    int? departments,
    int? employees,
    DateTime? createdAt,
  }) {
    return Branch(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      code: code ?? this.code,
      manager: manager ?? this.manager,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      type: type ?? this.type,
      status: status ?? this.status,
      departments: departments ?? this.departments,
      employees: employees ?? this.employees,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
