enum MarketplaceModuleVisibility {
  unpublished, // Brand new, no published releases yet
  published,   // Has at least one published release
  deprecated,  // Deprecated by publisher
  retired,     // Retired by publisher
}

extension MarketplaceModuleVisibilityExtension on MarketplaceModuleVisibility {
  String get displayName {
    switch (this) {
      case MarketplaceModuleVisibility.unpublished:
        return 'Unpublished';
      case MarketplaceModuleVisibility.published:
        return 'Published';
      case MarketplaceModuleVisibility.deprecated:
        return 'Deprecated';
      case MarketplaceModuleVisibility.retired:
        return 'Retired';
    }
  }
}
