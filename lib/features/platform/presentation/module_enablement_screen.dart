import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

// --- MOCK MODELS ---
class PackModule {
  final String id;
  final String name;
  final String description;
  final bool isEnabled;
  final bool isFuture;
  final List<String> dependencies;

  PackModule({
    required this.id,
    required this.name,
    required this.description,
    this.isEnabled = false,
    this.isFuture = false,
    this.dependencies = const [],
  });

  PackModule copyWith({
    String? id,
    String? name,
    String? description,
    bool? isEnabled,
    bool? isFuture,
    List<String>? dependencies,
  }) {
    return PackModule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isEnabled: isEnabled ?? this.isEnabled,
      isFuture: isFuture ?? this.isFuture,
      dependencies: dependencies ?? this.dependencies,
    );
  }
}

final _mockFurniFlowModules = [
  PackModule(id: 'mod_dash', name: 'Dashboard', description: 'Centralized overview and analytics.', isEnabled: true),
  PackModule(id: 'mod_crm', name: 'CRM', description: 'Manage customer relationships and leads.', isEnabled: true),
  PackModule(id: 'mod_cust', name: 'Customers', description: 'Customer database and history.', isEnabled: true, dependencies: ['CRM']),
  PackModule(id: 'mod_cat', name: 'Product Catalog', description: 'Manage products and variants.', isEnabled: true),
  PackModule(id: 'mod_quo', name: 'Quotations', description: 'Create and send quotes.', isEnabled: true, dependencies: ['Product Catalog', 'CRM']),
  PackModule(id: 'mod_so', name: 'Sales Orders', description: 'Process and track sales.', isEnabled: true, dependencies: ['Quotations']),
  PackModule(id: 'mod_bom', name: 'BOM', description: 'Bill of Materials management.', isEnabled: true, dependencies: ['Product Catalog']),
  PackModule(id: 'mod_prod', name: 'Production', description: 'Manufacturing workflows and routing.', isEnabled: true, dependencies: ['BOM']),
  PackModule(id: 'mod_inv', name: 'Inventory', description: 'Stock control and warehousing.', isEnabled: true),
  PackModule(id: 'mod_del', name: 'Delivery', description: 'Shipping and logistics tracking.', isEnabled: true, dependencies: ['Sales Orders']),
  PackModule(id: 'mod_fin', name: 'Finance', description: 'Invoicing and accounting integration.', isEnabled: true, dependencies: ['Sales Orders', 'Inventory']),
  
  // Future Modules
  PackModule(id: 'mod_proc', name: 'Procurement', description: 'Supplier and PO management.', isFuture: true),
  PackModule(id: 'mod_hr', name: 'HR', description: 'Human resources and employee management.', isFuture: true),
  PackModule(id: 'mod_pay', name: 'Payroll', description: 'Employee compensation.', isFuture: true, dependencies: ['HR']),
  PackModule(id: 'mod_qual', name: 'Quality', description: 'Quality assurance and testing.', isFuture: true, dependencies: ['Production']),
  PackModule(id: 'mod_maint', name: 'Maintenance', description: 'Equipment maintenance schedules.', isFuture: true),
  PackModule(id: 'mod_mrp', name: 'MRP', description: 'Material Requirements Planning.', isFuture: true, dependencies: ['BOM', 'Inventory', 'Production']),
];

// --- STATE ---
class ModuleEnablementState {
  final List<PackModule> modules;
  final String searchQuery;
  final String filter; // 'All', 'Enabled', 'Disabled', 'Future'
  final bool hasUnsavedChanges;
  final bool isSaving;

  ModuleEnablementState({
    required this.modules,
    this.searchQuery = '',
    this.filter = 'All',
    this.hasUnsavedChanges = false,
    this.isSaving = false,
  });

  ModuleEnablementState copyWith({
    List<PackModule>? modules,
    String? searchQuery,
    String? filter,
    bool? hasUnsavedChanges,
    bool? isSaving,
  }) {
    return ModuleEnablementState(
      modules: modules ?? this.modules,
      searchQuery: searchQuery ?? this.searchQuery,
      filter: filter ?? this.filter,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class ModuleEnablementNotifier extends Notifier<ModuleEnablementState> {
  @override
  ModuleEnablementState build() {
    // We ignore packId and just load mock furniflow data for the demo
    return ModuleEnablementState(modules: _mockFurniFlowModules);
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateFilter(String filter) {
    state = state.copyWith(filter: filter);
  }

  void toggleModule(String id, bool isEnabled) {
    final newModules = state.modules.map((m) {
      if (m.id == id && !m.isFuture) {
        return m.copyWith(isEnabled: isEnabled);
      }
      return m;
    }).toList();
    state = state.copyWith(modules: newModules, hasUnsavedChanges: true);
  }

  void bulkEnable() {
    final newModules = state.modules.map((m) {
      if (!m.isFuture) return m.copyWith(isEnabled: true);
      return m;
    }).toList();
    state = state.copyWith(modules: newModules, hasUnsavedChanges: true);
  }

  void bulkDisable() {
    final newModules = state.modules.map((m) {
      if (!m.isFuture) return m.copyWith(isEnabled: false);
      return m;
    }).toList();
    state = state.copyWith(modules: newModules, hasUnsavedChanges: true);
  }

  Future<void> saveChanges() async {
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(seconds: 1)); // Mock save delay
    state = state.copyWith(isSaving: false, hasUnsavedChanges: false);
  }
}

final moduleEnablementProvider = NotifierProvider<ModuleEnablementNotifier, ModuleEnablementState>(ModuleEnablementNotifier.new);

// --- SCREEN ---
class ModuleEnablementScreen extends ConsumerStatefulWidget {
  final String packId;

  const ModuleEnablementScreen({super.key, required this.packId});

  @override
  ConsumerState<ModuleEnablementScreen> createState() => _ModuleEnablementScreenState();
}

class _ModuleEnablementScreenState extends ConsumerState<ModuleEnablementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(moduleEnablementProvider);
    final notifier = ref.read(moduleEnablementProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    final filteredModules = state.modules.where((m) {
      final matchesSearch = m.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
                            m.description.toLowerCase().contains(state.searchQuery.toLowerCase());
      bool matchesFilter = true;
      if (state.filter == 'Enabled') matchesFilter = m.isEnabled && !m.isFuture;
      if (state.filter == 'Disabled') matchesFilter = !m.isEnabled && !m.isFuture;
      if (state.filter == 'Future') matchesFilter = m.isFuture;
      
      return matchesSearch && matchesFilter;
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Module Enablement'),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [
          if (state.hasUnsavedChanges)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: FilledButton.icon(
                  onPressed: state.isSaving ? null : () async {
                    await notifier.saveChanges();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Module configuration saved.')));
                    }
                  },
                  icon: state.isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(LucideIcons.save, size: 16),
                  label: Text(state.isSaving ? 'Saving...' : 'Save Changes'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(theme, state, notifier, isDesktop),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(24.0),
              itemCount: filteredModules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => _buildModuleCard(theme, filteredModules[index], notifier),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme, ModuleEnablementState state, ModuleEnablementNotifier notifier, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      color: theme.colorScheme.surface,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: isDesktop ? 300 : double.infinity,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search modules...',
                prefixIcon: const Icon(LucideIcons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              onChanged: notifier.updateSearch,
            ),
          ),
          DropdownMenu<String>(
            initialSelection: state.filter,
            onSelected: (value) => notifier.updateFilter(value ?? 'All'),
            dropdownMenuEntries: const [
              DropdownMenuEntry(value: 'All', label: 'All Modules'),
              DropdownMenuEntry(value: 'Enabled', label: 'Enabled'),
              DropdownMenuEntry(value: 'Disabled', label: 'Disabled'),
              DropdownMenuEntry(value: 'Future', label: 'Coming Soon'),
            ],
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          OutlinedButton.icon(
            onPressed: notifier.bulkEnable,
            icon: const Icon(LucideIcons.checkSquare, size: 16),
            label: const Text('Bulk Enable'),
          ),
          OutlinedButton.icon(
            onPressed: notifier.bulkDisable,
            icon: const Icon(LucideIcons.xSquare, size: 16),
            label: const Text('Bulk Disable'),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(ThemeData theme, PackModule module, ModuleEnablementNotifier notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(module.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      if (module.isFuture) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                          ),
                          child: const Text('Coming Soon', style: TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(module.description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  if (module.dependencies.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: module.dependencies.map((dep) => Chip(
                        label: Text(dep, style: const TextStyle(fontSize: 12)),
                        avatar: const Icon(LucideIcons.link, size: 14),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        side: BorderSide.none,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Switch(
                  value: module.isEnabled,
                  onChanged: module.isFuture ? null : (val) => notifier.toggleModule(module.id, val),
                  activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  module.isFuture ? 'Unavailable' : (module.isEnabled ? 'Active' : 'Inactive'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: module.isFuture ? Colors.grey : (module.isEnabled ? Colors.green : Colors.red),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
