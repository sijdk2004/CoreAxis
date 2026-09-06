import 'package:coreaxis/features/solution_blueprint/domain/models/marketplace_module_reference.dart';

class SolutionModuleConfiguration {
  final MarketplaceModuleReference reference;
  final Map<String, dynamic> configuration;

  const SolutionModuleConfiguration({
    required this.reference,
    this.configuration = const {},
  });

  SolutionModuleConfiguration copyWith({
    MarketplaceModuleReference? reference,
    Map<String, dynamic>? configuration,
  }) {
    return SolutionModuleConfiguration(
      reference: reference ?? this.reference,
      configuration: configuration ?? this.configuration,
    );
  }
}
