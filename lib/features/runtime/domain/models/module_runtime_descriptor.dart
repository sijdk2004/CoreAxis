import 'package:flutter/material.dart';

/// Runtime integration/compatibility metadata used by the Strangler migration.
/// 
/// It exists to allow legacy Business Modules to participate in the generic runtime
/// without rewriting them. It provides the metadata necessary for the generic
/// RuntimeShell to mount existing routes and enforce RBAC.
class ModuleRuntimeDescriptor {
  /// The unique module code matching Marketplace/Blueprint definitions (e.g., 'CORE_SALES')
  final String moduleCode;
  
  /// The display name for the runtime navigation sidebar
  final String displayName;
  
  /// The icon for the runtime navigation sidebar
  final IconData icon;
  
  /// The actual permission code expected by the existing RBAC system (e.g., 'SALES_VIEW')
  /// This bridges the gap between the generic runtime and legacy RBAC.
  final String requiredPermission;
  
  /// The base route or primary entry point owned by this module
  final String primaryRoute;
  
  /// The list of all route prefixes/paths claimed by this module,
  /// used by the runtime guard for deterministic resolution.
  final List<String> routePrefixes;
  
  /// Is this module currently available for runtime use? (Feature flag)
  final bool isAvailable;

  const ModuleRuntimeDescriptor({
    required this.moduleCode,
    required this.displayName,
    required this.icon,
    required this.requiredPermission,
    required this.primaryRoute,
    required this.routePrefixes,
    this.isAvailable = true,
  });

  /// Deterministically checks if a given GoRouter path belongs to this module
  bool ownsRoute(String path) {
    if (path == primaryRoute) return true;
    for (final prefix in routePrefixes) {
      if (path == prefix || path.startsWith('$prefix/')) {
        return true;
      }
    }
    return false;
  }
}
