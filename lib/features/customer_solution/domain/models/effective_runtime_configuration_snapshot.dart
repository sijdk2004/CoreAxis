import 'package:collection/collection.dart';
import 'dart:collection';

/// An immutable, deeply-copied value object representing the fully resolved
/// effective configuration for a CustomerSolution at a specific point in time.
/// 
/// This snapshot is directly consumable by Tenant Runtime and requires no further resolution.
class EffectiveRuntimeConfigurationSnapshot {
  /// The deeply merged configuration map, keyed by module code (e.g. 'MODULE_A').
  final Map<String, Map<String, dynamic>> resolvedConfiguration;
  
  /// The timestamp when this resolution occurred.
  final DateTime resolvedAt;
  
  /// The exact version of the Business Solution used as the source for this resolution,
  /// ensuring traceability back to the specific definition version.
  final String sourceSolutionDefinitionVersion;

  EffectiveRuntimeConfigurationSnapshot({
    required Map<String, Map<String, dynamic>> resolvedConfiguration,
    required this.resolvedAt,
    required this.sourceSolutionDefinitionVersion,
  }) : resolvedConfiguration = UnmodifiableMapView(
         resolvedConfiguration.map((key, value) => MapEntry(key, _makeDeeplyUnmodifiable(value) as Map<String, dynamic>))
       );

  static dynamic _makeDeeplyUnmodifiable(dynamic value) {
    if (value is Map) {
      final map = <String, dynamic>{};
      value.forEach((k, v) {
        map[k.toString()] = _makeDeeplyUnmodifiable(v);
      });
      return UnmodifiableMapView<String, dynamic>(map);
    } else if (value is List) {
      final list = <dynamic>[];
      for (final v in value) {
        list.add(_makeDeeplyUnmodifiable(v));
      }
      return UnmodifiableListView<dynamic>(list);
    }
    return value;
  }

  EffectiveRuntimeConfigurationSnapshot copyWith({
    Map<String, Map<String, dynamic>>? resolvedConfiguration,
    DateTime? resolvedAt,
    String? sourceSolutionDefinitionVersion,
  }) {
    return EffectiveRuntimeConfigurationSnapshot(
      resolvedConfiguration: resolvedConfiguration ?? this.resolvedConfiguration,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      sourceSolutionDefinitionVersion: sourceSolutionDefinitionVersion ?? this.sourceSolutionDefinitionVersion,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is EffectiveRuntimeConfigurationSnapshot &&
        mapEquals(other.resolvedConfiguration, resolvedConfiguration) &&
        other.resolvedAt == resolvedAt &&
        other.sourceSolutionDefinitionVersion == sourceSolutionDefinitionVersion;
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(resolvedConfiguration) ^
      resolvedAt.hashCode ^
      sourceSolutionDefinitionVersion.hashCode;
}
