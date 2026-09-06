class MarketplaceValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const MarketplaceValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });
}
