enum MarketplaceModuleLifecycleState {
  available,
  installed,
  updateAvailable,
  incompatible,
  blocked,
}

extension MarketplaceModuleLifecycleStateExtension on MarketplaceModuleLifecycleState {
  String get displayName {
    switch (this) {
      case MarketplaceModuleLifecycleState.available:
        return 'Available';
      case MarketplaceModuleLifecycleState.installed:
        return 'Installed';
      case MarketplaceModuleLifecycleState.updateAvailable:
        return 'Update Available';
      case MarketplaceModuleLifecycleState.incompatible:
        return 'Incompatible';
      case MarketplaceModuleLifecycleState.blocked:
        return 'Blocked by Dependencies';
    }
  }
}
