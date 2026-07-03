import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

// --- MOCK MODELS ---
enum NavItemType { group, module }

class NavBuilderItem {
  final String id;
  final String label;
  final IconData? icon;
  final NavItemType type;
  final bool isVisible;
  final List<NavBuilderItem> children;
  final String? moduleId;

  NavBuilderItem({
    required this.id,
    required this.label,
    required this.type,
    this.icon,
    this.isVisible = true,
    this.children = const [],
    this.moduleId,
  });

  NavBuilderItem copyWith({
    String? id,
    String? label,
    IconData? icon,
    NavItemType? type,
    bool? isVisible,
    List<NavBuilderItem>? children,
    String? moduleId,
  }) {
    return NavBuilderItem(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      isVisible: isVisible ?? this.isVisible,
      children: children ?? this.children,
      moduleId: moduleId ?? this.moduleId,
    );
  }
}

class AvailableModule {
  final String id;
  final String name;
  final IconData icon;
  final List<AvailableModule> children;

  const AvailableModule(this.id, this.name, this.icon, {this.children = const []});
}

// --- STATE & NOTIFIER ---
class NavigationBuilderState {
  final List<AvailableModule> availableModules;
  final List<NavBuilderItem> tree;
  final String? selectedItemId;
  final bool isSaving;
  final bool isPublishing;

  const NavigationBuilderState({
    this.availableModules = const [],
    this.tree = const [],
    this.selectedItemId,
    this.isSaving = false,
    this.isPublishing = false,
  });

  NavigationBuilderState copyWith({
    List<AvailableModule>? availableModules,
    List<NavBuilderItem>? tree,
    String? selectedItemId,
    bool? isSaving,
    bool? isPublishing,
  }) {
    return NavigationBuilderState(
      availableModules: availableModules ?? this.availableModules,
      tree: tree ?? this.tree,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      isSaving: isSaving ?? this.isSaving,
      isPublishing: isPublishing ?? this.isPublishing,
    );
  }
}

class NavigationBuilderNotifier extends Notifier<NavigationBuilderState> {
  @override
  NavigationBuilderState build() {
    return NavigationBuilderState(
      availableModules: [
        AvailableModule('mod_fin', 'Finance', LucideIcons.dollarSign, children: [
          AvailableModule('mod_fin_gl', 'General Ledger', LucideIcons.book),
          AvailableModule('mod_fin_ap', 'Accounts Payable', LucideIcons.arrowDownRight),
          AvailableModule('mod_fin_ar', 'Accounts Receivable', LucideIcons.arrowUpRight),
        ]),
        AvailableModule('mod_rep', 'Reports', LucideIcons.fileBarChart, children: [
          AvailableModule('mod_rep_sales', 'Sales Reports', LucideIcons.barChart),
          AvailableModule('mod_rep_fin', 'Financial Reports', LucideIcons.pieChart),
        ]),
        AvailableModule('mod_ai', 'AI Features', LucideIcons.sparkles, children: [
          AvailableModule('mod_ai_pred', 'Predictions', LucideIcons.brain),
          AvailableModule('mod_ai_chat', 'AI Assistant', LucideIcons.messageSquare),
        ]),
      ],
      tree: [
        NavBuilderItem(id: 'dash', label: 'Dashboard', type: NavItemType.module, icon: LucideIcons.layoutDashboard, moduleId: 'mod_dash'),
        NavBuilderItem(id: 'sales', label: 'Sales', type: NavItemType.group, icon: LucideIcons.shoppingCart, children: [
          NavBuilderItem(id: 'cust', label: 'Customers', type: NavItemType.module, moduleId: 'mod_cust'),
          NavBuilderItem(id: 'quo', label: 'Quotations', type: NavItemType.module, moduleId: 'mod_quo'),
          NavBuilderItem(id: 'ord', label: 'Orders', type: NavItemType.module, moduleId: 'mod_ord'),
        ]),
        NavBuilderItem(id: 'mfg', label: 'Manufacturing', type: NavItemType.group, icon: LucideIcons.factory, children: [
          NavBuilderItem(id: 'prod', label: 'Products', type: NavItemType.module, moduleId: 'mod_prod'),
          NavBuilderItem(id: 'bom', label: 'BOM', type: NavItemType.module, moduleId: 'mod_bom'),
          NavBuilderItem(id: 'prc', label: 'Production', type: NavItemType.module, moduleId: 'mod_prc'),
        ]),
        NavBuilderItem(id: 'inv', label: 'Inventory', type: NavItemType.group, icon: LucideIcons.package, children: [
          NavBuilderItem(id: 'whs', label: 'Warehouses', type: NavItemType.module, moduleId: 'mod_whs'),
          NavBuilderItem(id: 'stc', label: 'Stock Movements', type: NavItemType.module, moduleId: 'mod_stc'),
          NavBuilderItem(id: 'val', label: 'Valuation', type: NavItemType.module, moduleId: 'mod_val'),
        ]),
      ],
    );
  }

  void selectItem(String? id) {
    state = state.copyWith(selectedItemId: id);
  }

  void createGroup() {
    final newGroup = NavBuilderItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: 'New Group',
      type: NavItemType.group,
      icon: LucideIcons.folder,
    );
    state = state.copyWith(tree: [...state.tree, newGroup], selectedItemId: newGroup.id);
  }

  void updateSelectedLabel(String label) {
    if (state.selectedItemId == null) return;
    _updateTreeItem(state.selectedItemId!, (item) => item.copyWith(label: label));
  }

  void toggleSelectedVisibility(bool isVisible) {
    if (state.selectedItemId == null) return;
    _updateTreeItem(state.selectedItemId!, (item) => item.copyWith(isVisible: isVisible));
  }

  void addModuleToTree(AvailableModule module) {
    final newItem = NavBuilderItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: module.name,
      type: module.children.isEmpty ? NavItemType.module : NavItemType.group,
      icon: module.icon,
      moduleId: module.id,
      children: module.children.map((child) => NavBuilderItem(
        id: DateTime.now().microsecondsSinceEpoch.toString() + child.id,
        label: child.name,
        type: NavItemType.module,
        icon: child.icon,
        moduleId: child.id,
      )).toList(),
    );
    // Remove from available and add to end of tree
    state = state.copyWith(
      availableModules: state.availableModules.where((m) => m.id != module.id).toList(),
      tree: [...state.tree, newItem],
      selectedItemId: newItem.id,
    );
  }

  void _updateTreeItem(String id, NavBuilderItem Function(NavBuilderItem) updateFn) {
    List<NavBuilderItem> walk(List<NavBuilderItem> nodes) {
      return nodes.map((node) {
        if (node.id == id) {
          return updateFn(node);
        }
        if (node.children.isNotEmpty) {
          return node.copyWith(children: walk(node.children));
        }
        return node;
      }).toList();
    }
    state = state.copyWith(tree: walk(state.tree));
  }

  // Simplified moving mechanism for mock purposes
  void moveSelectedUp() {
    if (state.selectedItemId == null) return;
    state = state.copyWith(tree: _moveItem(state.tree, state.selectedItemId!, -1));
  }

  void moveSelectedDown() {
    if (state.selectedItemId == null) return;
    state = state.copyWith(tree: _moveItem(state.tree, state.selectedItemId!, 1));
  }

  List<NavBuilderItem> _moveItem(List<NavBuilderItem> list, String id, int offset) {
    // Attempt at root level
    final index = list.indexWhere((item) => item.id == id);
    if (index != -1) {
      final newIndex = index + offset;
      if (newIndex >= 0 && newIndex < list.length) {
        final newList = List<NavBuilderItem>.from(list);
        final item = newList.removeAt(index);
        newList.insert(newIndex, item);
        return newList;
      }
      return list;
    }
    // Attempt in children
    return list.map((node) {
      if (node.children.isNotEmpty) {
        return node.copyWith(children: _moveItem(node.children, id, offset));
      }
      return node;
    }).toList();
  }

  Future<void> save() async {
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(isSaving: false);
  }

  Future<void> publish() async {
    state = state.copyWith(isPublishing: true);
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(isPublishing: false);
  }
}

final navigationBuilderProvider = NotifierProvider<NavigationBuilderNotifier, NavigationBuilderState>(NavigationBuilderNotifier.new);

// --- SCREEN ---
class NavigationBuilderScreen extends ConsumerStatefulWidget {
  const NavigationBuilderScreen({super.key});

  @override
  ConsumerState<NavigationBuilderScreen> createState() => _NavigationBuilderScreenState();
}

class _NavigationBuilderScreenState extends ConsumerState<NavigationBuilderScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(navigationBuilderProvider);
    final notifier = ref.read(navigationBuilderProvider.notifier);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Navigation Builder'),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.eye, size: 16),
            label: const Text('Preview'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: state.isSaving ? null : () async {
              await notifier.save();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved draft.')));
            },
            icon: state.isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.save, size: 16),
            label: Text(state.isSaving ? 'Saving...' : 'Save'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: state.isPublishing ? null : () async {
              await notifier.publish();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigation published successfully.')));
            },
            icon: state.isPublishing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(LucideIcons.send, size: 16),
            label: Text(state.isPublishing ? 'Publishing...' : 'Publish'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isDesktop ? _buildDesktopLayout(theme, state, notifier) : _buildMobileLayout(theme, state, notifier),
    );
  }

  Widget _buildDesktopLayout(ThemeData theme, NavigationBuilderState state, NavigationBuilderNotifier notifier) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column
        SizedBox(
          width: 300,
          child: Column(
            children: [
              _buildPanelHeader(theme, 'Available Modules'),
              Expanded(child: _buildAvailableModules(theme, state, notifier)),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Center Column
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildPanelHeader(
                theme, 
                'Navigation Tree',
                action: TextButton.icon(
                  onPressed: notifier.createGroup, 
                  icon: const Icon(LucideIcons.folderPlus, size: 16), 
                  label: const Text('Create Group'),
                ),
              ),
              Expanded(child: _buildNavigationTree(theme, state, notifier)),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right Column
        SizedBox(
          width: 350,
          child: Column(
            children: [
              _buildPanelHeader(theme, 'Properties'),
              Expanded(child: _buildPropertiesPanel(theme, state, notifier)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(ThemeData theme, NavigationBuilderState state, NavigationBuilderNotifier notifier) {
    return ListView(
      children: [
        _buildPanelHeader(theme, 'Navigation Tree',
            action: TextButton.icon(
              onPressed: notifier.createGroup, 
              icon: const Icon(LucideIcons.folderPlus, size: 16), 
              label: const Text('Create Group'),
            ),
        ),
        SizedBox(
          height: 400,
          child: _buildNavigationTree(theme, state, notifier),
        ),
        const Divider(height: 1),
        _buildPanelHeader(theme, 'Properties'),
        SizedBox(
          height: 300,
          child: _buildPropertiesPanel(theme, state, notifier),
        ),
        const Divider(height: 1),
        _buildPanelHeader(theme, 'Available Modules'),
        SizedBox(
          height: 300,
          child: _buildAvailableModules(theme, state, notifier),
        ),
      ],
    );
  }

  Widget _buildPanelHeader(ThemeData theme, String title, {Widget? action}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildAvailableModules(ThemeData theme, NavigationBuilderState state, NavigationBuilderNotifier notifier) {
    if (state.availableModules.isEmpty) {
      return const Center(child: Text('No available modules left.'));
    }
    return ListView.builder(
      itemCount: state.availableModules.length,
      itemBuilder: (context, index) {
        final module = state.availableModules[index];
        return ListTile(
          leading: Icon(module.icon, size: 20),
          title: Text(module.name),
          trailing: IconButton(
            icon: const Icon(LucideIcons.plus, size: 18),
            onPressed: () => notifier.addModuleToTree(module),
          ),
        );
      },
    );
  }

  Widget _buildNavigationTree(ThemeData theme, NavigationBuilderState state, NavigationBuilderNotifier notifier) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: state.tree.map((node) => _buildTreeNode(theme, node, state.selectedItemId, notifier, 0)).toList(),
    );
  }

  Widget _buildTreeNode(ThemeData theme, NavBuilderItem node, String? selectedId, NavigationBuilderNotifier notifier, int depth) {
    final isSelected = node.id == selectedId;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => notifier.selectItem(node.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: EdgeInsets.only(left: 8.0 + (depth * 24.0), top: 8, bottom: 8, right: 8),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.5) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.gripVertical, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                if (node.icon != null) ...[
                  Icon(node.icon, size: 18, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    node.label,
                    style: TextStyle(
                      fontWeight: node.type == NavItemType.group ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      decoration: node.isVisible ? TextDecoration.none : TextDecoration.lineThrough,
                    ),
                  ),
                ),
                if (!node.isVisible)
                  Icon(LucideIcons.eyeOff, size: 16, color: theme.colorScheme.onSurfaceVariant),
                if (node.type == NavItemType.group)
                  const SizedBox(width: 8),
                if (node.type == NavItemType.group)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('GROUP', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        ),
        if (node.children.isNotEmpty)
          ...node.children.map((child) => _buildTreeNode(theme, child, selectedId, notifier, depth + 1)),
      ],
    );
  }

  Widget _buildPropertiesPanel(ThemeData theme, NavigationBuilderState state, NavigationBuilderNotifier notifier) {
    if (state.selectedItemId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.mousePointerClick, size: 48, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text('Select an item to edit its properties'),
          ],
        ),
      );
    }

    NavBuilderItem? findItem(List<NavBuilderItem> items, String id) {
      for (var item in items) {
        if (item.id == id) return item;
        final child = findItem(item.children, id);
        if (child != null) return child;
      }
      return null;
    }

    final selectedItem = findItem(state.tree, state.selectedItemId!);
    if (selectedItem == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('Edit ${selectedItem.type == NavItemType.group ? 'Group' : 'Module'}', style: theme.textTheme.titleMedium),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: selectedItem.label,
          decoration: const InputDecoration(
            labelText: 'Label',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) => notifier.updateSelectedLabel(val),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text('Visible in Navigation'),
          value: selectedItem.isVisible,
          onChanged: (val) => notifier.toggleSelectedVisibility(val),
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(height: 48),
        Text('Reorder', style: theme.textTheme.titleSmall),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: notifier.moveSelectedUp,
                icon: const Icon(LucideIcons.arrowUp, size: 16),
                label: const Text('Move Up'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: notifier.moveSelectedDown,
                icon: const Icon(LucideIcons.arrowDown, size: 16),
                label: const Text('Move Down'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
