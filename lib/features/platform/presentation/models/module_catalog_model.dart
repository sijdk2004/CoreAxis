class ModuleCatalogModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconName;
  final String version;
  final String status; // 'Active', 'Beta', 'Coming Soon'
  final int screensCount;
  final List<String> dependencies;
  final String launchRoute;
  final bool isFavorite;
  final DateTime? lastUsed;

  const ModuleCatalogModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconName,
    required this.version,
    required this.status,
    required this.screensCount,
    required this.dependencies,
    required this.launchRoute,
    this.isFavorite = false,
    this.lastUsed,
  });

  ModuleCatalogModel copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? iconName,
    String? version,
    String? status,
    int? screensCount,
    List<String>? dependencies,
    String? launchRoute,
    bool? isFavorite,
    DateTime? lastUsed,
  }) {
    return ModuleCatalogModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      version: version ?? this.version,
      status: status ?? this.status,
      screensCount: screensCount ?? this.screensCount,
      dependencies: dependencies ?? this.dependencies,
      launchRoute: launchRoute ?? this.launchRoute,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }
}
