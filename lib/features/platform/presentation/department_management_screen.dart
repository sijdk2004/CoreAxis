import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import '../domain/models/department.dart';
import 'providers/department_list_provider.dart';

class DepartmentManagementScreen extends ConsumerStatefulWidget {
  final String orgId;
  const DepartmentManagementScreen({super.key, required this.orgId});

  @override
  ConsumerState<DepartmentManagementScreen> createState() => _DepartmentManagementScreenState();
}

class _DepartmentManagementScreenState extends ConsumerState<DepartmentManagementScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // 0: Table, 1: Tree, 2: Card
  int _currentViewMode = 0;

  // Drawer Form State
  final _formKey = GlobalKey<FormState>();
  Department? _editingDepartment;
  
  // Controllers
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _managerController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedStatus = 'Active';
  String _selectedBranch = 'BR1000';
  String? _selectedParentId;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _managerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openDrawer([Department? department]) {
    setState(() {
      _editingDepartment = department;
      if (department != null) {
        _nameController.text = department.name;
        _codeController.text = department.code;
        _managerController.text = department.manager;
        _descriptionController.text = department.description;
        _selectedStatus = department.status;
        _selectedBranch = department.branchId;
        _selectedParentId = department.parentId;
      } else {
        _nameController.clear();
        _codeController.clear();
        _managerController.clear();
        _descriptionController.clear();
        _selectedStatus = 'Active';
        _selectedBranch = 'BR1000';
        _selectedParentId = null;
      }
    });
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _saveDepartment() {
    if (_formKey.currentState!.validate()) {
      final newDepartment = Department(
        id: _editingDepartment?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        orgId: widget.orgId,
        branchId: _selectedBranch,
        parentId: _selectedParentId,
        name: _nameController.text,
        code: _codeController.text,
        manager: _managerController.text,
        description: _descriptionController.text,
        status: _selectedStatus,
        employees: _editingDepartment?.employees ?? 0,
        createdAt: _editingDepartment?.createdAt ?? DateTime.now(),
      );

      if (_editingDepartment != null) {
        ref.read(departmentListProvider.notifier).updateDepartment(newDepartment);
      } else {
        ref.read(departmentListProvider.notifier).addDepartment(newDepartment);
      }

      Navigator.of(context).pop(); // Close drawer
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editingDepartment != null ? 'Department updated successfully' : 'Department added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  int _getColumnIndex(String columnName) {
    const columns = ['name', 'code', 'branch', 'manager', 'employees', 'status'];
    return columns.indexOf(columnName) + 1; // +1 for checkbox
  }

  void _sort(String column, bool ascending) {
    ref.read(departmentListProvider.notifier).setSort(column, ascending);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(departmentListProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Department Management'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.go('/platform/organizations/${widget.orgId}'),
        ),
      ),
      endDrawer: _buildEndDrawer(context, state.departments),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatisticsRow(state.departments, isDesktop),
            const SizedBox(height: 24),
            _buildToolbar(context),
            const SizedBox(height: 16),
            _buildMainContent(context, state, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsRow(List<Department> departments, bool isDesktop) {
    final total = departments.length;
    final active = departments.where((d) => d.status == 'Active').length;
    final headCount = departments.map((d) => d.manager).toSet().length;
    final totalEmp = departments.fold(0, (sum, d) => sum + d.employees);

    final cards = [
      GradientKpiCard(title: 'Total Departments', value: '$total', subtitle: 'All business units', icon: LucideIcons.network, gradientColors: const [Colors.blue, Colors.indigo]),
      GradientKpiCard(title: 'Active Departments', value: '$active', subtitle: 'Currently operating', icon: LucideIcons.checkCircle, gradientColors: const [Colors.green, Colors.teal]),
      GradientKpiCard(title: 'Department Heads', value: '$headCount', subtitle: 'Unique managers', icon: LucideIcons.users, gradientColors: const [Colors.orange, Colors.deepOrange]),
      GradientKpiCard(title: 'Total Employees', value: '$totalEmp', subtitle: 'Across departments', icon: LucideIcons.briefcase, gradientColors: const [Colors.purple, Colors.pink]),
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
              hintText: 'Search departments...',
              prefixIcon: const Icon(LucideIcons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            onChanged: (val) => ref.read(departmentListProvider.notifier).setSearchQuery(val),
          ),
        ),
        const SizedBox(width: 16),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 0, icon: Icon(LucideIcons.list), label: Text('Table')),
            ButtonSegment(value: 1, icon: Icon(LucideIcons.network), label: Text('Tree')),
            ButtonSegment(value: 2, icon: Icon(LucideIcons.layoutGrid), label: Text('Cards')),
          ],
          selected: {_currentViewMode},
          onSelectionChanged: (Set<int> newSelection) {
            setState(() {
              _currentViewMode = newSelection.first;
            });
          },
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: () => _openDrawer(),
          icon: const Icon(LucideIcons.plus, size: 18),
          label: const Text('Add Department'),
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context, DepartmentListState state, bool isDesktop) {
    if (state.filteredDepartments.isEmpty) {
      return const PremiumCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(48.0),
            child: Text('No departments found.'),
          ),
        ),
      );
    }

    switch (_currentViewMode) {
      case 0:
        return _buildTable(context, state, isDesktop);
      case 1:
        return _buildTreeView(context, state);
      case 2:
        return _buildCardView(context, state, isDesktop);
      default:
        return _buildTable(context, state, isDesktop);
    }
  }

  Widget _buildTable(BuildContext context, DepartmentListState state, bool isDesktop) {
    final theme = Theme.of(context);
    final departments = state.filteredDepartments;
    final isLargeDesktop = ResponsiveBreakpoints.of(context).largerThan(DESKTOP);

    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Department Directory', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (state.selectedIds.isNotEmpty)
                  Text('${state.selectedIds.length} selected', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 96),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dataTableTheme: DataTableThemeData(
                    headingTextStyle: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurfaceVariant),
                    dataTextStyle: theme.textTheme.bodyMedium,
                  ),
                ),
                child: DataTable(
                  showCheckboxColumn: true,
                  sortColumnIndex: _getColumnIndex(state.sortColumn),
                  sortAscending: state.sortAscending,
                  onSelectAll: (val) => ref.read(departmentListProvider.notifier).selectAll(val ?? false),
                  columns: [
                    DataColumn(label: const Text('Department Name'), onSort: (idx, asc) => _sort('name', asc)),
                    if (isLargeDesktop) DataColumn(label: const Text('Code'), onSort: (idx, asc) => _sort('code', asc)),
                    if (isLargeDesktop) const DataColumn(label: Text('Branch')),
                    DataColumn(label: const Text('Manager'), onSort: (idx, asc) => _sort('manager', asc)),
                    DataColumn(label: const Text('Employees'), onSort: (idx, asc) => _sort('employees', asc), numeric: true),
                    DataColumn(label: const Text('Status'), onSort: (idx, asc) => _sort('status', asc)),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: departments.map((d) {
                    return DataRow(
                      selected: state.selectedIds.contains(d.id),
                      onSelectChanged: (val) => ref.read(departmentListProvider.notifier).toggleSelection(d.id),
                      cells: [
                        DataCell(Container(constraints: const BoxConstraints(minWidth: 150), child: Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))),
                        if (isLargeDesktop) DataCell(Container(constraints: const BoxConstraints(minWidth: 60), child: Text(d.code))),
                        if (isLargeDesktop) DataCell(Text(d.branchId)), // Mock representation
                        DataCell(Container(constraints: const BoxConstraints(minWidth: 100), child: Text(d.manager, overflow: TextOverflow.ellipsis))),
                        DataCell(Text('${d.employees}')),
                        DataCell(_buildStatusBadge(d.status)),
                        DataCell(_buildActionMenu(d)),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          // Pagination placeholder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.1)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Rows per page: 10', style: theme.textTheme.bodySmall),
                const SizedBox(width: 24),
                Text('1-${departments.length} of ${departments.length}', style: theme.textTheme.bodySmall),
                const SizedBox(width: 24),
                IconButton(icon: const Icon(LucideIcons.chevronLeft, size: 18), onPressed: () {}),
                IconButton(icon: const Icon(LucideIcons.chevronRight, size: 18), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeView(BuildContext context, DepartmentListState state) {
    // Build tree logic
    final allDeps = state.filteredDepartments;
    final topLevel = allDeps.where((d) => d.parentId == null).toList();

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Organization Hierarchy', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          ...topLevel.map((t) => _buildTreeNode(t, allDeps, 0)),
        ],
      ),
    );
  }

  Widget _buildTreeNode(Department node, List<Department> allDeps, int level) {
    final children = allDeps.where((d) => d.parentId == node.id).toList();
    if (children.isEmpty) {
      return ListTile(
        contentPadding: EdgeInsets.only(left: 16.0 + (level * 24.0), right: 16.0),
        leading: const Icon(LucideIcons.folder, color: Colors.blue),
        title: Text(node.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text('Code: ${node.code} • Manager: ${node.manager}'),
        trailing: Text('${node.employees} emp'),
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: level == 0, // Expand corporate by default
        tilePadding: EdgeInsets.only(left: 16.0 + (level * 24.0), right: 16.0),
        leading: const Icon(LucideIcons.network, color: Colors.indigo),
        title: Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Code: ${node.code} • Manager: ${node.manager}'),
        children: children.map((c) => _buildTreeNode(c, allDeps, level + 1)).toList(),
      ),
    );
  }

  Widget _buildCardView(BuildContext context, DepartmentListState state, bool isDesktop) {
    final allDeps = state.filteredDepartments;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 3 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isDesktop ? 1.5 : 2.5,
      ),
      itemCount: allDeps.length,
      itemBuilder: (context, index) {
        final d = allDeps[index];
        final childCount = allDeps.where((c) => c.parentId == d.id).length;
        
        return PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis)),
                  _buildStatusBadge(d.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(d.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const Spacer(),
              Row(
                children: [
                  const Icon(LucideIcons.user, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(d.manager, style: const TextStyle(fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.briefcase, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${d.employees} Employees', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  if (childCount > 0)
                    Text('+$childCount sub-departments', style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.green.withOpacity(0.5) : Colors.red.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.red[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionMenu(Department department) {
    return PopupMenuButton<String>(
      icon: const Icon(LucideIcons.moreVertical, size: 18),
      onSelected: (val) {
        if (val == 'edit') {
          _openDrawer(department);
        } else if (val == 'delete') {
          ref.read(departmentListProvider.notifier).deleteDepartment(department.id);
        }
      },
      itemBuilder: (ctx) => [
        const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(LucideIcons.edit, size: 18), title: Text('Edit'), contentPadding: EdgeInsets.zero)),
        const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(LucideIcons.trash2, size: 18, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)), contentPadding: EdgeInsets.zero)),
      ],
    );
  }

  Widget _buildEndDrawer(BuildContext context, List<Department> allDeps) {
    final theme = Theme.of(context);
    final possibleParents = allDeps.where((d) => d.id != _editingDepartment?.id).toList(); // Cannot be own parent

    return Drawer(
      width: 400,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Icon(_editingDepartment == null ? LucideIcons.plusCircle : LucideIcons.edit, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    _editingDepartment == null ? 'Add Department' : 'Edit Department',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(icon: const Icon(LucideIcons.x), onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Department Name', border: OutlineInputBorder(), prefixIcon: Icon(LucideIcons.network)),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(labelText: 'Department Code', border: OutlineInputBorder(), prefixIcon: Icon(LucideIcons.hash)),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Parent Department', border: OutlineInputBorder(), prefixIcon: Icon(LucideIcons.folder)),
                      value: _selectedParentId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None (Top Level)')),
                        ...possibleParents.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))),
                      ],
                      onChanged: (val) => setState(() => _selectedParentId = val),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder(), prefixIcon: Icon(LucideIcons.gitBranch)),
                      value: _selectedBranch,
                      items: const [
                        DropdownMenuItem(value: 'BR1000', child: Text('Corporate Office 1')),
                        DropdownMenuItem(value: 'BR1001', child: Text('Distribution Center 2')),
                      ],
                      onChanged: (val) => setState(() => _selectedBranch = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _managerController,
                      decoration: const InputDecoration(labelText: 'Manager Name', border: OutlineInputBorder(), prefixIcon: Icon(LucideIcons.user)),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), prefixIcon: Icon(LucideIcons.fileText)),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder(), prefixIcon: Icon(LucideIcons.activity)),
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      ],
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 16),
                  FilledButton(onPressed: _saveDepartment, child: const Text('Save Department')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
