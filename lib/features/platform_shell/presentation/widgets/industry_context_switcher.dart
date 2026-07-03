import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// --- MOCK DATA ---
class IndustryContextItem {
  final String id;
  final String name;
  final String industry;
  final String version;
  final String status;
  final IconData icon;
  final bool isPinned;
  final bool isRecent;

  IndustryContextItem({
    required this.id,
    required this.name,
    required this.industry,
    required this.version,
    required this.status,
    required this.icon,
    this.isPinned = false,
    this.isRecent = false,
  });
}

final _mockContexts = [
  IndustryContextItem(id: 'erp_core', name: 'ERP Platform', industry: 'Core Framework', version: '2.0.1', status: 'Active', icon: LucideIcons.boxes, isPinned: true),
  IndustryContextItem(id: 'inst_furni', name: 'FurniFlow', industry: 'Furniture Mfg', version: '1.2.4', status: 'Active', icon: LucideIcons.sofa, isRecent: true, isPinned: true),
  IndustryContextItem(id: 'pack_steel', name: 'SteelFlow', industry: 'Metal Fabrication', version: '1.0.8', status: 'Maintenance', icon: LucideIcons.anvil, isRecent: true),
  IndustryContextItem(id: 'pack_garment', name: 'GarmentFlow', industry: 'Apparel Mfg', version: '1.1.2', status: 'Active', icon: LucideIcons.shirt),
  IndustryContextItem(id: 'pack_kitchen', name: 'KitchenFlow', industry: 'Cabinetry', version: '0.9.8', status: 'Beta', icon: LucideIcons.chefHat),
  IndustryContextItem(id: 'pack_construct', name: 'ConstructionFlow', industry: 'Contracting', version: '1.4.0', status: 'Active', icon: LucideIcons.hardHat),
];

// --- STATE ---
class ContextSwitcherState {
  final IndustryContextItem activeContext;
  final bool isSwitching;

  ContextSwitcherState({required this.activeContext, this.isSwitching = false});
}

class ContextSwitcherNotifier extends Notifier<ContextSwitcherState> {
  @override
  ContextSwitcherState build() {
    return ContextSwitcherState(activeContext: _mockContexts.first);
  }

  Future<void> switchContext(BuildContext context, IndustryContextItem newItem) async {
    state = ContextSwitcherState(activeContext: state.activeContext, isSwitching: true);
    
    // Simulate complex context switch (fetching config, tearing down state, etc)
    await Future.delayed(const Duration(milliseconds: 1200));
    
    state = ContextSwitcherState(activeContext: newItem, isSwitching: false);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully switched context to ${newItem.name}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      // Navigate to dashboard if it's an industry pack, otherwise platform home
      if (newItem.id == 'erp_core') {
        context.go('/platform/dashboard');
      } else {
        context.go('/platform/industry-packs/${newItem.id}/dashboard');
      }
    }
  }
}

final contextSwitcherProvider = NotifierProvider<ContextSwitcherNotifier, ContextSwitcherState>(ContextSwitcherNotifier.new);

// --- COMPONENT ---
class IndustryContextSwitcher extends ConsumerStatefulWidget {
  const IndustryContextSwitcher({super.key});

  @override
  ConsumerState<IndustryContextSwitcher> createState() => _IndustryContextSwitcherState();
}

class _IndustryContextSwitcherState extends ConsumerState<IndustryContextSwitcher> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';
  
  void _toggleDropdown() {
    if (_overlayEntry != null) {
      _closeDropdown();
    } else {
      _showDropdown();
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _searchQuery = '';
    });
  }

  void _showDropdown() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final theme = Theme.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: 380,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 8),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
              shadowColor: Colors.black26,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _DropdownMenuContent(
                  searchQuery: _searchQuery,
                  onSearchChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                    _overlayEntry?.markNeedsBuild();
                  },
                  onItemTap: (item) {
                    _closeDropdown();
                    ref.read(contextSwitcherProvider.notifier).switchContext(context, item);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contextSwitcherProvider);
    final theme = Theme.of(context);
    final isActive = _overlayEntry != null;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Material(
        color: isActive ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: state.isSwitching ? null : _toggleDropdown,
          borderRadius: BorderRadius.circular(8),
          hoverColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.isSwitching)
                  const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                else
                  Icon(state.activeContext.icon, color: theme.colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.activeContext.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      state.activeContext.industry,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Icon(
                  isActive ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownMenuContent extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<IndustryContextItem> onItemTap;

  const _DropdownMenuContent({
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final filtered = _mockContexts.where((item) => 
      item.name.toLowerCase().contains(searchQuery.toLowerCase()) || 
      item.industry.toLowerCase().contains(searchQuery.toLowerCase())
    ).toList();

    final pinned = filtered.where((e) => e.isPinned).toList();
    final recent = filtered.where((e) => e.isRecent && !e.isPinned).toList();
    final others = filtered.where((e) => !e.isPinned && !e.isRecent).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search packs...',
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: theme.dividerColor),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
            onChanged: onSearchChanged,
          ),
        ),
        const Divider(height: 1),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pinned.isNotEmpty) ...[
                  _buildSectionHeader(theme, 'Pinned'),
                  ...pinned.map((e) => _buildContextTile(context, theme, e)),
                  const Divider(height: 1),
                ],
                if (recent.isNotEmpty) ...[
                  _buildSectionHeader(theme, 'Recent'),
                  ...recent.map((e) => _buildContextTile(context, theme, e)),
                  const Divider(height: 1),
                ],
                if (others.isNotEmpty) ...[
                  _buildSectionHeader(theme, 'All Contexts'),
                  ...others.map((e) => _buildContextTile(context, theme, e)),
                ],
                if (filtered.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text('No contexts found')),
                  ),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        InkWell(
          onTap: () {
            // Action for navigating to context manager
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.settings, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Manage Environments', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildContextTile(BuildContext context, ThemeData theme, IndustryContextItem item) {
    return InkWell(
      onTap: () => onItemTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: theme.colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.status == 'Active' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.status, style: TextStyle(fontSize: 10, color: item.status == 'Active' ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('${item.industry} • v${item.version}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
