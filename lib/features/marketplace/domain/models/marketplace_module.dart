import '../../../../core/utils/version_utils.dart';
import 'marketplace_module_dependency.dart';
import 'marketplace_module_lifecycle_state.dart';
import 'marketplace_module_visibility.dart';
import 'marketplace_module_release.dart';
import 'marketplace_module_draft.dart';

class MarketplaceModule {
  // Core Identifiers
  final String id;
  final String moduleKey;
  final String moduleCode;
  final String publisherName;
  
  // Overarching Marketplace Visibility State
  final MarketplaceModuleVisibility visibility;
  
  // Immutable history of published releases
  final List<MarketplaceModuleRelease> releases;
  
  // Mutable active draft (if any)
  final MarketplaceModuleDraft? draft;
  
  // Operation State / Display state derived from Mock Installation
  final MarketplaceModuleLifecycleState lifecycleState;
  final String? currentVersion; // The currently installed version, if installed
  
  // Base details (these are pulled from the latest release for display, or draft if unpublished)
  final bool isFeatured;
  final bool isRecommended;
  final bool isFavorite;
  
  MarketplaceModule({
    required this.id,
    required this.moduleKey,
    required this.moduleCode,
    required this.publisherName,
    this.visibility = MarketplaceModuleVisibility.unpublished,
    List<MarketplaceModuleRelease> releases = const [],
    this.draft,
    this.lifecycleState = MarketplaceModuleLifecycleState.available,
    this.currentVersion,
    this.isFeatured = false,
    this.isRecommended = false,
    this.isFavorite = false,
  }) : releases = List.unmodifiable(releases);

  String get latestPublishedVersion {
    if (releases.isEmpty) return '0.0.0';
    return releases.map((r) => r.version).reduce((a, b) => VersionUtils.compareVersions(a, b) > 0 ? a : b);
  }

  // Getters for standard display fields, pulling from latest release or draft
  String get name => _latestData?.name ?? draft?.name ?? '';
  String get shortDescription => _latestData?.shortDescription ?? draft?.shortDescription ?? '';
  String get description => _latestData?.description ?? draft?.description ?? '';
  String get icon => _latestData?.icon ?? draft?.icon ?? 'box';
  List<String> get categoryIds => _latestData?.categoryIds ?? draft?.categoryIds ?? [];
  List<String> get capabilities => _latestData?.capabilities ?? draft?.capabilities ?? [];
  List<String> get features => _latestData?.features ?? draft?.features ?? [];
  List<String> get screenshots => _latestData?.screenshots ?? draft?.screenshots ?? [];
  List<String> get screens => _latestData?.screens ?? draft?.screens ?? [];
  List<String> get tags => _latestData?.tags ?? draft?.tags ?? [];
  String get minCoreAxisVersion => _latestData?.minCoreAxisVersion ?? draft?.minCoreAxisVersion ?? '1.0.0';
  String? get maxCoreAxisVersion => _latestData?.maxCoreAxisVersion ?? draft?.maxCoreAxisVersion;
  List<MarketplaceModuleDependency> get dependencies => _latestData?.dependencies ?? draft?.dependencies ?? [];

  MarketplaceModuleRelease? get _latestData {
    if (releases.isEmpty) return null;
    final latestVer = latestPublishedVersion;
    return releases.firstWhere((r) => r.version == latestVer, orElse: () => releases.first);
  }

  MarketplaceModule copyWith({
    String? id,
    String? moduleKey,
    String? moduleCode,
    String? publisherName,
    MarketplaceModuleVisibility? visibility,
    List<MarketplaceModuleRelease>? releases,
    MarketplaceModuleDraft? draft,
    MarketplaceModuleLifecycleState? lifecycleState,
    String? currentVersion,
    bool? isFeatured,
    bool? isRecommended,
    bool? isFavorite,
  }) {
    return MarketplaceModule(
      id: id ?? this.id,
      moduleKey: moduleKey ?? this.moduleKey,
      moduleCode: moduleCode ?? this.moduleCode,
      publisherName: publisherName ?? this.publisherName,
      visibility: visibility ?? this.visibility,
      releases: releases ?? this.releases,
      draft: draft ?? this.draft,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      currentVersion: currentVersion ?? this.currentVersion,
      isFeatured: isFeatured ?? this.isFeatured,
      isRecommended: isRecommended ?? this.isRecommended,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Helper to clear draft
  MarketplaceModule clearDraft() {
    return MarketplaceModule(
      id: id,
      moduleKey: moduleKey,
      moduleCode: moduleCode,
      publisherName: publisherName,
      visibility: visibility,
      releases: releases,
      draft: null,
      lifecycleState: lifecycleState,
      currentVersion: currentVersion,
      isFeatured: isFeatured,
      isRecommended: isRecommended,
      isFavorite: isFavorite,
    );
  }
}
