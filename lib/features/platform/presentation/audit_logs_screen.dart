import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// ─── Model ───────────────────────────────────────────────────────────────────

enum AuditSeverity { info, warning, critical }

enum AuditCategory {
  authentication,
  authorization,
  dataAccess,
  configuration,
  userManagement,
  documentManagement,
  workflowExecution,
  systemEvent,
}

class AuditLogEntry {
  final String id;
  final DateTime timestamp;
  final AuditSeverity severity;
  final AuditCategory category;
  final String actor;
  final String actorRole;
  final String action;
  final String resource;
  final String resourceId;
  final String ipAddress;
  final String sessionId;
  final bool success;
  final Map<String, String> metadata;

  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.category,
    required this.actor,
    required this.actorRole,
    required this.action,
    required this.resource,
    required this.resourceId,
    required this.ipAddress,
    required this.sessionId,
    required this.success,
    required this.metadata,
  });
}

// ─── Mock Provider ────────────────────────────────────────────────────────────

class AuditLogsState {
  final List<AuditLogEntry> allLogs;
  final String searchQuery;
  final AuditSeverity? filterSeverity;
  final AuditCategory? filterCategory;
  final bool? filterSuccess;
  final DateTimeRange? filterDateRange;

  AuditLogsState({
    required this.allLogs,
    this.searchQuery = '',
    this.filterSeverity,
    this.filterCategory,
    this.filterSuccess,
    this.filterDateRange,
  });

  AuditLogsState copyWith({
    List<AuditLogEntry>? allLogs,
    String? searchQuery,
    AuditSeverity? filterSeverity,
    AuditCategory? filterCategory,
    bool? filterSuccess,
    DateTimeRange? filterDateRange,
    bool clearSeverity = false,
    bool clearCategory = false,
    bool clearSuccess = false,
    bool clearDateRange = false,
  }) {
    return AuditLogsState(
      allLogs: allLogs ?? this.allLogs,
      searchQuery: searchQuery ?? this.searchQuery,
      filterSeverity: clearSeverity ? null : filterSeverity ?? this.filterSeverity,
      filterCategory: clearCategory ? null : filterCategory ?? this.filterCategory,
      filterSuccess: clearSuccess ? null : filterSuccess ?? this.filterSuccess,
      filterDateRange: clearDateRange ? null : filterDateRange ?? this.filterDateRange,
    );
  }

  List<AuditLogEntry> get filteredLogs {
    return allLogs.where((log) {
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!log.actor.toLowerCase().contains(q) &&
            !log.action.toLowerCase().contains(q) &&
            !log.resource.toLowerCase().contains(q)) return false;
      }
      if (filterSeverity != null && log.severity != filterSeverity) return false;
      if (filterCategory != null && log.category != filterCategory) return false;
      if (filterSuccess != null && log.success != filterSuccess) return false;
      if (filterDateRange != null) {
        if (log.timestamp.isBefore(filterDateRange!.start) ||
            log.timestamp.isAfter(filterDateRange!.end)) return false;
      }
      return true;
    }).toList();
  }

  int get criticalCount => allLogs.where((l) => l.severity == AuditSeverity.critical).length;
  int get warningCount => allLogs.where((l) => l.severity == AuditSeverity.warning).length;
  int get failureCount => allLogs.where((l) => !l.success).length;
  int get todayCount {
    final today = DateTime.now();
    return allLogs.where((l) =>
      l.timestamp.year == today.year &&
      l.timestamp.month == today.month &&
      l.timestamp.day == today.day).length;
  }
}

class AuditLogsNotifier extends Notifier<AuditLogsState> {
  @override
  AuditLogsState build() {
    return AuditLogsState(allLogs: _generateMockLogs());
  }

  void setSearch(String q) => state = state.copyWith(searchQuery: q);
  void setSeverity(AuditSeverity? s) => s == null
      ? state = state.copyWith(clearSeverity: true)
      : state = state.copyWith(filterSeverity: s);
  void setCategory(AuditCategory? c) => c == null
      ? state = state.copyWith(clearCategory: true)
      : state = state.copyWith(filterCategory: c);
  void setSuccess(bool? s) => s == null
      ? state = state.copyWith(clearSuccess: true)
      : state = state.copyWith(filterSuccess: s);
  void clearFilters() => state = state.copyWith(
        searchQuery: '',
        clearSeverity: true,
        clearCategory: true,
        clearSuccess: true,
        clearDateRange: true,
      );

  List<AuditLogEntry> _generateMockLogs() {
    final r = Random(42);
    final now = DateTime.now();
    final actors = [
      ('Alice Smith', 'Platform Admin'),
      ('Bob Jones', 'Finance Manager'),
      ('Charlie Davis', 'Tenant Admin'),
      ('Dana White', 'Developer'),
      ('System', 'Automated Process'),
      ('Eve Adams', 'HR Manager'),
      ('Frank Castle', 'Compliance Officer'),
    ];
    final actions = [
      (AuditCategory.authentication, 'User Login', 'Auth Session', AuditSeverity.info),
      (AuditCategory.authentication, 'User Logout', 'Auth Session', AuditSeverity.info),
      (AuditCategory.authentication, 'Failed Login Attempt', 'Auth Session', AuditSeverity.warning),
      (AuditCategory.authentication, 'MFA Challenge', 'Auth Session', AuditSeverity.info),
      (AuditCategory.authorization, 'Permission Denied', 'RBAC Policy', AuditSeverity.warning),
      (AuditCategory.authorization, 'Role Assigned', 'User Role', AuditSeverity.info),
      (AuditCategory.authorization, 'Privilege Escalation Attempt', 'RBAC Policy', AuditSeverity.critical),
      (AuditCategory.dataAccess, 'Document Viewed', 'Document', AuditSeverity.info),
      (AuditCategory.dataAccess, 'Document Downloaded', 'Document', AuditSeverity.info),
      (AuditCategory.dataAccess, 'Bulk Data Export', 'Data Export', AuditSeverity.warning),
      (AuditCategory.configuration, 'System Setting Modified', 'Config', AuditSeverity.warning),
      (AuditCategory.configuration, 'Integration Key Rotated', 'API Key', AuditSeverity.warning),
      (AuditCategory.userManagement, 'User Created', 'User Account', AuditSeverity.info),
      (AuditCategory.userManagement, 'User Deactivated', 'User Account', AuditSeverity.warning),
      (AuditCategory.userManagement, 'Password Reset', 'User Account', AuditSeverity.info),
      (AuditCategory.documentManagement, 'Document Deleted', 'Document', AuditSeverity.warning),
      (AuditCategory.documentManagement, 'Document Shared Externally', 'Document Share', AuditSeverity.warning),
      (AuditCategory.workflowExecution, 'Workflow Triggered', 'Workflow', AuditSeverity.info),
      (AuditCategory.workflowExecution, 'Approval Bypassed', 'Workflow Step', AuditSeverity.critical),
      (AuditCategory.systemEvent, 'Backup Completed', 'System', AuditSeverity.info),
      (AuditCategory.systemEvent, 'High Memory Usage Alert', 'System Resource', AuditSeverity.critical),
    ];

    final ips = ['192.168.1.45', '10.0.0.5', '203.0.113.42', '198.51.100.23', '172.16.0.8'];

    return List.generate(120, (i) {
      final actor = actors[r.nextInt(actors.length)];
      final action = actions[r.nextInt(actions.length)];
      final isSuccess = action.$4 == AuditSeverity.critical ? r.nextBool() : r.nextDouble() > 0.15;

      return AuditLogEntry(
        id: 'AUDIT-${(10000 + i).toString()}',
        timestamp: now.subtract(Duration(
          hours: r.nextInt(720),
          minutes: r.nextInt(60),
          seconds: r.nextInt(60),
        )),
        severity: action.$4,
        category: action.$1,
        actor: actor.$1,
        actorRole: actor.$2,
        action: action.$2,
        resource: action.$3,
        resourceId: 'RES-${r.nextInt(9999).toString().padLeft(4, '0')}',
        ipAddress: ips[r.nextInt(ips.length)],
        sessionId: 'SES-${r.nextInt(999999).toString().padLeft(6, '0')}',
        success: isSuccess,
        metadata: {
          'User-Agent': 'Chrome/125.0 Windows',
          'Request-ID': 'req_${r.nextInt(9999999)}',
          'Tenant': 'acme-corp',
        },
      );
    })..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}

final auditLogsProvider = NotifierProvider<AuditLogsNotifier, AuditLogsState>(() {
  return AuditLogsNotifier();
});

// ─── Screen ────────────────────────────────────────────────────────────────────

class AuditLogsScreen extends ConsumerStatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  ConsumerState<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends ConsumerState<AuditLogsScreen> {
  final _searchController = TextEditingController();
  AuditLogEntry? _selectedEntry;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(auditLogsProvider);
    final notifier = ref.read(auditLogsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, theme, state, notifier),
                        const SizedBox(height: 24),
                        _buildKpiRow(context, theme, state),
                        const SizedBox(height: 24),
                        _buildToolbar(context, theme, state, notifier),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  sliver: _buildLogTable(context, theme, state.filteredLogs),
                ),
              ],
            ),
          ),
          if (_selectedEntry != null)
            _buildDetailPanel(context, theme, _selectedEntry!),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, AuditLogsState state, AuditLogsNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Audit Logs', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Complete tamper-proof record of all platform events',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting audit log as CSV...'))),
              icon: const Icon(LucideIcons.download, size: 16),
              label: const Text('Export CSV'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generating compliance report...'))),
              icon: const Icon(LucideIcons.fileCheck, size: 16),
              label: const Text('Compliance Report'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiRow(BuildContext context, ThemeData theme, AuditLogsState state) {
    final kpis = [
      ('Total Events', state.allLogs.length.toString(), LucideIcons.activity, theme.colorScheme.primary),
      ('Today', state.todayCount.toString(), LucideIcons.calendar, Colors.blue),
      ('Failures', state.failureCount.toString(), LucideIcons.xCircle, Colors.red),
      ('Warnings', state.warningCount.toString(), LucideIcons.alertTriangle, Colors.orange),
      ('Critical', state.criticalCount.toString(), LucideIcons.alertOctagon, Colors.red.shade700),
    ];

    return Row(
      children: kpis.map((kpi) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kpi.$4.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(kpi.$3, size: 18, color: kpi.$4),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kpi.$2, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text(kpi.$1, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, AuditLogsState state, AuditLogsNotifier notifier) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            onChanged: notifier.setSearch,
            decoration: InputDecoration(
              hintText: 'Search by actor, action, or resource...',
              prefixIcon: const Icon(LucideIcons.search, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        notifier.setSearch('');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Severity Filter
        DropdownButtonHideUnderline(
          child: DropdownButton<AuditSeverity?>(
            value: state.filterSeverity,
            hint: const Text('Severity'),
            borderRadius: BorderRadius.circular(12),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Severities')),
              ...AuditSeverity.values.map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(_severityLabel(s)),
                  )),
            ],
            onChanged: notifier.setSeverity,
          ),
        ),
        const SizedBox(width: 12),
        // Category Filter
        DropdownButtonHideUnderline(
          child: DropdownButton<AuditCategory?>(
            value: state.filterCategory,
            hint: const Text('Category'),
            borderRadius: BorderRadius.circular(12),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Categories')),
              ...AuditCategory.values.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(_categoryLabel(c)),
                  )),
            ],
            onChanged: notifier.setCategory,
          ),
        ),
        const SizedBox(width: 12),
        // Status Filter
        DropdownButtonHideUnderline(
          child: DropdownButton<bool?>(
            value: state.filterSuccess,
            hint: const Text('Status'),
            borderRadius: BorderRadius.circular(12),
            items: const [
              DropdownMenuItem(value: null, child: Text('All Status')),
              DropdownMenuItem(value: true, child: Text('Success')),
              DropdownMenuItem(value: false, child: Text('Failed')),
            ],
            onChanged: notifier.setSuccess,
          ),
        ),
        const SizedBox(width: 12),
        if (state.filterSeverity != null || state.filterCategory != null || state.filterSuccess != null || state.searchQuery.isNotEmpty)
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              notifier.clearFilters();
            },
            icon: const Icon(LucideIcons.filterX, size: 16),
            label: const Text('Clear'),
          ),
        const Spacer(),
        Text(
          '${state.filteredLogs.length} of ${state.allLogs.length} events',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildLogTable(BuildContext context, ThemeData theme, List<AuditLogEntry> logs) {
    return SliverList.builder(
      itemCount: logs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                SizedBox(width: 120, child: Text('TIMESTAMP', style: _headerStyle(theme))),
                SizedBox(width: 90, child: Text('SEVERITY', style: _headerStyle(theme))),
                SizedBox(width: 140, child: Text('CATEGORY', style: _headerStyle(theme))),
                Expanded(child: Text('ACTOR', style: _headerStyle(theme))),
                Expanded(flex: 2, child: Text('ACTION', style: _headerStyle(theme))),
                Expanded(child: Text('RESOURCE', style: _headerStyle(theme))),
                SizedBox(width: 80, child: Text('STATUS', style: _headerStyle(theme))),
                SizedBox(width: 110, child: Text('IP ADDRESS', style: _headerStyle(theme))),
              ],
            ),
          );
        }

        final log = logs[index - 1];
        final isSelected = _selectedEntry?.id == log.id;

        return InkWell(
          onTap: () => setState(() => _selectedEntry = isSelected ? null : log),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : (index.isEven ? theme.colorScheme.surface : theme.colorScheme.surfaceVariant.withOpacity(0.2)),
              border: Border(
                left: isSelected ? BorderSide(color: theme.colorScheme.primary, width: 3) : BorderSide.none,
                bottom: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    DateFormat('MM/dd HH:mm:ss').format(log.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
                SizedBox(width: 90, child: _severityBadge(theme, log.severity)),
                SizedBox(
                  width: 140,
                  child: Text(
                    _categoryLabel(log.category),
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.actor, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                      Text(log.actorRole, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    log.action,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(log.resource, style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
                      Text(log.resourceId, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (log.success ? Colors.green : Colors.red).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.success ? 'Success' : 'Failed',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: log.success ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    log.ipAddress,
                    style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailPanel(BuildContext context, ThemeData theme, AuditLogEntry entry) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(left: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Event Detail', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () => setState(() => _selectedEntry = null),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(theme, 'Event ID', entry.id),
                  _detailRow(theme, 'Timestamp', DateFormat('MMM dd, yyyy HH:mm:ss').format(entry.timestamp)),
                  _detailRow(theme, 'Severity', _severityLabel(entry.severity)),
                  _detailRow(theme, 'Category', _categoryLabel(entry.category)),
                  const Divider(height: 32),
                  _detailRow(theme, 'Actor', entry.actor),
                  _detailRow(theme, 'Role', entry.actorRole),
                  _detailRow(theme, 'Action', entry.action),
                  _detailRow(theme, 'Resource', entry.resource),
                  _detailRow(theme, 'Resource ID', entry.resourceId),
                  const Divider(height: 32),
                  _detailRow(theme, 'Status', entry.success ? 'Success' : 'Failed'),
                  _detailRow(theme, 'IP Address', entry.ipAddress),
                  _detailRow(theme, 'Session ID', entry.sessionId),
                  const Divider(height: 32),
                  Text('Metadata', style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  )),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entry.metadata.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(e.key, style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                            ),
                            Expanded(
                              child: Text(e.value, style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            )),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _severityBadge(ThemeData theme, AuditSeverity severity) {
    final (color, label) = switch (severity) {
      AuditSeverity.info => (Colors.blue, 'Info'),
      AuditSeverity.warning => (Colors.orange, 'Warning'),
      AuditSeverity.critical => (Colors.red, 'Critical'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label, style: theme.textTheme.labelSmall?.copyWith(
        color: color.shade700,
        fontWeight: FontWeight.w600,
      )),
    );
  }

  TextStyle _headerStyle(ThemeData theme) => theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  String _severityLabel(AuditSeverity s) => switch (s) {
        AuditSeverity.info => 'Info',
        AuditSeverity.warning => 'Warning',
        AuditSeverity.critical => 'Critical',
      };

  String _categoryLabel(AuditCategory c) => switch (c) {
        AuditCategory.authentication => 'Authentication',
        AuditCategory.authorization => 'Authorization',
        AuditCategory.dataAccess => 'Data Access',
        AuditCategory.configuration => 'Configuration',
        AuditCategory.userManagement => 'User Mgmt',
        AuditCategory.documentManagement => 'Documents',
        AuditCategory.workflowExecution => 'Workflow',
        AuditCategory.systemEvent => 'System',
      };
}
