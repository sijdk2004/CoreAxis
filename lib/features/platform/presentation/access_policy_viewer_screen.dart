import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/access_policy_provider.dart';

class AccessPolicyViewerScreen extends ConsumerStatefulWidget {
  const AccessPolicyViewerScreen({super.key});

  @override
  ConsumerState<AccessPolicyViewerScreen> createState() => _AccessPolicyViewerScreenState();
}

class _AccessPolicyViewerScreenState extends ConsumerState<AccessPolicyViewerScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(accessPolicyProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                Expanded(
                  child: isDesktop
                      ? Row(
                          children: [
                            // Left: Policy List
                            SizedBox(width: 350, child: _buildLeftPane(theme, state)),
                            const VerticalDivider(width: 1),
                            // Center: Inheritance Tree
                            Expanded(flex: 5, child: _buildCenterPane(theme, state)),
                            const VerticalDivider(width: 1),
                            // Right: Policy Details
                            SizedBox(width: 350, child: _buildRightPane(theme, state)),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(flex: 2, child: _buildLeftPane(theme, state)),
                            const Divider(height: 1),
                            Expanded(flex: 3, child: _buildCenterPane(theme, state)),
                          ],
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
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
            child: Icon(LucideIcons.gitCommit, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Access Policy Viewer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Visualize IAM policies and permission inheritance', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPane(ThemeData theme, AccessPolicyState state) {
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref.read(accessPolicyProvider.notifier).setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search policies...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                isDense: true,
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: state.filteredPolicies.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final policy = state.filteredPolicies[index];
                final isSelected = state.selectedPolicyId == policy.id;
                
                Color typeColor;
                if (policy.type == 'Allow') typeColor = Colors.green;
                else if (policy.type == 'Deny') typeColor = Colors.red;
                else typeColor = Colors.orange;

                return ListTile(
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(policy.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(policy.resource, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: typeColor.withOpacity(0.3)),
                        ),
                        child: Text(policy.type.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: typeColor)),
                      ),
                    ],
                  ),
                  onTap: () => ref.read(accessPolicyProvider.notifier).selectPolicy(policy.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPane(ThemeData theme, AccessPolicyState state) {
    if (state.rootNode == null) return const SizedBox();

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.network, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                const Text('Role Inheritance Tree', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.download, size: 16),
                  label: const Text('Export Diagram'),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: _buildTreeNode(state.rootNode!, theme),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeNode(RoleTreeNode node, ThemeData theme, {bool isLast = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Node Card
            Container(
              width: 260,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
                ]
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                    ),
                    child: _getIcon(node.iconName, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Level ${node.level}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (node.children.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(LucideIcons.chevronDown, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    )
                ],
              ),
            ),
          ],
        ),
        if (node.children.isNotEmpty)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Vertical connector line
                Container(
                  width: 2,
                  margin: const EdgeInsets.only(left: 24, right: 24),
                  color: theme.dividerColor,
                ),
                // Children list
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: node.children.asMap().entries.map((entry) {
                      final child = entry.value;
                      final isLastChild = entry.key == node.children.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Horizontal elbow connector
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(top: 24),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: theme.dividerColor, width: 2),
                                left: BorderSide(color: isLastChild ? Colors.transparent : theme.dividerColor, width: 2),
                              )
                            ),
                          ),
                          _buildTreeNode(child, theme, isLast: isLastChild),
                        ],
                      );
                    }).toList(),
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildRightPane(ThemeData theme, AccessPolicyState state) {
    if (state.selectedPolicyId == null) {
      return Container(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.fileSearch, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text('Select an Access Policy from the left to view resolution details and conflicts.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ],
          ),
        ),
      );
    }

    final policy = state.policies.firstWhere((p) => p.id == state.selectedPolicyId);
    
    Color typeColor;
    if (policy.type == 'Allow') typeColor = Colors.green;
    else if (policy.type == 'Deny') typeColor = Colors.red;
    else typeColor = Colors.orange;

    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Policy Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      onPressed: () => ref.read(accessPolicyProvider.notifier).clearSelection(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(policy.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(policy.description, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Resolution Type'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: typeColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(policy.type == 'Allow' ? LucideIcons.checkCircle2 : policy.type == 'Deny' ? LucideIcons.xCircle : LucideIcons.alertCircle, color: typeColor, size: 16),
                        const SizedBox(width: 8),
                        Text(policy.type.toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: typeColor)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Resource Scope'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.code, color: Colors.green, size: 16),
                        const SizedBox(width: 12),
                        Text(policy.resource, style: const TextStyle(fontFamily: 'monospace', color: Colors.greenAccent, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Effective Roles'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: policy.effectiveRoles.map((r) => Chip(
                      label: Text(r, style: const TextStyle(fontSize: 12)),
                      avatar: const Icon(LucideIcons.shield, size: 14),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                  if (policy.conflicts.isNotEmpty) ...[
                    _buildSectionTitle('Known Conflicts'),
                    ...policy.conflicts.map((c) => Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Conflicts with: $c', style: const TextStyle(fontSize: 13, color: Colors.orange))),
                        ],
                      ),
                    )),
                  ],
                  const SizedBox(height: 24),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 16),
                  Text('Last Updated: ${DateFormat('MMM d, yyyy').format(policy.updatedAt)}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }

  Widget _getIcon(String name, {Color? color}) {
    switch (name) {
      case 'globe': return Icon(LucideIcons.globe, size: 20, color: color);
      case 'building-2': return Icon(LucideIcons.building2, size: 20, color: color);
      case 'trending-up': return Icon(LucideIcons.trendingUp, size: 20, color: color);
      case 'package': return Icon(LucideIcons.package, size: 20, color: color);
      case 'bar-chart-3': return Icon(LucideIcons.barChart3, size: 20, color: color);
      case 'shield-alert': return Icon(LucideIcons.shieldAlert, size: 20, color: color);
      case 'user': return Icon(LucideIcons.user, size: 20, color: color);
      default: return Icon(LucideIcons.circle, size: 20, color: color);
    }
  }
}
