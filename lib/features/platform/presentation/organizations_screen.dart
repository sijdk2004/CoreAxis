import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/organization_provider.dart';
import '../domain/models/organization.dart';

class OrganizationsScreen extends ConsumerStatefulWidget {
  const OrganizationsScreen({super.key});

  @override
  ConsumerState<OrganizationsScreen> createState() => _OrganizationsScreenState();
}

class _OrganizationsScreenState extends ConsumerState<OrganizationsScreen> {
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
    final state = ref.watch(organizationListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Organizations'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: FilledButton.icon(
              onPressed: () {
                context.go('/platform/organizations/new');
              },
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Create Organization'),
            ),
          ),
        ],
      ),
      body: state.isLoading && state.allOrganizations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, state, isDesktop),
    );
  }

  Widget _buildBody(BuildContext context, OrganizationListState state, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStats(state.allOrganizations, isDesktop),
          const SizedBox(height: 24),
          _buildToolbar(context, state, isDesktop),
          const SizedBox(height: 16),
          if (state.selectedOrgIds.isNotEmpty) _buildBulkActionsBar(context, state),
          if (state.selectedOrgIds.isNotEmpty) const SizedBox(height: 16),
          _buildTable(context, state, isDesktop),
        ],
      ),
    );
  }

  Widget _buildStats(List<Organization> allOrgs, bool isDesktop) {
    final active = allOrgs.where((t) => t.status == 'Active').length;
    final manufacturing = allOrgs.where((t) => t.industry == 'Manufacturing').length;
    final multiBranch = allOrgs.where((t) => t.branchCount > 1).length;
    final totalBranches = allOrgs.fold<int>(0, (prev, org) => prev + org.branchCount);
    final totalEmployees = allOrgs.fold<int>(0, (prev, org) => prev + org.employeeCount);

    final cards = [
      GradientKpiCard(title: 'Total Organizations', value: '${allOrgs.length}', subtitle: 'All registered', icon: LucideIcons.network, gradientColors: [Colors.blue, Colors.lightBlue]),
      GradientKpiCard(title: 'Active Organizations', value: '$active', subtitle: 'Currently active', icon: LucideIcons.checkCircle, gradientColors: [Colors.green, Colors.lightGreen]),
      GradientKpiCard(title: 'Manufacturing', value: '$manufacturing', subtitle: 'Industrial orgs', icon: LucideIcons.factory, gradientColors: [Colors.orange, Colors.amber]),
      GradientKpiCard(title: 'Multi-Branch', value: '$multiBranch', subtitle: 'Global footprints', icon: LucideIcons.gitBranch, gradientColors: [Colors.purple, Colors.purpleAccent]),
      GradientKpiCard(title: 'Total Branches', value: '$totalBranches', subtitle: 'Across the globe', icon: LucideIcons.mapPin, gradientColors: [Colors.teal, Colors.tealAccent]),
      GradientKpiCard(title: 'Total Employees', value: NumberFormat.compact().format(totalEmployees), subtitle: 'Managed workforce', icon: LucideIcons.users, gradientColors: [Colors.indigo, Colors.indigoAccent]),
    ];

    if (isDesktop) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
              const SizedBox(width: 16),
              Expanded(child: cards[2]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[3]),
              const SizedBox(width: 16),
              Expanded(child: cards[4]),
              const SizedBox(width: 16),
              Expanded(child: cards[5]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: c)).toList(),
      );
    }
  }

  Widget _buildToolbar(BuildContext context, OrganizationListState state, bool isDesktop) {
    final filters = ['All', 'Active', 'Inactive', 'Manufacturing', 'Trading', 'Service', 'Multi-Branch'];

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
              hintText: 'Search organizations...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            onChanged: (val) {
              setState(() => _currentPage = 0);
              ref.read(organizationListProvider.notifier).setSearchQuery(val);
            },
          ),
        ),
        ...filters.map((f) => ChoiceChip(
          label: Text(f),
          selected: state.filterStatus == f,
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentPage = 0);
              ref.read(organizationListProvider.notifier).setFilterStatus(f);
            }
          },
        )),
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Advanced Filters'),
                content: const Text('Mock Advanced Filters Dialog. (Filter by employee count, industry types, etc.)'),
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
          onPressed: () => ref.read(organizationListProvider.notifier).loadOrganizations(),
          icon: const Icon(LucideIcons.refreshCw),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildBulkActionsBar(BuildContext context, OrganizationListState state) {
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
          Text('${state.selectedOrgIds.length} Selected', style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => ref.read(organizationListProvider.notifier).bulkUpdateStatus('Active'),
            icon: const Icon(LucideIcons.checkCircle, size: 16, color: Colors.green),
            label: const Text('Activate', style: TextStyle(color: Colors.green)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => ref.read(organizationListProvider.notifier).bulkUpdateStatus('Inactive'),
            icon: const Icon(LucideIcons.pauseCircle, size: 16, color: Colors.grey),
            label: const Text('Deactivate', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exporting ${state.selectedOrgIds.length} orgs...')));
            },
            icon: const Icon(LucideIcons.download, size: 16, color: Colors.blue),
            label: const Text('Export', style: TextStyle(color: Colors.blue)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => ref.read(organizationListProvider.notifier).bulkDelete(),
            icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, OrganizationListState state, bool isDesktop) {
    final theme = Theme.of(context);
    final orgs = state.filteredOrganizations;
    final isLargeDesktop = ResponsiveBreakpoints.of(context).largerThan(DESKTOP);

    if (orgs.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(48.0),
        child: Text('No organizations found matching the criteria.'),
      ));
    }

    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage > orgs.length) ? orgs.length : startIndex + _rowsPerPage;
    final pageItems = orgs.sublist(startIndex, endIndex);

    final isAllPageSelected = pageItems.isNotEmpty && pageItems.every((o) => state.selectedOrgIds.contains(o.id));

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
                    columnSpacing: isDesktop ? 16 : 8,
                    headingRowColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.3)),
                    dataRowMinHeight: 64,
                    dataRowMaxHeight: 64,
                    showCheckboxColumn: true,
                    sortColumnIndex: _getColumnIndex(state.sortColumn),
                    sortAscending: state.sortAscending,
                    onSelectAll: (val) {
                      ref.read(organizationListProvider.notifier).selectAll(val ?? false);
                    },
                    columns: [
                      DataColumn(label: const Text('Organization'), onSort: (idx, asc) => _sort('name', asc)),
                      if (isLargeDesktop) DataColumn(label: const Text('Code'), onSort: (idx, asc) => _sort('code', asc)),
                      DataColumn(label: const Text('Tenant'), onSort: (idx, asc) => _sort('tenant', asc)),
                      DataColumn(label: const Text('Industry'), onSort: (idx, asc) => _sort('industry', asc)),
                      DataColumn(label: const Text('Branches'), numeric: true, onSort: (idx, asc) => _sort('branches', asc)),
                      DataColumn(label: const Text('Employees'), numeric: true, onSort: (idx, asc) => _sort('employees', asc)),
                      if (isLargeDesktop) DataColumn(label: const Text('Country'), onSort: (idx, asc) => _sort('country', asc)),
                      DataColumn(label: const Text('Status'), onSort: (idx, asc) => _sort('status', asc)),
                      DataColumn(label: const Text('Created'), onSort: (idx, asc) => _sort('created', asc)),
                      const DataColumn(label: Text('Actions')),
                    ],
                    rows: pageItems.map((o) {
                      return DataRow(
                        selected: state.selectedOrgIds.contains(o.id),
                        onSelectChanged: (val) => ref.read(organizationListProvider.notifier).toggleSelection(o.id),
                        cells: [
                          DataCell(Container(
                            constraints: const BoxConstraints(minWidth: 110),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(o.logoUrl),
                                  radius: 16,
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Text(o.name, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          )),
                          if (isLargeDesktop) DataCell(Container(constraints: const BoxConstraints(minWidth: 60), child: Text(o.code))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 70), child: Text(o.tenantName, style: TextStyle(color: theme.colorScheme.primary), overflow: TextOverflow.ellipsis))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 80), child: Text(o.industry, overflow: TextOverflow.ellipsis))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 80), alignment: Alignment.centerRight, child: Text('${o.branchCount}'))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 90), alignment: Alignment.centerRight, child: Text(NumberFormat.compact().format(o.employeeCount)))),
                          if (isLargeDesktop) DataCell(Container(constraints: const BoxConstraints(minWidth: 70), child: Text(o.country, overflow: TextOverflow.ellipsis))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 65), child: _buildStatusBadge(o.status))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 70), child: Text(DateFormat('MMM dd, yyyy').format(o.createdAt)))),
                          DataCell(_buildActionMenu(o)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
          const Divider(height: 1),
          _buildPagination(orgs.length),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.grey;
    if (status == 'Active') color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionMenu(Organization org) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 20),
      onSelected: (val) {
        if (val == 'view') {
          context.go('/platform/organizations/${org.id}');
        } else if (val == 'branches') {
          context.go('/platform/organizations/${org.id}/branches');
        } else if (val == 'departments') {
          context.go('/platform/organizations/${org.id}/departments');
        } else if (val == 'activate') {
          ref.read(organizationListProvider.notifier).updateOrganizationStatus(org.id, 'Active');
        } else if (val == 'deactivate') {
          ref.read(organizationListProvider.notifier).updateOrganizationStatus(org.id, 'Inactive');
        } else if (val == 'delete') {
          ref.read(organizationListProvider.notifier).deleteOrganization(org.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mock Action: $val for ${org.name}')));
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'view', child: Text('View Details')),
        const PopupMenuItem(value: 'edit', child: Text('Edit Organization')),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'branches', child: Text('Manage Branches')),
        const PopupMenuItem(value: 'departments', child: Text('Departments')),
        const PopupMenuItem(value: 'users', child: Text('View Users')),
        const PopupMenuDivider(),
        if (org.status != 'Active') const PopupMenuItem(value: 'activate', child: Text('Activate', style: TextStyle(color: Colors.green))),
        if (org.status != 'Inactive') const PopupMenuItem(value: 'deactivate', child: Text('Deactivate', style: TextStyle(color: Colors.grey))),
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
      case 'tenant': return 2;
      case 'industry': return 3;
      case 'branches': return 4;
      case 'employees': return 5;
      case 'country': return 6;
      case 'status': return 7;
      case 'created': return 8;
      default: return 0;
    }
  }

  void _sort(String column, bool ascending) {
    ref.read(organizationListProvider.notifier).setSort(column, ascending);
  }
}
