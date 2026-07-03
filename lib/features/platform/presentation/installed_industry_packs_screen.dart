import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

// --- MOCK MODELS ---
enum PackStatus { enabled, disabled, pendingUpdate }

class InstalledPack {
  final String id;
  final String name;
  final String industry;
  final String version;
  final List<String> modules;
  final DateTime installationDate;
  final PackStatus status;
  final Color themeColor;
  final IconData icon;

  InstalledPack({
    required this.id,
    required this.name,
    required this.industry,
    required this.version,
    required this.modules,
    required this.installationDate,
    required this.status,
    required this.themeColor,
    required this.icon,
  });

  InstalledPack copyWith({
    String? id,
    String? name,
    String? industry,
    String? version,
    List<String>? modules,
    DateTime? installationDate,
    PackStatus? status,
    Color? themeColor,
    IconData? icon,
  }) {
    return InstalledPack(
      id: id ?? this.id,
      name: name ?? this.name,
      industry: industry ?? this.industry,
      version: version ?? this.version,
      modules: modules ?? this.modules,
      installationDate: installationDate ?? this.installationDate,
      status: status ?? this.status,
      themeColor: themeColor ?? this.themeColor,
      icon: icon ?? this.icon,
    );
  }
}

final _mockInstalledPacks = [
  InstalledPack(
    id: 'inst_furni',
    name: 'FurniFlow',
    industry: 'Furniture Manufacturing',
    version: '1.2.4',
    modules: ['CRM', 'Quotations', 'Production'],
    installationDate: DateTime.now().subtract(const Duration(days: 45)),
    status: PackStatus.enabled,
    themeColor: const Color(0xFF2563EB),
    icon: LucideIcons.sofa,
  ),
  InstalledPack(
    id: 'inst_steel',
    name: 'SteelFlow',
    industry: 'Manufacturing',
    version: '0.9.1',
    modules: ['Metallurgy', 'Logistics'],
    installationDate: DateTime.now().subtract(const Duration(days: 12)),
    status: PackStatus.pendingUpdate,
    themeColor: const Color(0xFF64748B),
    icon: LucideIcons.anvil,
  ),
  InstalledPack(
    id: 'inst_retail',
    name: 'RetailFlow',
    industry: 'Retail',
    version: '2.0.0',
    modules: ['POS', 'Store Mgmt'],
    installationDate: DateTime.now().subtract(const Duration(days: 120)),
    status: PackStatus.disabled,
    themeColor: const Color(0xFF059669),
    icon: LucideIcons.store,
  ),
];

// --- STATE ---
class InstalledIndustryPacksState {
  final List<InstalledPack> packs;
  final String searchQuery;
  final bool isLoading;

  const InstalledIndustryPacksState({
    required this.packs,
    this.searchQuery = '',
    this.isLoading = false,
  });

  InstalledIndustryPacksState copyWith({
    List<InstalledPack>? packs,
    String? searchQuery,
    bool? isLoading,
  }) {
    return InstalledIndustryPacksState(
      packs: packs ?? this.packs,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get totalInstalled => packs.length;
  int get totalEnabled => packs.where((p) => p.status == PackStatus.enabled).length;
  int get totalDisabled => packs.where((p) => p.status == PackStatus.disabled).length;
  int get totalPending => packs.where((p) => p.status == PackStatus.pendingUpdate).length;
}

class InstalledIndustryPacksNotifier extends Notifier<InstalledIndustryPacksState> {
  @override
  InstalledIndustryPacksState build() {
    return InstalledIndustryPacksState(packs: _mockInstalledPacks);
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isLoading: false);
  }

  void toggleStatus(String id) {
    final newPacks = state.packs.map((pack) {
      if (pack.id == id) {
        if (pack.status == PackStatus.enabled) {
          return pack.copyWith(status: PackStatus.disabled);
        } else if (pack.status == PackStatus.disabled) {
          return pack.copyWith(status: PackStatus.enabled);
        }
      }
      return pack;
    }).toList();
    state = state.copyWith(packs: newPacks);
  }

  void upgradePack(String id) {
    final newPacks = state.packs.map((pack) {
      if (pack.id == id && pack.status == PackStatus.pendingUpdate) {
        return pack.copyWith(status: PackStatus.enabled, version: '1.0.0'); // Mock upgrade
      }
      return pack;
    }).toList();
    state = state.copyWith(packs: newPacks);
  }

  void uninstallPack(String id) {
    final newPacks = state.packs.where((pack) => pack.id != id).toList();
    state = state.copyWith(packs: newPacks);
  }
}

final installedIndustryPacksProvider = NotifierProvider<InstalledIndustryPacksNotifier, InstalledIndustryPacksState>(InstalledIndustryPacksNotifier.new);

// --- SCREEN ---
class InstalledIndustryPacksScreen extends ConsumerStatefulWidget {
  const InstalledIndustryPacksScreen({super.key});

  @override
  ConsumerState<InstalledIndustryPacksScreen> createState() => _InstalledIndustryPacksScreenState();
}

class _InstalledIndustryPacksScreenState extends ConsumerState<InstalledIndustryPacksScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(installedIndustryPacksProvider);
    final notifier = ref.read(installedIndustryPacksProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    final filteredPacks = state.packs.where((pack) {
      return pack.name.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
             pack.industry.toLowerCase().contains(state.searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Installed Industry Packs'),
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatisticsRow(theme, state, isDesktop),
                const SizedBox(height: 32),
                _buildToolbar(theme, notifier),
                const SizedBox(height: 24),
                _buildDataTable(theme, filteredPacks, notifier, isDesktop),
              ],
            ),
          ),
    );
  }

  Widget _buildStatisticsRow(ThemeData theme, InstalledIndustryPacksState state, bool isDesktop) {
    if (isDesktop) {
      return Row(
        children: [
          Expanded(child: _buildStatCard(theme, 'Installed Packs', state.totalInstalled.toString(), LucideIcons.packageCheck, Colors.blue)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(theme, 'Enabled', state.totalEnabled.toString(), LucideIcons.checkCircle, Colors.green)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(theme, 'Disabled', state.totalDisabled.toString(), LucideIcons.pauseCircle, Colors.grey)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(theme, 'Pending Updates', state.totalPending.toString(), LucideIcons.arrowUpCircle, Colors.orange)),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard(theme, 'Installed Packs', state.totalInstalled.toString(), LucideIcons.packageCheck, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(theme, 'Enabled', state.totalEnabled.toString(), LucideIcons.checkCircle, Colors.green)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard(theme, 'Disabled', state.totalDisabled.toString(), LucideIcons.pauseCircle, Colors.grey)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(theme, 'Pending Updates', state.totalPending.toString(), LucideIcons.arrowUpCircle, Colors.orange)),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildStatCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme, InstalledIndustryPacksNotifier notifier) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search installed packs...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: notifier.updateSearch,
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () => notifier.refresh(),
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          label: const Text('Refresh'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting report...')));
          },
          icon: const Icon(LucideIcons.download, size: 16),
          label: const Text('Export'),
        ),
      ],
    );
  }

  Widget _buildDataTable(ThemeData theme, List<InstalledPack> packs, InstalledIndustryPacksNotifier notifier, bool isDesktop) {
    if (packs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(64.0),
          child: Text('No installed packs found.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
        ),
      );
    }

    if (!isDesktop) {
      // Mobile/Tablet layout: List of cards
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: packs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildMobilePackCard(theme, packs[index], notifier),
      );
    }

    // Desktop layout: Data Table
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
          columnSpacing: 32,
          columns: const [
            DataColumn(label: Text('Pack Name')),
            DataColumn(label: Text('Industry')),
            DataColumn(label: Text('Version')),
            DataColumn(label: Text('Modules')),
            DataColumn(label: Text('Installation Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: packs.map((pack) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: pack.themeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                        child: Icon(pack.icon, color: pack.themeColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Text(pack.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                DataCell(Text(pack.industry)),
                DataCell(Text('v${pack.version}')),
                DataCell(
                  SizedBox(
                    width: 150, // Constraint width for modules wrap
                    child: Text(pack.modules.join(', '), overflow: TextOverflow.ellipsis),
                  ),
                ),
                DataCell(Text('${pack.installationDate.year}-${pack.installationDate.month.toString().padLeft(2, '0')}-${pack.installationDate.day.toString().padLeft(2, '0')}')),
                DataCell(_buildStatusBadge(theme, pack.status)),
                DataCell(_buildActionsMenu(theme, pack, notifier)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobilePackCard(ThemeData theme, InstalledPack pack, InstalledIndustryPacksNotifier notifier) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: pack.themeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(pack.icon, color: pack.themeColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pack.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('v${pack.version}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                _buildStatusBadge(theme, pack.status),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text('Industry: ${pack.industry}', style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('Modules: ${pack.modules.join(', ')}', style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (pack.status == PackStatus.enabled)
                  TextButton.icon(
                    onPressed: () {
                      if (pack.name == 'FurniFlow') context.go('/platform/pack/furniflow');
                    },
                    icon: const Icon(LucideIcons.rocket, size: 16),
                    label: const Text('Launch'),
                  ),
                _buildActionsMenu(theme, pack, notifier),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, PackStatus status) {
    Color color;
    String text;

    switch (status) {
      case PackStatus.enabled:
        color = Colors.green;
        text = 'Enabled';
        break;
      case PackStatus.disabled:
        color = Colors.grey;
        text = 'Disabled';
        break;
      case PackStatus.pendingUpdate:
        color = Colors.orange;
        text = 'Update Available';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionsMenu(ThemeData theme, InstalledPack pack, InstalledIndustryPacksNotifier notifier) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'details':
            context.go('/platform/industry-packs/${pack.id}');
            break;
          case 'launch':
            if (pack.name == 'FurniFlow') context.go('/platform/pack/furniflow');
            break;
          case 'configure':
            context.go('/platform/industry-packs/${pack.id}');
            break;
          case 'toggle':
            notifier.toggleStatus(pack.id);
            break;
          case 'upgrade':
            _showUpgradeDialog(theme, pack, notifier);
            break;
          case 'uninstall':
            _showUninstallDialog(theme, pack, notifier);
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'details',
          child: ListTile(
            leading: Icon(LucideIcons.info, size: 18),
            title: Text('View Details'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (pack.status == PackStatus.enabled) ...[
          const PopupMenuItem<String>(
            value: 'launch',
            child: ListTile(
              leading: Icon(LucideIcons.rocket, size: 18),
              title: Text('Launch'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem<String>(
            value: 'configure',
            child: ListTile(
              leading: Icon(LucideIcons.settings, size: 18),
              title: Text('Configure'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuDivider(),
        ],
        PopupMenuItem<String>(
          value: 'toggle',
          child: ListTile(
            leading: Icon(pack.status == PackStatus.enabled ? LucideIcons.pauseCircle : LucideIcons.playCircle, size: 18),
            title: Text(pack.status == PackStatus.enabled ? 'Disable' : 'Enable'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (pack.status == PackStatus.pendingUpdate)
          const PopupMenuItem<String>(
            value: 'upgrade',
            child: ListTile(
              leading: Icon(LucideIcons.arrowUpCircle, size: 18, color: Colors.orange),
              title: Text('Upgrade Pack', style: TextStyle(color: Colors.orange)),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'uninstall',
          child: ListTile(
            leading: Icon(LucideIcons.trash2, size: 18, color: Colors.red),
            title: Text('Uninstall', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  void _showUninstallDialog(ThemeData theme, InstalledPack pack, InstalledIndustryPacksNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Uninstall Pack'),
          content: Text('Are you sure you want to uninstall ${pack.name}? This action cannot be undone and will remove all associated modules and configuration data.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                notifier.uninstallPack(pack.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${pack.name} uninstalled successfully.')));
              },
              child: const Text('Uninstall'),
            ),
          ],
        );
      },
    );
  }

  void _showUpgradeDialog(ThemeData theme, InstalledPack pack, InstalledIndustryPacksNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Upgrade ${pack.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('A new version is available for ${pack.name}.'),
              const SizedBox(height: 16),
              Text('Current Version: ${pack.version}', style: theme.textTheme.bodySmall),
              Text('New Version: 1.0.0', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 16),
              const Text('Do you want to proceed with the upgrade? Your environment will not be available during this process.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                notifier.upgradePack(pack.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${pack.name} is upgrading in the background...')));
              },
              child: const Text('Start Upgrade'),
            ),
          ],
        );
      },
    );
  }
}
