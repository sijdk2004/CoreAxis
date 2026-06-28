import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/branch.dart';
import 'providers/branch_list_provider.dart';

class BranchManagementScreen extends ConsumerStatefulWidget {
  final String orgId;
  const BranchManagementScreen({super.key, required this.orgId});

  @override
  ConsumerState<BranchManagementScreen> createState() => _BranchManagementScreenState();
}

class _BranchManagementScreenState extends ConsumerState<BranchManagementScreen> {
  final int _rowsPerPage = 10;
  int _currentPage = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  Branch? _editingBranch;
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _managerController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  String _type = 'Office';
  String _status = 'Active';

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _managerController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _openDrawer([Branch? branch]) {
    setState(() {
      _editingBranch = branch;
      if (branch != null) {
        _nameController.text = branch.name;
        _codeController.text = branch.code;
        _managerController.text = branch.manager;
        _emailController.text = branch.email;
        _phoneController.text = branch.phone;
        _cityController.text = branch.city;
        _countryController.text = branch.country;
        _type = branch.type;
        _status = branch.status;
      } else {
        _nameController.clear();
        _codeController.clear();
        _managerController.clear();
        _emailController.clear();
        _phoneController.clear();
        _cityController.clear();
        _countryController.clear();
        _type = 'Office';
        _status = 'Active';
      }
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _saveBranch() {
    if (_formKey.currentState!.validate()) {
      final newBranch = Branch(
        id: _editingBranch?.id ?? 'BR${DateTime.now().millisecondsSinceEpoch}',
        orgId: widget.orgId,
        name: _nameController.text,
        code: _codeController.text,
        manager: _managerController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _editingBranch?.address ?? '123 Default St',
        city: _cityController.text,
        state: _editingBranch?.state ?? 'ST',
        country: _countryController.text,
        postalCode: _editingBranch?.postalCode ?? '00000',
        type: _type,
        status: _status,
        departments: _editingBranch?.departments ?? 1,
        employees: _editingBranch?.employees ?? 10,
        createdAt: _editingBranch?.createdAt ?? DateTime.now(),
      );

      if (_editingBranch != null) {
        ref.read(branchListProvider.notifier).updateBranch(newBranch);
      } else {
        ref.read(branchListProvider.notifier).addBranch(newBranch);
      }

      Navigator.of(context).pop(); // Close drawer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editingBranch != null ? 'Branch updated successfully' : 'Branch added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  int _getColumnIndex(String columnName) {
    const columns = ['name', 'code', 'manager', 'city', 'country', 'departments', 'employees', 'status'];
    return columns.indexOf(columnName) + 1; // +1 for checkbox
  }

  void _sort(String column, bool ascending) {
    ref.read(branchListProvider.notifier).setSort(column, ascending);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(branchListProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Branch Management'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/organizations/${widget.orgId}'),
        ),
      ),
      endDrawer: _buildEndDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticsRow(state.branches, isDesktop),
            const SizedBox(height: 24),
            _buildToolbar(context),
            const SizedBox(height: 16),
            _buildTable(context, state, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(List<Branch> branches, bool isDesktop) {
    final total = branches.length;
    final active = branches.where((b) => b.status == 'Active').length;
    final warehouses = branches.where((b) => b.type == 'Warehouse').length;
    final offices = branches.where((b) => b.type == 'Office').length;

    final cards = [
      GradientKpiCard(title: 'Total Branches', value: '$total', subtitle: 'All locations', icon: LucideIcons.gitBranch, gradientColors: const [Colors.blue, Colors.indigo]),
      GradientKpiCard(title: 'Active Branches', value: '$active', subtitle: 'Currently operating', icon: LucideIcons.checkCircle, gradientColors: const [Colors.green, Colors.teal]),
      GradientKpiCard(title: 'Warehouses', value: '$warehouses', subtitle: 'Storage hubs', icon: LucideIcons.package, gradientColors: const [Colors.orange, Colors.deepOrange]),
      GradientKpiCard(title: 'Offices', value: '$offices', subtitle: 'Corporate & Regional', icon: LucideIcons.building, gradientColors: const [Colors.purple, Colors.pink]),
    ];

    if (isDesktop) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: EdgeInsets.only(right: c == cards.last ? 0 : 16.0), child: c))).toList(),
      );
    } else {
      return Column(
        children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 16.0), child: c)).toList(),
      );
    }
  }

  Widget _buildToolbar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search branches...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            onChanged: (val) => ref.read(branchListProvider.notifier).setSearchQuery(val),
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: () => _openDrawer(),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Add Branch'),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, BranchListState state, bool isDesktop) {
    final theme = Theme.of(context);
    final branches = state.filteredBranches;
    final isLargeDesktop = ResponsiveBreakpoints.of(context).largerThan(DESKTOP);

    if (branches.isEmpty) {
      return const PremiumCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: Text('No branches found.'),
          ),
        ),
      );
    }

    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage > branches.length) ? branches.length : startIndex + _rowsPerPage;
    final pageItems = branches.sublist(startIndex, endIndex);

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
                    onSelectAll: (val) => ref.read(branchListProvider.notifier).selectAll(val ?? false),
                    columns: [
                      DataColumn(label: const Text('Branch Name'), onSort: (idx, asc) => _sort('name', asc)),
                      if (isLargeDesktop) DataColumn(label: const Text('Code'), onSort: (idx, asc) => _sort('code', asc)),
                      DataColumn(label: const Text('Manager'), onSort: (idx, asc) => _sort('manager', asc)),
                      DataColumn(label: const Text('City'), onSort: (idx, asc) => _sort('city', asc)),
                      if (isLargeDesktop) DataColumn(label: const Text('Country'), onSort: (idx, asc) => _sort('country', asc)),
                      DataColumn(label: const Text('Depts'), numeric: true, onSort: (idx, asc) => _sort('departments', asc)),
                      DataColumn(label: const Text('Emps'), numeric: true, onSort: (idx, asc) => _sort('employees', asc)),
                      DataColumn(label: const Text('Status'), onSort: (idx, asc) => _sort('status', asc)),
                      const DataColumn(label: Text('Actions')),
                    ],
                    rows: pageItems.map((b) {
                      return DataRow(
                        selected: state.selectedIds.contains(b.id),
                        onSelectChanged: (val) => ref.read(branchListProvider.notifier).toggleSelection(b.id),
                        cells: [
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 120), child: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))),
                          if (isLargeDesktop) DataCell(Container(constraints: const BoxConstraints(minWidth: 60), child: Text(b.code))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 100), child: Text(b.manager, overflow: TextOverflow.ellipsis))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 80), child: Text(b.city, overflow: TextOverflow.ellipsis))),
                          if (isLargeDesktop) DataCell(Container(constraints: const BoxConstraints(minWidth: 80), child: Text(b.country, overflow: TextOverflow.ellipsis))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 60), alignment: Alignment.centerRight, child: Text('${b.departments}'))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 60), alignment: Alignment.centerRight, child: Text('${b.employees}'))),
                          DataCell(Container(constraints: const BoxConstraints(minWidth: 65), child: _buildStatusBadge(b.status))),
                          DataCell(_buildActionMenu(b)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1),
          _buildPagination(branches.length),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'Active' ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionMenu(Branch branch) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 20),
      onSelected: (val) {
        if (val == 'edit') {
          _openDrawer(branch);
        } else if (val == 'delete') {
          ref.read(branchListProvider.notifier).deleteBranch(branch.id);
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit Branch')),
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
          Text('Page ${_currentPage + 1} of $totalPages'),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight),
            onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildEndDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = _editingBranch != null;

    return Drawer(
      width: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: theme.colorScheme.primary,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Branch' : 'Add New Branch',
                      style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onPrimary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, color: theme.colorScheme.onPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Branch Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(labelText: 'Branch Code', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _managerController,
                      decoration: const InputDecoration(labelText: 'Manager Name', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required field' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? 'Required field' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _countryController,
                            decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
                            validator: (v) => v!.isEmpty ? 'Required field' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(labelText: 'Branch Type', border: OutlineInputBorder()),
                      items: ['Office', 'Warehouse', 'Retail'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _type = v!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ['Active', 'Inactive'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _status = v!),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveBranch,
                    child: Text(isEditing ? 'Save Changes' : 'Create Branch'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
