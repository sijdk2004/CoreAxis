import '../models/customer_solution.dart';
import '../models/effective_runtime_configuration_snapshot.dart';
import 'dart:convert';

/// A pure domain service responsible for determining the effective runtime configuration
/// for a CustomerSolution.
/// 
/// It implements deep-merging where:
/// Blueprint Defaults + Current CustomerSolution Configuration = Effective Configuration
class CustomerSolutionConfigurationResolver {
  
  /// Resolves the effective runtime configuration for a given CustomerSolution.
  /// 
  /// The returned snapshot is deeply immutable and fully flattened, making it 
  /// directly consumable by M9 Tenant Runtime.
  EffectiveRuntimeConfigurationSnapshot resolve(CustomerSolution solution) {
    final Map<String, Map<String, dynamic>> resolvedConfig = {};

    for (final module in solution.moduleConfigurations) {
      final moduleCode = module.reference.moduleCode;
      
      // Get Blueprint defaults for this module
      final blueprintDefaults = module.reference.blueprintConfiguration;
      
      // Get the current configuration (initialized from Business Solution Config and mutated over time)
      final currentConfig = module.configuration;

      // Deep merge: Current Config overrides Blueprint Defaults
      final mergedModuleConfig = _deepMerge(blueprintDefaults, currentConfig);
      
      resolvedConfig[moduleCode] = mergedModuleConfig;
    }

    return EffectiveRuntimeConfigurationSnapshot(
      resolvedConfiguration: resolvedConfig,
      resolvedAt: DateTime.now().toUtc(),
      sourceSolutionDefinitionVersion: solution.exactSolutionDefinitionVersion,
    );
  }

  /// Recursively merges [overrideMap] into [baseMap].
  /// 
  /// - Keys in [overrideMap] overwrite keys in [baseMap].
  /// - If a key is null in [overrideMap], it effectively removes the key from the merged result.
  /// - The original maps are not mutated; a new Map is returned.
  Map<String, dynamic> _deepMerge(Map<String, dynamic> baseMap, Map<String, dynamic> overrideMap) {
    // Start with a deep copy of the base map to avoid mutating the original
    final merged = _deepCopyMap(baseMap);

    for (final key in overrideMap.keys) {
      final overrideValue = overrideMap[key];

      if (overrideValue == null) {
        // Explicit null in override removes the key inherited from base
        merged.remove(key);
      } else if (overrideValue is Map<String, dynamic> && merged[key] is Map<String, dynamic>) {
        // Deep merge nested maps
        merged[key] = _deepMerge(merged[key] as Map<String, dynamic>, overrideValue);
      } else {
        // Overwrite or add
        merged[key] = _deepCopyValue(overrideValue);
      }
    }

    return merged;
  }
  
  /// Helper to deep copy a Map using JSON serialization, ensuring complete isolation.
  Map<String, dynamic> _deepCopyMap(Map<String, dynamic> original) {
    if (original.isEmpty) return <String, dynamic>{};
    return jsonDecode(jsonEncode(original)) as Map<String, dynamic>;
  }

  /// Helper to deep copy a single value using JSON serialization if needed.
  dynamic _deepCopyValue(dynamic value) {
    if (value == null || value is num || value is bool || value is String) {
      return value;
    }
    return jsonDecode(jsonEncode(value));
  }
}
