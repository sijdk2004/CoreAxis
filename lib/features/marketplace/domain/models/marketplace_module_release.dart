import 'marketplace_module_dependency.dart';

class MarketplaceModuleRelease {
  final String version;
  final DateTime publishedAt;
  final String releaseNotes;
  
  // Immutable snapshots for this specific release
  final String name;
  final String shortDescription;
  final String description;
  final String icon;
  final List<String> categoryIds;
  final List<String> tags;
  final List<String> capabilities;
  final List<String> features;
  final List<String> screens;
  final List<String> screenshots;
  final List<MarketplaceModuleDependency> dependencies;
  
  final String minCoreAxisVersion;
  final String? maxCoreAxisVersion;

  MarketplaceModuleRelease({
    required this.version,
    required this.publishedAt,
    required this.releaseNotes,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.icon,
    List<String> categoryIds = const [],
    List<String> tags = const [],
    List<String> capabilities = const [],
    List<String> features = const [],
    List<String> screens = const [],
    List<String> screenshots = const [],
    List<MarketplaceModuleDependency> dependencies = const [],
    this.minCoreAxisVersion = '1.0.0',
    this.maxCoreAxisVersion,
  }) : categoryIds = List.unmodifiable(categoryIds),
       tags = List.unmodifiable(tags),
       capabilities = List.unmodifiable(capabilities),
       features = List.unmodifiable(features),
       screens = List.unmodifiable(screens),
       screenshots = List.unmodifiable(screenshots),
       dependencies = List.unmodifiable(dependencies);
}
