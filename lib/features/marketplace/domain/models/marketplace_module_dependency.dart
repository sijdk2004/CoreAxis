class MarketplaceModuleDependency {
  final String moduleId;
  final String moduleCode;
  final String requiredVersion;
  final bool isRequired;

  const MarketplaceModuleDependency({
    required this.moduleId,
    required this.moduleCode,
    required this.requiredVersion,
    this.isRequired = true,
  });

  MarketplaceModuleDependency copyWith({
    String? moduleId,
    String? moduleCode,
    String? requiredVersion,
    bool? isRequired,
  }) {
    return MarketplaceModuleDependency(
      moduleId: moduleId ?? this.moduleId,
      moduleCode: moduleCode ?? this.moduleCode,
      requiredVersion: requiredVersion ?? this.requiredVersion,
      isRequired: isRequired ?? this.isRequired,
    );
  }
}
