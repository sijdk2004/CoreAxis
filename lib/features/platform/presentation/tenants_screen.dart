import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/tenant_provider.dart';
import '../domain/models/tenant.dart';

class TenantsScreen extends ConsumerStatefulWidget {
  const TenantsScreen({super.key});

  @override
  ConsumerState<TenantsScreen> createState() => _TenantsScreenState();
}

class _TenantsScreenState extends ConsumerState<TenantsScreen> {
  final _searchController = TextEditingController();
  int _rowsPerPage = 10;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final state = ref.watch(tenantListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tenants'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: () {
                context.go('/platform/tenants/new');
              },
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Create Tenant'),
            ),
          ),
        ],
      ),
      body: state.isLoading && state.allTenants.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, state, isDesktop),
    );
  }

  Widget _buildBody(BuildContext context, TenantListState state, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStats(state.allTenants, isDesktop),
          const SizedBox(height: 24),
          _buildToolbar(context, state, isDesktop),
          const SizedBox(height: 16),
          if (state.selectedTenantIds.isNotEmpty) _buildBulkActionsBar(context, state),
          if (state.selectedTenantIds.isNotEmpty) const SizedBox(height: 16),
          _buildTable(context, state, isDesktop),
        ],
      ),
    );
  }

  Widget _buildStats(List<Tenant> allTenants, bool isDesktop) {
    final active = allTenants.where((t) => t.status == 'Active').length;
    final trial = allTenants.where((t) => t.status == 'Trial').length;
    final paid = allTenants.where((t) => t.subscriptionPlan != 'Trial').length;
    final suspended = allTenants.where((t) => t.status == 'Suspended').length;

    final cards = [
      GradientKpiCard(title: 'Total Tenants', value: '${allTenants.length}', subtitle: 'All registered', icon: LucideIcons.building2, gradientColors: [Colors.blue, Colors.lightBlue]),
      GradientKpiCard(title: 'Active', value: '$active', subtitle: 'Currently active', icon: LucideIcons.checkCircle, gradientColors: [Colors.green, Colors.lightGreen]),
      GradientKpiCard(title: 'Trial', value: '$trial', subtitle: 'In trial period', icon: LucideIcons.clock, gradientColors: [Colors.orange, Colors.amber]),
      GradientKpiCard(title: 'Paid', value: '$paid', subtitle: 'Paid subscriptions', icon: LucideIcons.dollarSign, gradientColors: [Colors.purple, Colors.purpleAccent]),
      GradientKpiCard(title: 'Suspended', value: '$suspended', subtitle: 'Requires attention', icon: LucideIcons.alertTriangle, gradientColors: [Colors.red, Colors.redAccent]),
    ];

    if (isDesktop) {
      return Row(
        children: cards.asMap().entries.map((e) => Expanded(
          child: Padding(padding: EdgeInsets.only(right: e.key < cards.length - 1 ? 16.0 : 0), child: e.value)
        )).toList(),
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: c)).toList(),
      );
    }
  }

  Widget _buildToolbar(BuildContext context, TenantListState state, bool isDesktop) {
    final filters = ['All', 'Active', 'Inactive', 'Trial', 'Paid', 'Suspended', 'Expired'];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search tenants...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            onChanged: (val) {
              setState(() => _currentPage = 0);
              ref.read(tenantListProvider.notifier).setSearchQuery(val);
            },
          ),
        ),
        ...filters.map((f) => ChoiceChip(
          label: Text(f),
          selected: state.filterStatus == f,
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentPage = 0);
              ref.read(tenantListProvider.notifier).setFilterStatus(f);
            }
          },
        )),
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Advanced Filters'),
                content: const Text('Mock Advanced Filters Dialog. (Filter by date ranges, org count, etc.)'),
                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
              )
            );
          },
          icon: const Icon(LucideIcons.sliders, size: 16),
          label: const Text('Advanced'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Exporting to CSV...')));
          },
          icon: const Icon(LucideIcons.download, size: 16),
          label: const Text('Export'),
        ),
        IconButton(
          onPressed: () => ref.read(tenantListProvider.notifier).loadTenants(),
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildBulkActionsBar(BuildContext context, TenantListState state) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text('${state.selectedTenantIds.length} Selected', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => ref.read(tenantListProvider.notifier).bulkUpdateStatus('Active'),
            icon: const Icon(LucideIcons.checkCircle, size: 16, color: Colors.green),
            label: const Text('Activate', style: TextStyle(color: Colors.green)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => ref.read(tenantListProvider.notifier).bulkUpdateStatus('Suspended'),
            icon: const Icon(LucideIcons.pauseCircle, size: 16, color: Colors.orange),
            label: const Text('Suspend', style: TextStyle(color: Colors.orange)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => ref.read(tenantListProvider.notifier).bulkDelete(),
            icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, TenantListState state, bool isDesktop) {
    final theme = Theme.of(context);
    final tenants = state.filteredTenants;

    if (tenants.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Text('No tenants found matching the criteria.'),
      ));
    }

    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage > tenants.length) ? tenants.length : startIndex + _rowsPerPage;
    final pageItems = tenants.sublist(startIndex, endIndex);

    final isAllPageSelected = pageItems.isNotEmpty && pageItems.every((t) => state.selectedTenantIds.contains(t.id));

    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: isDesktop ? 24 : 16,
                headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
                dataRowMinHeight: 64,
                dataRowMaxHeight: 64,
                showCheckboxColumn: true,
                sortColumnIndex: _getColumnIndex(state.sortColumn),
                sortAscending: state.sortAscending,
                onSelectAll: (val) {
                  ref.read(tenantListProvider.notifier).selectAll(val ?? false);
                },
                columns: [
                  DataColumn(label: const Text('Tenant'), onSort: (idx, asc) => _sort('name', asc)),
                  DataColumn(label: const Text('Code'), onSort: (idx, asc) => _sort('code', asc)),
                  DataColumn(label: const Text('Organizations'), numeric: true, onSort: (idx, asc) => _sort('orgs', asc)),
                  DataColumn(label: const Text('Users'), numeric: true, onSort: (idx, asc) => _sort('users', asc)),
                  DataColumn(label: const Text('Plan'), onSort: (idx, asc) => _sort('plan', asc)),
                  DataColumn(label: const Text('Status'), onSort: (idx, asc) => _sort('status', asc)),
                  DataColumn(label: const Text('Created'), onSort: (idx, asc) => _sort('created', asc)),
                  const DataColumn(label: Text('Actions')),
                ],
                rows: pageItems.map((t) {
                  return DataRow(
                    selected: state.selectedTenantIds.contains(t.id),
                    onSelectChanged: (val) => ref.read(tenantListProvider.notifier).toggleSelection(t.id),
                    cells: [
                      DataCell(Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(t.logoUrl),
                            radius: 16,
                          ),
                          const SizedBox(width: 12),
                          Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      )),
                      DataCell(Text(t.code)),
                      DataCell(Text('${t.organizationCount}')),
                      DataCell(Text('${t.userCount}')),
                      DataCell(Text(t.subscriptionPlan)),
                      DataCell(_buildStatusBadge(t.status)),
                      DataCell(Text(DateFormat('MMM dd, yyyy').format(t.createdAt))),
                      DataCell(_buildActionMenu(t)),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
          }),
          const Divider(height: 1),
          _buildPagination(tenants.length),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'Active') color = Colors.green;
    if (status == 'Trial') color = Colors.orange;
    if (status == 'Suspended') color = Colors.red;
    if (status == 'Expired') color = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionMenu(Tenant tenant) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 20),
      onSelected: (val) {
        if (val == 'view') {
          context.go('/platform/tenants/${tenant.id}');
        } else if (val == 'subscription') {
          context.go('/platform/tenants/${tenant.id}/subscription');
        } else if (val == 'analytics') {
          context.go('/platform/tenants/${tenant.id}/analytics');
        } else if (val == 'settings') {
          context.go('/platform/tenants/${tenant.id}/settings');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mock Action: $val for ${tenant.name}')));
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'view', child: Text('View Details')),
        const PopupMenuItem(value: 'edit', child: Text('Edit Tenant')),
        const PopupMenuItem(value: 'settings', child: Text('Settings')),
        const PopupMenuItem(value: 'subscription', child: Text('Manage Subscription')),
        const PopupMenuItem(value: 'analytics', child: Text('Analytics')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'orgs', child: Text('View Organizations')),
        const PopupMenuItem(value: 'users', child: Text('View Users')),
        const PopupMenuDivider(),
        if (tenant.status != 'Active') const PopupMenuItem(value: 'activate', child: Text('Activate', style: TextStyle(color: Colors.green))),
        if (tenant.status != 'Suspended') const PopupMenuItem(value: 'suspend', child: Text('Suspend', style: TextStyle(color: Colors.orange))),
        const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    );
  }

  Widget _buildPagination(int totalItems) {
    final totalPages = (totalItems / _rowsPerPage).ceil();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Rows per page:'),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _rowsPerPage,
            underline: const SizedBox(),
            items: [10, 20, 50].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _rowsPerPage = v;
                  _currentPage = 0;
                });
              }
            },
          ),
          const SizedBox(width: 24),
          Text('${_currentPage * _rowsPerPage + 1}-${(_currentPage * _rowsPerPage + _rowsPerPage > totalItems) ? totalItems : _currentPage * _rowsPerPage + _rowsPerPage} of $totalItems'),
          const SizedBox(width: 24),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
          ),
        ],
      ),
    );
  }

  int _getColumnIndex(String sortColumn) {
    switch (sortColumn) {
      case 'name': return 0;
      case 'code': return 1;
      case 'orgs': return 2;
      case 'users': return 3;
      case 'plan': return 4;
      case 'status': return 5;
      case 'created': return 6;
      default: return 0;
    }
  }

  void _sort(String column, bool ascending) {
    ref.read(tenantListProvider.notifier).setSort(column, ascending);
  }
}
