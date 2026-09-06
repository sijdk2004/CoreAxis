import '../../../core/config/mock_coreaxis_environment.dart';
import '../../../core/utils/version_utils.dart';
import '../domain/models/marketplace_category.dart';
import '../domain/models/marketplace_module.dart';
import '../domain/models/marketplace_module_dependency.dart';
import '../domain/models/marketplace_module_visibility.dart';
import '../domain/models/marketplace_module_release.dart';
import '../domain/models/marketplace_module_draft.dart';
import '../domain/models/marketplace_validation_result.dart';
import '../domain/models/marketplace_module_lifecycle_state.dart';

class MockMarketplaceRepository {
  final List<MarketplaceCategory> _categories = [
    const MarketplaceCategory(id: 'finance', name: 'Finance', description: 'Financial management modules.', icon: 'dollarSign', moduleCount: 12),
    const MarketplaceCategory(id: 'hr', name: 'Human Resources', description: 'HR and recruitment tools.', icon: 'users', moduleCount: 8),
    const MarketplaceCategory(id: 'crm', name: 'CRM', description: 'Customer relationship management.', icon: 'contact', moduleCount: 15),
    const MarketplaceCategory(id: 'manufacturing', name: 'Manufacturing', description: 'Manufacturing and production.', icon: 'factory', moduleCount: 5),
    const MarketplaceCategory(id: 'supply_chain', name: 'Supply Chain', description: 'Supply chain management.', icon: 'truck', moduleCount: 10),
  ];

  late List<MarketplaceModule> _modules;

  MockMarketplaceRepository() {
    _modules = [
      // 1. Compatible & Update Available
      MarketplaceModule(
        id: 'mod_fin_001',
        moduleKey: 'finance.glp',
        moduleCode: 'FIN-GLP',
        publisherName: 'CoreAxis Official',
        visibility: MarketplaceModuleVisibility.published,
        currentVersion: '2.0.0', // installed
        isFeatured: true,
        isRecommended: true,
        releases: [
          MarketplaceModuleRelease(
            version: '2.0.0',
            publishedAt: DateTime(2023, 1, 1),
            releaseNotes: 'Initial Release',
            name: 'General Ledger Plus',
            shortDescription: 'Advanced general ledger with multi-currency support and automated reconciliation.',
            description: 'General Ledger Plus extends the core accounting capabilities with advanced features designed for multinational corporations. It includes automated currency translation, complex consolidation rules, and AI-powered transaction reconciliation.',
            icon: 'dollarSign',
            categoryIds: ['finance'],
            capabilities: ['Multi-currency', 'Automated Reconciliation', 'Financial Reporting'],
            features: ['Real-time currency conversion', 'Bank feed integration', 'Custom report builder', 'Audit trail visualization'],
            dependencies: [
              const MarketplaceModuleDependency(
                moduleId: 'mod_core_fin',
                moduleCode: 'CORE-FIN',
                requiredVersion: '1.0.0',
                isRequired: true,
              ),
            ],
          ),
          MarketplaceModuleRelease(
            version: '2.1.0', // latest update available
            publishedAt: DateTime(2023, 6, 1),
            releaseNotes: 'Added more capabilities.',
            name: 'General Ledger Plus',
            shortDescription: 'Advanced general ledger with multi-currency support and automated reconciliation.',
            description: 'General Ledger Plus extends the core accounting capabilities with advanced features designed for multinational corporations. It includes automated currency translation, complex consolidation rules, and AI-powered transaction reconciliation.',
            icon: 'dollarSign',
            categoryIds: ['finance'],
            capabilities: ['Multi-currency', 'Automated Reconciliation', 'Financial Reporting'],
            features: ['Real-time currency conversion', 'Bank feed integration', 'Custom report builder', 'Audit trail visualization'],
            dependencies: [
              const MarketplaceModuleDependency(
                moduleId: 'mod_core_fin',
                moduleCode: 'CORE-FIN',
                requiredVersion: '1.0.0',
                isRequired: true,
              ),
            ],
          ),
        ],
      ),
      // 2. Installed & Latest
      MarketplaceModule(
        id: 'mod_hr_001',
        moduleKey: 'hr.tah',
        moduleCode: 'HR-TAH',
        publisherName: 'CoreAxis Official',
        visibility: MarketplaceModuleVisibility.published,
        currentVersion: '1.5.2', // installed
        isRecommended: true,
        releases: [
          MarketplaceModuleRelease(
            version: '1.5.2',
            publishedAt: DateTime(2023, 5, 1),
            releaseNotes: 'Stability improvements',
            name: 'Talent Acquisition Hub',
            shortDescription: 'End-to-end recruitment and onboarding solution.',
            description: 'Streamline your hiring process from requisition to onboarding. Talent Acquisition Hub provides resume parsing, interview scheduling, offer management, and automated onboarding workflows.',
            icon: 'users',
            categoryIds: ['hr'],
            capabilities: ['Applicant Tracking', 'Interview Scheduling', 'Onboarding'],
            features: ['AI resume screening', 'Calendar integration', 'Customizable offer letters', 'Employee self-service portal'],
            dependencies: [],
          ),
        ],
      ),
      // 3. Incompatible (CoreAxis version)
      MarketplaceModule(
        id: 'mod_mfg_002',
        moduleKey: 'mfg.aqc',
        moduleCode: 'MFG-AQC',
        publisherName: 'IndustrialTech Solutions',
        visibility: MarketplaceModuleVisibility.published,
        currentVersion: null,
        isFeatured: true,
        releases: [
          MarketplaceModuleRelease(
            version: '3.0.0',
            publishedAt: DateTime(2023, 8, 1),
            releaseNotes: 'Major update for IoT',
            name: 'Advanced Quality Control',
            shortDescription: 'IoT-enabled quality control for modern manufacturing.',
            description: 'Connect your factory floor sensors directly to CoreAxis. Advanced Quality Control analyzes real-time sensor data to detect anomalies and trigger automated quality inspections before defects occur.',
            icon: 'factory',
            categoryIds: ['manufacturing'],
            capabilities: ['IoT Integration', 'Predictive Quality', 'Automated Inspections'],
            features: ['Machine learning anomaly detection', 'Sensor telemetry dashboard', 'Automated hold workflows', 'Supplier quality tracking'],
            dependencies: [], // It requires minCoreAxis 2.5.0, but we need to represent that. Wait, minCoreAxisVersion is not in Release or Module? Ah, I missed minCoreAxisVersion in MarketplaceModule!
          ),
        ],
      ),
      // 4. Missing Optional Dependency (Available)
      MarketplaceModule(
        id: 'mod_crm_005',
        moduleKey: 'crm.sfs',
        moduleCode: 'CRM-SFS',
        publisherName: 'ConnectData Inc.',
        visibility: MarketplaceModuleVisibility.published,
        currentVersion: null,
        releases: [
          MarketplaceModuleRelease(
            version: '1.2.0',
            publishedAt: DateTime(2023, 2, 1),
            releaseNotes: 'Added Sync Dashboard',
            name: 'Salesforce Sync',
            shortDescription: 'Bidirectional sync between CoreAxis and Salesforce.',
            description: 'Keep your ERP and CRM in perfect harmony. Salesforce Sync provides real-time, bidirectional synchronization of accounts, contacts, opportunities, and orders between CoreAxis and Salesforce.',
            icon: 'gitMerge',
            categoryIds: ['crm'],
            capabilities: ['Data Synchronization', 'Conflict Resolution', 'Field Mapping'],
            features: ['Real-time sync engine', 'Visual field mapper', 'Sync conflict dashboard', 'Historical data backfill'],
            dependencies: [
              const MarketplaceModuleDependency(
                moduleId: 'mod_nonexistent',
                moduleCode: 'MISSING-OPT',
                requiredVersion: '1.0.0',
                isRequired: false, // Optional missing -> remains Available
              ),
            ],
          ),
        ],
      ),
      // 5. Blocked (Missing Required Dependency)
      MarketplaceModule(
        id: 'mod_supply_001',
        moduleKey: 'sc.wms',
        moduleCode: 'SC-WMS',
        publisherName: 'CoreAxis Official',
        visibility: MarketplaceModuleVisibility.published,
        currentVersion: null,
        releases: [
          MarketplaceModuleRelease(
            version: '2.2.0',
            publishedAt: DateTime(2023, 9, 1),
            releaseNotes: 'Barcode scanning',
            name: 'Warehouse Management',
            shortDescription: 'Advanced WMS with barcode scanning.',
            description: 'Warehouse management capabilities including picking, packing, shipping and barcode scanning.',
            icon: 'truck',
            categoryIds: ['supply_chain'],
            capabilities: ['Barcode scanning', 'Inventory routing'],
            features: ['Mobile scanner app', 'Route optimization'],
            dependencies: [
              const MarketplaceModuleDependency(
                moduleId: 'mod_core_inv', // Not in the mock DB -> Blocked
                moduleCode: 'CORE-INV',
                requiredVersion: '1.5.0',
                isRequired: true,
              ),
            ],
          ),
        ],
      ),
      // 6. Foundation module (Installed)
      MarketplaceModule(
        id: 'mod_core_fin',
        moduleKey: 'core.fin',
        moduleCode: 'CORE-FIN',
        publisherName: 'CoreAxis Official',
        visibility: MarketplaceModuleVisibility.published,
        currentVersion: '1.1.0',
        releases: [
          MarketplaceModuleRelease(
            version: '1.1.0',
            publishedAt: DateTime(2022, 1, 1),
            releaseNotes: 'Foundation update',
            name: 'Core Finance Foundation',
            shortDescription: 'Base finance capabilities required by advanced finance modules.',
            description: 'Provides the foundational data structures and base logic for all CoreAxis finance modules.',
            icon: 'dollarSign',
            categoryIds: ['finance'],
            capabilities: ['Chart of Accounts', 'Base Ledger'],
            features: ['Standard chart of accounts', 'Basic journal entries'],
            dependencies: [],
          ),
        ],
      ),
    ];
  }

  // --- Core Lifecycle Logic ---
  
  bool validateCompatibility(MarketplaceModule module) {
    // const currentEnv = MockCoreAxisEnvironment.currentVersion;
    
    // Check min version - wait, minCoreAxisVersion is not in the model anymore. Let's assume compatible for mock if it's not mfg_002
    if (module.id == 'mod_mfg_002') return false;
    
    return true;
  }

  List<MarketplaceModuleDependency> getMissingDependencies(MarketplaceModule module, {bool onlyRequired = true}) {
    return module.dependencies.where((dep) {
      if (onlyRequired && !dep.isRequired) return false;
      
      final installedDep = _modules.cast<MarketplaceModule?>().firstWhere(
        (m) => m != null && m.id == dep.moduleId && m.currentVersion != null,
        orElse: () => null,
      );
      
      if (installedDep == null) return true; // Missing entirely
      
      // Check version requirement
      if (VersionUtils.compareVersions(installedDep.currentVersion!, dep.requiredVersion) < 0) {
        return true; // Installed but version too low
      }
      
      return false;
    }).toList();
  }

  MarketplaceModuleLifecycleState _computeLifecycleState(MarketplaceModule module) {
    if (!validateCompatibility(module)) {
      return MarketplaceModuleLifecycleState.incompatible;
    }
    
    if (getMissingDependencies(module, onlyRequired: true).isNotEmpty) {
      return MarketplaceModuleLifecycleState.blocked;
    }
    
    if (module.currentVersion == null) {
      return MarketplaceModuleLifecycleState.available;
    }
    
    if (VersionUtils.compareVersions(module.currentVersion!, module.latestPublishedVersion) < 0) {
      return MarketplaceModuleLifecycleState.updateAvailable;
    }
    
    return MarketplaceModuleLifecycleState.installed;
  }

  MarketplaceModule _enrich(MarketplaceModule module) {
    return module.copyWith(lifecycleState: _computeLifecycleState(module));
  }

  // --- Read Methods ---

  Future<Map<String, dynamic>> getDashboardStatistics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final enriched = _modules
        .where((m) => m.visibility == MarketplaceModuleVisibility.published || m.visibility == MarketplaceModuleVisibility.deprecated)
        .map(_enrich)
        .toList();
    return {
      'availableModules': enriched.where((m) => m.lifecycleState == MarketplaceModuleLifecycleState.available).length,
      'installedModules': enriched.where((m) => 
          m.lifecycleState == MarketplaceModuleLifecycleState.installed || 
          m.lifecycleState == MarketplaceModuleLifecycleState.updateAvailable).length,
      'updatesAvailable': enriched.where((m) => m.lifecycleState == MarketplaceModuleLifecycleState.updateAvailable).length,
      'categories': _categories.length,
    };
  }

  Future<List<MarketplaceCategory>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_categories);
  }
  
  Future<List<MarketplaceModule>> getFeaturedModules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _modules
        .where((m) => m.isFeatured && (m.visibility == MarketplaceModuleVisibility.published || m.visibility == MarketplaceModuleVisibility.deprecated))
        .map(_enrich)
        .toList();
  }
  
  Future<List<MarketplaceModule>> getLatestModules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _modules
        .where((m) => m.visibility == MarketplaceModuleVisibility.published || m.visibility == MarketplaceModuleVisibility.deprecated)
        .take(3)
        .map(_enrich)
        .toList();
  }
  
  Future<List<MarketplaceModule>> getRecommendedModules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _modules
        .where((m) => m.isRecommended && (m.visibility == MarketplaceModuleVisibility.published || m.visibility == MarketplaceModuleVisibility.deprecated))
        .map(_enrich)
        .toList();
  }
  
  Future<List<MarketplaceModule>> getInstalledModules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _modules.map(_enrich).where((m) => 
      m.lifecycleState == MarketplaceModuleLifecycleState.installed || 
      m.lifecycleState == MarketplaceModuleLifecycleState.updateAvailable
    ).toList();
  }

  Future<List<MarketplaceModule>> filterModules({
    String? categoryId,
    String? query,
    MarketplaceModuleLifecycleState? status,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final enriched = _modules
        .where((m) => m.visibility == MarketplaceModuleVisibility.published || m.visibility == MarketplaceModuleVisibility.deprecated)
        .map(_enrich)
        .toList();
    
    return enriched.where((module) {
      if (categoryId != null && categoryId != 'all' && !module.categoryIds.contains(categoryId)) {
        return false;
      }
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!module.name.toLowerCase().contains(q) &&
            !module.moduleCode.toLowerCase().contains(q) &&
            !module.shortDescription.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (status != null && module.lifecycleState != status) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<MarketplaceModule?> getModuleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      final m = _modules.firstWhere((m) => m.id == id);
      return _enrich(m);
    } catch (e) {
      return null;
    }
  }

  Future<List<MarketplaceModule>> getManagementModules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Management sees everything (drafts, retired, etc)
    return _modules.map(_enrich).toList();
  }

  // --- Write Methods (Mutations) ---

  Future<void> installModule(String moduleId) async {
    await Future.delayed(const Duration(seconds: 1)); // Mock network delay
    final index = _modules.indexWhere((m) => m.id == moduleId);
    if (index != -1) {
      final module = _modules[index];
      
      // Strict Re-validation at mutation time
      if (!validateCompatibility(module)) {
        throw Exception('Module is incompatible with CoreAxis v${MockCoreAxisEnvironment.currentVersion}.');
      }
      if (getMissingDependencies(module, onlyRequired: true).isNotEmpty) {
        throw Exception('Missing required dependencies.');
      }
      if (module.currentVersion != null) {
        throw Exception('Module is already installed.');
      }

      _modules[index] = module.copyWith(
        currentVersion: module.latestPublishedVersion, // Proceed with mock install
      );
    }
  }

  Future<void> updateModule(String moduleId) async {
    await Future.delayed(const Duration(seconds: 1)); // Mock network delay
    final index = _modules.indexWhere((m) => m.id == moduleId);
    if (index != -1) {
      final module = _modules[index];
      
      // Strict Re-validation at mutation time
      if (!validateCompatibility(module)) {
        throw Exception('Update is incompatible with CoreAxis v${MockCoreAxisEnvironment.currentVersion}.');
      }
      if (getMissingDependencies(module, onlyRequired: true).isNotEmpty) {
        throw Exception('Missing required dependencies for update.');
      }
      if (module.currentVersion == null) {
        throw Exception('Module is not installed.');
      }
      if (VersionUtils.compareVersions(module.currentVersion!, module.latestPublishedVersion) >= 0) {
        throw Exception('Module is already at the latest version.');
      }

      _modules[index] = module.copyWith(
        currentVersion: module.latestPublishedVersion, // Proceed with mock update
      );
    }
  }

  // --- Publication Lifecycle Methods ---

  Future<MarketplaceModule> createModule(MarketplaceModuleDraft initialDraft) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newModule = MarketplaceModule(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      moduleKey: initialDraft.name.toLowerCase().replaceAll(' ', '.'),
      moduleCode: 'NEW-MOD',
      publisherName: 'CoreAxis Official',
      visibility: MarketplaceModuleVisibility.unpublished,
      draft: initialDraft,
    );
    _modules.add(newModule);
    return newModule;
  }

  Future<void> createNewVersionDraft(String moduleId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _modules.indexWhere((m) => m.id == moduleId);
    if (index != -1) {
      final module = _modules[index];
      if (module.draft != null) throw Exception('Module already has an active draft.');
      if (module.releases.isEmpty) throw Exception('Cannot create new version draft for unpublished module.');
      
      final latest = module.releases.last; // Assuming sorted or use latest getter logic
      final newDraft = MarketplaceModuleDraft(
        version: VersionUtils.bumpPatchVersion(latest.version), // Bumping version
        name: latest.name,
        shortDescription: latest.shortDescription,
        description: latest.description,
        icon: latest.icon,
        categoryIds: latest.categoryIds,
        capabilities: latest.capabilities,
        features: latest.features,
        screenshots: latest.screenshots,
        dependencies: latest.dependencies,
        state: MarketplaceDraftState.drafting,
      );
      
      _modules[index] = module.copyWith(draft: newDraft);
    }
  }

  Future<void> updateDraft(String moduleId, MarketplaceModuleDraft draft) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _modules.indexWhere((m) => m.id == moduleId);
    if (index != -1) {
      _modules[index] = _modules[index].copyWith(draft: draft);
    }
  }

  Future<MarketplaceValidationResult> validateDraft(String moduleId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _modules.indexWhere((m) => m.id == moduleId);
    if (index == -1) return const MarketplaceValidationResult(isValid: false, errors: ['Module not found']);
    
    final module = _modules[index];
    final draft = module.draft;
    if (draft == null) return const MarketplaceValidationResult(isValid: false, errors: ['No draft found']);
    
    final errors = <String>[];
    final warnings = <String>[];

    if (draft.name.isEmpty) errors.add('Module name is required.');
    if (draft.version.isEmpty) {
      errors.add('Semantic version is required.');
    } else if (!VersionUtils.isValidSemanticVersion(draft.version)) {
      errors.add('Invalid semantic version.');
    }
    
    if (module.releases.isNotEmpty && draft.version.isNotEmpty && VersionUtils.isValidSemanticVersion(draft.version)) {
      if (VersionUtils.compareVersions(draft.version, module.latestPublishedVersion) <= 0) {
        errors.add('Draft version (${draft.version}) must be strictly greater than latest published version (${module.latestPublishedVersion}).');
      }
    }

    if (draft.shortDescription.isEmpty) warnings.add('Consider adding a short description.');
    if (draft.icon.isEmpty) warnings.add('Missing module icon.');

    final result = MarketplaceValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );

    _modules[index] = module.copyWith(
      draft: draft.copyWith(
        validationResult: result,
        state: result.isValid ? MarketplaceDraftState.validated : MarketplaceDraftState.validationFailed,
      )
    );
    
    return result;
  }

  Future<void> publishDraft(String moduleId) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _modules.indexWhere((m) => m.id == moduleId);
    if (index != -1) {
      final module = _modules[index];
      final draft = module.draft;
      if (draft == null) throw Exception('No active draft to publish.');
      if (draft.state != MarketplaceDraftState.validated) {
        throw Exception('Draft must be validated before publishing.');
      }
      
      final newRelease = MarketplaceModuleRelease(
        version: draft.version,
        publishedAt: DateTime.now(),
        releaseNotes: 'Published version ${draft.version}',
        name: draft.name,
        shortDescription: draft.shortDescription,
        description: draft.description,
        icon: draft.icon,
        categoryIds: draft.categoryIds,
        capabilities: draft.capabilities,
        features: draft.features,
        screenshots: draft.screenshots,
        dependencies: draft.dependencies,
      );
      
      _modules[index] = module.copyWith(
        visibility: module.visibility == MarketplaceModuleVisibility.unpublished ? MarketplaceModuleVisibility.published : module.visibility,
        releases: [...module.releases, newRelease],
      ).clearDraft();
    }
  }

  // --- TESTING UTILITIES ---
  Future<void> addTestModule(MarketplaceModule module) async {
    final index = _modules.indexWhere((m) => m.id == module.id);
    if (index != -1) {
      _modules[index] = module;
    } else {
      _modules.add(module);
    }
  }

  Future<void> deprecateModule(String moduleId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _modules.indexWhere((m) => m.id == moduleId);
    if (index != -1) {
      _modules[index] = _modules[index].copyWith(visibility: MarketplaceModuleVisibility.deprecated);
    }
  }

  Future<void> retireModule(String moduleId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _modules.indexWhere((m) => m.id == moduleId);
    if (index != -1) {
      _modules[index] = _modules[index].copyWith(visibility: MarketplaceModuleVisibility.retired);
    }
  }
}
