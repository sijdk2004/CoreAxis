

/// Represents a pointer to a specific released version of a Marketplace Module.
/// This allows a Solution Blueprint to assemble a composition without duplicating the
/// module's actual definition or code.
class MarketplaceModuleReference {
  /// The unique ID of the MarketplaceModule.
  final String marketplaceModuleId;
  
  /// The module code
  final String moduleCode;

  /// The exact pinned semantic version of the released module (e.g., '1.0.0').
  final String exactPublishedVersion;

  /// Optional configuration overrides specific to this blueprint's usage of the module.
  final Map<String, dynamic> blueprintConfiguration;

  /// Whether this reference is flagged because a newer version exists in the marketplace.
  /// This is transient state used by the Blueprint Editor UI and typically not persisted
  /// strictly as part of the blueprint core definition itself, but included here for convenience.
  final bool hasUpdateAvailable;

  const MarketplaceModuleReference({
    required this.marketplaceModuleId,
    required this.moduleCode,
    required this.exactPublishedVersion,
    this.blueprintConfiguration = const {},
    this.hasUpdateAvailable = false,
  });

  MarketplaceModuleReference copyWith({
    String? marketplaceModuleId,
    String? moduleCode,
    String? exactPublishedVersion,
    Map<String, dynamic>? blueprintConfiguration,
    bool? hasUpdateAvailable,
  }) {
    return MarketplaceModuleReference(
      marketplaceModuleId: marketplaceModuleId ?? this.marketplaceModuleId,
      moduleCode: moduleCode ?? this.moduleCode,
      exactPublishedVersion: exactPublishedVersion ?? this.exactPublishedVersion,
      blueprintConfiguration: blueprintConfiguration ?? this.blueprintConfiguration,
      hasUpdateAvailable: hasUpdateAvailable ?? this.hasUpdateAvailable,
    );
  }
}
