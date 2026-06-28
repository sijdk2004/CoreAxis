import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/role_permission_matrix_provider.dart';

class RolePermissionMatrixScreen extends ConsumerStatefulWidget {
  const RolePermissionMatrixScreen({super.key});

  @override
  ConsumerState<RolePermissionMatrixScreen> createState() => _RolePermissionMatrixScreenState();
}

class _RolePermissionMatrixScreenState extends ConsumerState<RolePermissionMatrixScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _bodyScrollController = ScrollController();

  bool _isSyncingHeader = false;
  bool _isSyncingBody = false;

  final List<String> _categories = [
    'All',
    'Identity', 'Users', 'Reports', 'Sales', 'Finance', 'Inventory', 'System'
  ];

  @override
  void initState() {
    super.initState();
    _headerScrollController.addListener(() {
      if (_isSyncingBody) return;
      _isSyncingHeader = true;
      if (_bodyScrollController.hasClients && _headerScrollController.hasClients) {
        if (_bodyScrollController.offset != _headerScrollController.offset) {
          _bodyScrollController.jumpTo(_headerScrollController.offset);
        }
      }
      _isSyncingHeader = false;
    });

    _bodyScrollController.addListener(() {
      if (_isSyncingHeader) return;
      _isSyncingBody = true;
      if (_headerScrollController.hasClients && _bodyScrollController.hasClients) {
        if (_headerScrollController.offset != _bodyScrollController.offset) {
          _headerScrollController.jumpTo(_bodyScrollController.offset);
        }
      }
      _isSyncingBody = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerScrollController.dispose();
    _bodyScrollController.dispose();
    super.dispose();
  }

  void _showMockDialog(String title, [String? content]) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: content != null ? Text(content) : const Text('This feature is currently mocked for the UI prototype.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(rolePermissionMatrixProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: state.isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme, state),
              _buildToolbar(state, theme),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: PremiumCard(
                    padding: EdgeInsets.zero,
                    child: _buildMatrixGrid(state, theme),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader(ThemeData theme, MatrixState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.grid, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Role Permission Matrix', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Enterprise matrix view for managing permissions across roles', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: () => _showMockDialog('Export Excel', 'Exporting matrix to Excel...'),
            icon: const Icon(LucideIcons.fileSpreadsheet, size: 16),
            label: const Text('Export Excel'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: state.isSaving ? null : () async {
              await ref.read(rolePermissionMatrixProvider.notifier).saveChanges();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes saved successfully!')));
              }
            },
            icon: state.isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                : const Icon(LucideIcons.save, size: 16),
            label: Text(state.isSaving ? 'Saving...' : 'Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(MatrixState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => ref.read(rolePermissionMatrixProvider.notifier).setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search permissions...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: DropdownButtonFormField<String>(
              value: state.selectedCategory,
              decoration: InputDecoration(
                labelText: 'Filter Category',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(rolePermissionMatrixProvider.notifier).setCategoryFilter(val);
                }
              },
            ),
          ),
          const Spacer(),
          // Stats summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.shieldCheck, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${state.filteredPermissions.length} Permissions',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 16),
                Icon(LucideIcons.users, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '${state.roles.length} Roles',
                  style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMatrixGrid(MatrixState state, ThemeData theme) {
    if (state.filteredPermissions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Text('No permissions match the current filters.'),
        ),
      );
    }

    const double firstColumnWidth = 250.0;
    const double columnWidth = 140.0;
    const double rowHeight = 60.0;
    const double headerHeight = 70.0;

    return Column(
      children: [
        // Header Row (Sticky Roles)
        Container(
          height: headerHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            children: [
              // Top-left blank cell
              Container(
                width: firstColumnWidth,
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: theme.dividerColor)),
                ),
                child: const Text('PERMISSION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              // Role Headers (Scrollable Horizontally)
              Expanded(
                child: SingleChildScrollView(
                  controller: _headerScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: state.roles.map((role) {
                      return Container(
                        width: columnWidth,
                        padding: const EdgeInsets.all(12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: theme.dividerColor)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              role.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              role.code,
                              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Body (Scrollable Vertically)
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column (Sticky Permissions)
                SizedBox(
                  width: firstColumnWidth,
                  child: Column(
                    children: state.filteredPermissions.map((perm) {
                      return Container(
                        height: rowHeight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.dividerColor),
                            right: BorderSide(color: theme.dividerColor),
                          ),
                          color: theme.colorScheme.surface,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              perm.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              perm.code,
                              style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Grid Cells (Scrollable Horizontally)
                Expanded(
                  child: SingleChildScrollView(
                    controller: _bodyScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: state.filteredPermissions.map((perm) {
                        return Row(
                          children: state.roles.map((role) {
                            final isGranted = state.grid[perm.id]?[role.id] ?? false;
                            return Container(
                              width: columnWidth,
                              height: rowHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: theme.dividerColor),
                                  right: BorderSide(color: theme.dividerColor),
                                ),
                                color: isGranted ? theme.colorScheme.primaryContainer.withOpacity(0.2) : theme.colorScheme.surface,
                              ),
                              child: Checkbox(
                                value: isGranted,
                                onChanged: (val) {
                                  if (val != null) {
                                    ref.read(rolePermissionMatrixProvider.notifier).togglePermission(perm.id, role.id, val);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
