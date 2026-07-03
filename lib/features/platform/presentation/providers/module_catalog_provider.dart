import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/module_catalog_model.dart';

class ModuleCatalogState {
  final List<ModuleCatalogModel> modules;
  final String searchQuery;
  final String selectedCategory;

  const ModuleCatalogState({
    required this.modules,
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  ModuleCatalogState copyWith({
    List<ModuleCatalogModel>? modules,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return ModuleCatalogState(
      modules: modules ?? this.modules,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }

  List<ModuleCatalogModel> get filteredModules {
    return modules.where((mod) {
      final matchesSearch = mod.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          mod.description.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || 
          (selectedCategory == 'Favorites' && mod.isFavorite) ||
          (selectedCategory == 'Recently Used' && mod.lastUsed != null) ||
          mod.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }
}

class ModuleCatalogNotifier extends Notifier<ModuleCatalogState> {
  @override
  ModuleCatalogState build() {
    return ModuleCatalogState(
      modules: [
        ModuleCatalogModel(
          id: 'mod-dashboard',
          name: 'Dashboard',
          description: 'Central hub for tracking operations, alerts, and platform metrics.',
          category: 'Analytics',
          iconName: 'layoutDashboard',
          version: '2.4.1',
          status: 'Active',
          screensCount: 12,
          dependencies: ['Core', 'Reporting Engine'],
          launchRoute: '/platform/dashboard',
          isFavorite: true,
          lastUsed: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ModuleCatalogModel(
          id: 'mod-tenant',
          name: 'Tenant Management',
          description: 'Provision and configure isolation bounds for tenants in multi-tenant environments.',
          category: 'Platform Administration',
          iconName: 'building',
          version: '2.0.0',
          status: 'Active',
          screensCount: 8,
          dependencies: ['Core', 'RBAC'],
          launchRoute: '/platform/tenants',
        ),
        ModuleCatalogModel(
          id: 'mod-users',
          name: 'Users',
          description: 'Manage identities, profiles, and basic user preferences across the platform.',
          category: 'Platform Administration',
          iconName: 'users',
          version: '3.1.2',
          status: 'Active',
          screensCount: 15,
          dependencies: ['RBAC', 'Auth Service'],
          launchRoute: '/platform/users',
          isFavorite: true,
          lastUsed: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ModuleCatalogModel(
          id: 'mod-workflow',
          name: 'Workflow Engine',
          description: 'Visual designer and execution runtime for business processes.',
          category: 'Automation',
          iconName: 'workflow',
          version: '1.8.0',
          status: 'Active',
          screensCount: 22,
          dependencies: ['Core', 'Approval Engine', 'Notification Engine'],
          launchRoute: '/platform/workflows',
          lastUsed: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ModuleCatalogModel(
          id: 'mod-approval',
          name: 'Approval Chains',
          description: 'Manage delegation, rule execution, and manual sign-offs across entities.',
          category: 'Automation',
          iconName: 'checkSquare',
          version: '1.4.5',
          status: 'Active',
          screensCount: 9,
          dependencies: ['Workflow Engine'],
          launchRoute: '/platform/approvals',
        ),
        ModuleCatalogModel(
          id: 'mod-notifications',
          name: 'Notifications',
          description: 'Omnichannel broadcast center, templates, and delivery queues.',
          category: 'Automation',
          iconName: 'bell',
          version: '2.1.0',
          status: 'Active',
          screensCount: 11,
          dependencies: ['Core'],
          launchRoute: '/platform/notifications',
        ),
        ModuleCatalogModel(
          id: 'mod-documents',
          name: 'Document Management',
          description: 'Secure vault for file storage, versioning, sharing, and compliance checks.',
          category: 'Documents',
          iconName: 'fileText',
          version: '4.0.0',
          status: 'Active',
          screensCount: 18,
          dependencies: ['Core', 'Storage Service'],
          launchRoute: '/platform/documents',
          isFavorite: true,
        ),
        ModuleCatalogModel(
          id: 'mod-reports',
          name: 'Reporting',
          description: 'Advanced data modeling, visual dashboard builder, and export center.',
          category: 'Analytics',
          iconName: 'pieChart',
          version: '3.2.1',
          status: 'Active',
          screensCount: 24,
          dependencies: ['Data Warehouse', 'Core'],
          launchRoute: '/platform/reports',
        ),
        ModuleCatalogModel(
          id: 'mod-audit',
          name: 'Audit Engine',
          description: 'Immutable ledger for security events, compliance reports, and data history.',
          category: 'Platform Administration',
          iconName: 'shieldCheck',
          version: '1.9.0',
          status: 'Active',
          screensCount: 7,
          dependencies: ['Core', 'Logging Service'],
          launchRoute: '/platform/audit',
        ),
        ModuleCatalogModel(
          id: 'mod-ai',
          name: 'AI Intelligence',
          description: 'Configure LLMs, manage autonomous agents, and evaluate prompts.',
          category: 'AI',
          iconName: 'bot',
          version: '1.0.0-beta',
          status: 'Beta',
          screensCount: 14,
          dependencies: ['Core'],
          launchRoute: '/platform/ai',
          isFavorite: true,
          lastUsed: DateTime.now().subtract(const Duration(minutes: 45)),
        ),
        ModuleCatalogModel(
          id: 'mod-marketplace',
          name: 'Marketplace',
          description: 'Discover, preview, and install specialized Industry Packs.',
          category: 'Industry Packs',
          iconName: 'store',
          version: '1.1.0',
          status: 'Active',
          screensCount: 3,
          dependencies: ['Core', 'Package Manager'],
          launchRoute: '/platform/marketplace',
        ),
      ],
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoryFilter(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void toggleFavorite(String moduleId) {
    final updatedModules = state.modules.map((mod) {
      if (mod.id == moduleId) {
        return mod.copyWith(isFavorite: !mod.isFavorite);
      }
      return mod;
    }).toList();
    state = state.copyWith(modules: updatedModules);
  }
}

final moduleCatalogProvider = NotifierProvider<ModuleCatalogNotifier, ModuleCatalogState>(() {
  return ModuleCatalogNotifier();
});
