class MarketplaceCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int moduleCount;

  const MarketplaceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.moduleCount = 0,
  });

  MarketplaceCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? icon,
    int? moduleCount,
  }) {
    return MarketplaceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      moduleCount: moduleCount ?? this.moduleCount,
    );
  }
}
