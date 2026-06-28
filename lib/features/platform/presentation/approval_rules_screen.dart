import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'providers/approval_rules_provider.dart';
import 'widgets/approval_rule_builder_dialog.dart';
import '../domain/models/approval_rule.dart';

class ApprovalRulesScreen extends ConsumerWidget {
  const ApprovalRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(approvalRulesProvider);
    final notifier = ref.read(approvalRulesProvider.notifier);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Approval Rules'),
        centerTitle: false,
        actions: [
          _buildToolbar(context, theme, notifier, isDesktop),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.dividerColor.withOpacity(0.5), height: 1.0),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCategoryFilters(theme, state, notifier),
          Divider(height: 1, color: theme.dividerColor.withOpacity(0.5)),
          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(child: _buildDataTable(context, theme, state, notifier, isDesktop)),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, ApprovalRulesNotifier notifier, bool isDesktop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDesktop)
            Container(
              width: 250,
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search rules...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  prefixIcon: const Icon(LucideIcons.search, size: 16),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onChanged: notifier.setSearchQuery,
              ),
            ),
          const SizedBox(width: 16),
          IconButton(icon: const Icon(LucideIcons.filter), tooltip: 'Filters', onPressed: () {}),
          IconButton(icon: const Icon(LucideIcons.download), tooltip: 'Export', onPressed: () {}),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: () => showDialog(context: context, builder: (_) => const ApprovalRuleBuilderDialog()),
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text('Create Rule'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(ThemeData theme, ApprovalRulesState state, ApprovalRulesNotifier notifier) {
    final categories = ['All', 'Quotation', 'Purchase', 'Sales Order', 'Production', 'Finance', 'HR', 'Inventory', 'Quality'];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: state.activeCategoryFilter == cat,
              onSelected: (val) {
                if (val) notifier.setCategoryFilter(cat);
              },
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, ThemeData theme, ApprovalRulesState state, ApprovalRulesNotifier notifier, bool isDesktop) {
    if (state.filteredRules.isEmpty) {
      return const Center(child: Text('No rules found.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Fixed widths for narrow columns
        const double wCat = 100.0;
        const double wEscal = 140.0;
        const double wSla = 90.0;
        const double wStatus = 70.0;
        const double wActions = 44.0;
        const double hPad = 32.0; // 16 left + 16 right padding

        // Fixed total consumed by narrow columns + padding
        const double fixedTotal = wCat + wEscal + wSla + wStatus + wActions + hPad;

        // Remaining space split evenly across 3 flex columns
        final double remaining = constraints.maxWidth - fixedTotal;
        final double flexCol = remaining / 3.0; // Name, Conditions, Approvers
        final double wName = flexCol;
        final double wCond = flexCol;
        final double wAppr = flexCol;

        Widget buildHeaderCell(String label) =>
            Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis);

        return Column(
          children: [
            // Header Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              child: Row(
                children: [
                  SizedBox(width: wName, child: buildHeaderCell('Rule Name')),
                  SizedBox(width: wCat, child: buildHeaderCell('Category')),
                  SizedBox(width: wCond, child: buildHeaderCell('Conditions')),
                  SizedBox(width: wAppr, child: buildHeaderCell('Approvers')),
                  SizedBox(width: wEscal, child: buildHeaderCell('Escalation')),
                  SizedBox(width: wSla, child: buildHeaderCell('SLA')),
                  SizedBox(width: wStatus, child: buildHeaderCell('Status')),
                  SizedBox(width: wActions),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            // Body
            Expanded(
              child: ListView.builder(
                itemCount: state.filteredRules.length,
                itemBuilder: (context, index) {
                  final rule = state.filteredRules[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5))),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: wName,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rule.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                              Text(rule.id, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: wCat,
                          child: Text(rule.category, style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(
                          width: wCond,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(rule.conditions, style: const TextStyle(color: Colors.purple, fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        SizedBox(
                          width: wAppr,
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: rule.approvers.map((a) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Text(a, style: const TextStyle(color: Colors.blue, fontSize: 11)),
                            )).toList(),
                          ),
                        ),
                        SizedBox(
                          width: wEscal,
                          child: Text(rule.escalation, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(
                          width: wSla,
                          child: Text(rule.sla, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                        ),
                        SizedBox(
                          width: wStatus,
                          child: Switch(
                            value: rule.isActive,
                            onChanged: (_) => notifier.toggleRuleStatus(rule.id),
                          ),
                        ),
                        SizedBox(
                          width: wActions,
                          child: PopupMenuButton<String>(
                            icon: const Icon(LucideIcons.moreVertical, size: 20),
                            onSelected: (val) {
                              if (val == 'Edit') {
                                showDialog(context: context, builder: (_) => ApprovalRuleBuilderDialog(existingRule: rule));
                              } else if (val == 'Delete') {
                                notifier.deleteRule(rule.id);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'Edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'Duplicate', child: Text('Duplicate')),
                              const PopupMenuItem(value: 'Delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
