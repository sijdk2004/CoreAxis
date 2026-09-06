import 'marketplace_validation_result.dart';
import 'marketplace_module_dependency.dart';

enum MarketplaceDraftState {
  drafting,
  validationFailed,
  validated,
}

extension MarketplaceDraftStateExtension on MarketplaceDraftState {
  String get displayName {
    switch (this) {
      case MarketplaceDraftState.drafting:
        return 'Drafting';
      case MarketplaceDraftState.validationFailed:
        return 'Validation Failed';
      case MarketplaceDraftState.validated:
        return 'Validated';
    }
  }
}

class MarketplaceModuleDraft {
  final String version;
  final MarketplaceDraftState state;
  final MarketplaceValidationResult? validationResult;
  
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

  const MarketplaceModuleDraft({
    required this.version,
    this.state = MarketplaceDraftState.drafting,
    this.validationResult,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.icon,
    this.categoryIds = const [],
    this.tags = const [],
    this.capabilities = const [],
    this.features = const [],
    this.screens = const [],
    this.screenshots = const [],
    this.dependencies = const [],
    this.minCoreAxisVersion = '1.0.0',
    this.maxCoreAxisVersion,
  });

  MarketplaceModuleDraft copyWith({
    String? version,
    MarketplaceDraftState? state,
    MarketplaceValidationResult? validationResult,
    String? name,
    String? shortDescription,
    String? description,
    String? icon,
    List<String>? categoryIds,
    List<String>? tags,
    List<String>? capabilities,
    List<String>? features,
    List<String>? screens,
    List<String>? screenshots,
    List<MarketplaceModuleDependency>? dependencies,
    String? minCoreAxisVersion,
    String? maxCoreAxisVersion,
  }) {
    return MarketplaceModuleDraft(
      version: version ?? this.version,
      state: state ?? this.state,
      validationResult: validationResult ?? this.validationResult,
      name: name ?? this.name,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      categoryIds: categoryIds ?? this.categoryIds,
      tags: tags ?? this.tags,
      capabilities: capabilities ?? this.capabilities,
      features: features ?? this.features,
      screens: screens ?? this.screens,
      screenshots: screenshots ?? this.screenshots,
      dependencies: dependencies ?? this.dependencies,
      minCoreAxisVersion: minCoreAxisVersion ?? this.minCoreAxisVersion,
      maxCoreAxisVersion: maxCoreAxisVersion ?? this.maxCoreAxisVersion,
    );
  }
}
