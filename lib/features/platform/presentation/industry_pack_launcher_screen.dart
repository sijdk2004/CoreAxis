import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

// --- MOCK MODELS ---
class IndustryPack {
  final String id;
  final String name;
  final String industry;
  final String status;
  final String version;
  final List<String> modules;
  final bool isInstalled;
  final Color themeColor;

  IndustryPack({
    required this.id,
    required this.name,
    required this.industry,
    required this.status,
    required this.version,
    required this.modules,
    required this.isInstalled,
    required this.themeColor,
  });
}

final _mockPacks = [
  IndustryPack(
    id: 'pack_furni',
    name: 'FurniFlow',
    industry: 'Furniture Manufacturing',
    status: 'Installed',
    version: '1.0',
    modules: ['Dashboard', 'CRM', 'Quotations', 'Sales Orders', 'Product Catalog', 'BOM', 'Production', 'Inventory', 'Delivery', 'Finance'],
    isInstalled: true,
    themeColor: const Color(0xFF2563EB), // Blue
  ),
  IndustryPack(
    id: 'pack_steel',
    name: 'SteelFlow',
    industry: 'Manufacturing',
    status: 'Coming Soon',
    version: 'Alpha',
    modules: ['Metallurgy', 'Heavy Logistics', 'Asset Tracking', 'Compliance'],
    isInstalled: false,
    themeColor: const Color(0xFF64748B), // Slate
  ),
  IndustryPack(
    id: 'pack_garment',
    name: 'GarmentFlow',
    industry: 'Retail & Apparel',
    status: 'Coming Soon',
    version: 'Beta',
    modules: ['Textile BOM', 'Size Matrix', 'Vendor Portal'],
    isInstalled: false,
    themeColor: const Color(0xFFE11D48), // Rose
  ),
  IndustryPack(
    id: 'pack_kitchen',
    name: 'KitchenFlow',
    industry: 'Manufacturing',
    status: 'Coming Soon',
    version: 'Alpha',
    modules: ['Custom Designs', 'Installation Scheduling'],
    isInstalled: false,
    themeColor: const Color(0xFFD97706), // Amber
  ),
  IndustryPack(
    id: 'pack_construction',
    name: 'ConstructionFlow',
    industry: 'Construction',
    status: 'Coming Soon',
    version: 'Planning',
    modules: ['Site Management', 'Subcontractors', 'Equipment'],
    isInstalled: false,
    themeColor: const Color(0xFFEA580C), // Orange
  ),
  IndustryPack(
    id: 'pack_retail',
    name: 'RetailFlow',
    industry: 'Retail',
    status: 'Coming Soon',
    version: 'Beta',
    modules: ['POS', 'Store Management', 'Loyalty'],
    isInstalled: false,
    themeColor: const Color(0xFF059669), // Emerald
  ),
  IndustryPack(
    id: 'pack_pharma',
    name: 'PharmaFlow',
    industry: 'Healthcare',
    status: 'Coming Soon',
    version: 'Alpha',
    modules: ['Compliance', 'Batch Tracking', 'Expiry Mgmt'],
    isInstalled: false,
    themeColor: const Color(0xFF0EA5E9), // Sky
  ),
  IndustryPack(
    id: 'pack_education',
    name: 'EducationFlow',
    industry: 'Education',
    status: 'Coming Soon',
    version: 'Planning',
    modules: ['Admissions', 'Syllabus', 'Alumni'],
    isInstalled: false,
    themeColor: const Color(0xFF7C3AED), // Violet
  ),
  IndustryPack(
    id: 'pack_hospital',
    name: 'HospitalFlow',
    industry: 'Healthcare',
    status: 'Coming Soon',
    version: 'Alpha',
    modules: ['Patient Records', 'Wards', 'Pharmacy'],
    isInstalled: false,
    themeColor: const Color(0xFF0F766E), // Teal
  ),
];

// --- STATE ---
class IndustryPackLauncherState {
  final String searchQuery;
  final String selectedCategory;

  const IndustryPackLauncherState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
  });

  IndustryPackLauncherState copyWith({
    String? searchQuery,
    String? selectedCategory,
  }) {
    return IndustryPackLauncherState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class IndustryPackLauncherNotifier extends Notifier<IndustryPackLauncherState> {
  @override
  IndustryPackLauncherState build() => const IndustryPackLauncherState();

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }
}

final industryPackLauncherProvider = NotifierProvider<IndustryPackLauncherNotifier, IndustryPackLauncherState>(IndustryPackLauncherNotifier.new);

// --- SCREEN ---
class IndustryPackLauncherScreen extends ConsumerStatefulWidget {
  const IndustryPackLauncherScreen({super.key});

  @override
  ConsumerState<IndustryPackLauncherScreen> createState() => _IndustryPackLauncherScreenState();
}

class _IndustryPackLauncherScreenState extends ConsumerState<IndustryPackLauncherScreen> {
  final List<String> _categories = ['All', 'Manufacturing', 'Retail', 'Healthcare', 'Construction', 'Education'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(industryPackLauncherProvider);
    final notifier = ref.read(industryPackLauncherProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    // Filter packs
    final filteredPacks = _mockPacks.where((pack) {
      final matchesSearch = pack.name.toLowerCase().contains(state.searchQuery.toLowerCase()) || 
                            pack.modules.any((m) => m.toLowerCase().contains(state.searchQuery.toLowerCase()));
      final matchesCategory = state.selectedCategory == 'All' || pack.industry.contains(state.selectedCategory);
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildHeroBanner(theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchAndFilter(theme, state, notifier),
                  const SizedBox(height: 32),
                  Text('Installed Packs', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildPacksGrid(theme, filteredPacks.where((p) => p.isInstalled).toList(), isDesktop, true),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coming Soon', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildPacksGrid(theme, filteredPacks.where((p) => !p.isInstalled).toList(), isDesktop, false),
          const SliverToBoxAdapter(child: SizedBox(height: 64)),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        height: 200.0,
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative background pattern
            Positioned(
              right: -50,
              top: -50,
              child: Icon(LucideIcons.boxes, size: 300, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Welcome to ERP Platform',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Launch your business applications.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme, IndustryPackLauncherState state, IndustryPackLauncherNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search packs or modules...',
                  prefixIcon: const Icon(LucideIcons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: notifier.updateSearch,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((category) {
                    final isSelected = state.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (_) => notifier.updateCategory(category),
                        selectedColor: theme.colorScheme.primaryContainer,
                        checkmarkColor: theme.colorScheme.onPrimaryContainer,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPacksGrid(ThemeData theme, List<IndustryPack> packs, bool isDesktop, bool installed) {
    if (packs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text('No packs found matching your criteria.', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
        ),
      );
    }

    int crossAxisCount = isDesktop ? 3 : 1;
    // On very wide screens we might want 4
    if (MediaQuery.of(context).size.width > 1400) {
      crossAxisCount = 4;
    } else if (MediaQuery.of(context).size.width > 1000) {
      crossAxisCount = 3;
    } else if (MediaQuery.of(context).size.width > 600) {
      crossAxisCount = 2;
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 24.0,
          crossAxisSpacing: 24.0,
          mainAxisExtent: installed ? 360 : 180, // Installed cards need more height
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return installed 
                ? _buildInstalledCard(theme, packs[index])
                : _buildComingSoonCard(theme, packs[index]);
          },
          childCount: packs.length,
        ),
      ),
    );
  }

  Widget _buildInstalledCard(ThemeData theme, IndustryPack pack) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: pack.themeColor.withValues(alpha: 0.3), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pack.themeColor.withValues(alpha: 0.1),
              border: Border(bottom: BorderSide(color: pack.themeColor.withValues(alpha: 0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: pack.themeColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.package, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pack.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: pack.themeColor), overflow: TextOverflow.ellipsis),
                            Text(pack.industry, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(pack.status, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          
          // Modules section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Modules', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text('v${pack.version}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: pack.modules.map((m) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(m, style: const TextStyle(fontSize: 11)),
                        )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: pack.themeColor),
                  icon: const Icon(LucideIcons.rocket, size: 16),
                  label: const Text('Launch'),
                  onPressed: () {
                    if (pack.name == 'FurniFlow') {
                      context.go('/platform/pack/furniflow');
                    }
                  },
                ),
                OutlinedButton(
                  onPressed: () {
                    context.go('/platform/industry-packs/pack_furni'); // Use mock id
                  },
                  child: const Text('Details'),
                ),
                IconButton.outlined(
                  icon: const Icon(LucideIcons.settings, size: 18),
                  onPressed: () {
                    context.go('/platform/industry-packs/pack_furni'); // Use mock id
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonCard(ThemeData theme, IndustryPack pack) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: pack.themeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Stack(
        children: [
          // Background icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(LucideIcons.boxes, size: 100, color: pack.themeColor.withValues(alpha: 0.1)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(LucideIcons.package, color: pack.themeColor),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.clock, size: 12, color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(pack.status, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(pack.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text(pack.industry, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Text(pack.modules.take(2).join(', ') + (pack.modules.length > 2 ? '...' : ''), 
                     style: theme.textTheme.bodySmall?.copyWith(color: pack.themeColor, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
