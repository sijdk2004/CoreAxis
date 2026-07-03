class MarketplacePackModel {
  final String id;
  final String name;
  final String description;
  final String industry;
  final String iconName;
  final String status; // 'Installed', 'Coming Soon', 'Available'
  final List<String> modules;
  final String version;
  final String developer;

  const MarketplacePackModel({
    required this.id,
    required this.name,
    required this.description,
    required this.industry,
    required this.iconName,
    required this.status,
    required this.modules,
    required this.version,
    required this.developer,
  });

  MarketplacePackModel copyWith({
    String? id,
    String? name,
    String? description,
    String? industry,
    String? iconName,
    String? status,
    List<String>? modules,
    String? version,
    String? developer,
  }) {
    return MarketplacePackModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      iconName: iconName ?? this.iconName,
      status: status ?? this.status,
      modules: modules ?? this.modules,
      version: version ?? this.version,
      developer: developer ?? this.developer,
    );
  }
}
