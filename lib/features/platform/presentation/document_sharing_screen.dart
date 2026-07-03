import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../domain/models/document_sharing_model.dart';
import 'providers/document_sharing_provider.dart';

// ─── Screen ────────────────────────────────────────────────────────────────────

class DocumentSharingScreen extends ConsumerStatefulWidget {
  final String documentId;
  const DocumentSharingScreen({super.key, required this.documentId});

  @override
  ConsumerState<DocumentSharingScreen> createState() => _DocumentSharingScreenState();
}

class _DocumentSharingScreenState extends ConsumerState<DocumentSharingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Trigger lazy load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(documentSharingProvider.notifier).stateFor(widget.documentId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Color / Icon helpers ─────────────────────────────────────────────────

  Color _levelColor(PermissionLevel level, ColorScheme cs) {
    switch (level) {
      case PermissionLevel.owner:    return Colors.purple;
      case PermissionLevel.share:    return Colors.indigo;
      case PermissionLevel.edit:     return cs.primary;
      case PermissionLevel.delete:   return Colors.red;
      case PermissionLevel.download: return Colors.teal;
      case PermissionLevel.view:     return Colors.grey.shade600;
    }
  }

  IconData _typeIcon(PermissionTargetType type) {
    switch (type) {
      case PermissionTargetType.user:         return LucideIcons.user;
      case PermissionTargetType.role:         return LucideIcons.users;
      case PermissionTargetType.organization: return LucideIcons.building2;
      case PermissionTargetType.publicLink:   return LucideIcons.link2;
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allState = ref.watch(documentSharingProvider);
    final notifier = ref.read(documentSharingProvider.notifier);

    // Get per-document state (falls back to loading placeholder)
    final docState = allState[widget.documentId] ??
        const DocumentSharingState(isLoaded: false);

    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          _buildTopBar(context, theme, docState, notifier, isDesktop),
          if (docState.isLoaded) _buildSummaryStrip(context, theme, docState),
          _buildTabBar(theme, docState),
          const Divider(height: 1),
          Expanded(
            child: !docState.isLoaded
                ? _buildLoading()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _PermissionList(
                        key: ValueKey('users_${widget.documentId}'),
                        permissions: docState.users,
                        type: PermissionTargetType.user,
                        documentId: widget.documentId,
                        notifier: notifier,
                        onShare: () => _openShareDialog(context, theme, notifier),
                        levelColor: _levelColor,
                        typeIcon: _typeIcon,
                      ),
                      _PermissionList(
                        key: ValueKey('roles_${widget.documentId}'),
                        permissions: docState.roles,
                        type: PermissionTargetType.role,
                        documentId: widget.documentId,
                        notifier: notifier,
                        onShare: () => _openShareDialog(context, theme, notifier),
                        levelColor: _levelColor,
                        typeIcon: _typeIcon,
                      ),
                      _PermissionList(
                        key: ValueKey('orgs_${widget.documentId}'),
                        permissions: docState.organizations,
                        type: PermissionTargetType.organization,
                        documentId: widget.documentId,
                        notifier: notifier,
                        onShare: () => _openShareDialog(context, theme, notifier),
                        levelColor: _levelColor,
                        typeIcon: _typeIcon,
                      ),
                      _PublicLinksTab(
                        key: ValueKey('links_${widget.documentId}'),
                        permissions: docState.publicLinks,
                        documentId: widget.documentId,
                        notifier: notifier,
                        onShare: () => _openShareDialog(
                          context, theme, notifier,
                          startTab: PermissionTargetType.publicLink,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading permissions...'),
        ],
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(
    BuildContext context,
    ThemeData theme,
    DocumentSharingState docState,
    DocumentSharingNotifier notifier,
    bool isDesktop,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            tooltip: 'Back to Document',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/platform/documents');
              }
            },
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sharing & Permissions',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                'Document ID: ${widget.documentId}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isDesktop) ...[
            OutlinedButton.icon(
              onPressed: () => notifier.refresh(widget.documentId),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Refresh'),
            ),
            const SizedBox(width: 12),
          ],
          FilledButton.icon(
            onPressed: () => _openShareDialog(context, theme, notifier),
            icon: const Icon(LucideIcons.userPlus, size: 16),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  // ─── Summary Strip ────────────────────────────────────────────────────────

  Widget _buildSummaryStrip(
    BuildContext context,
    ThemeData theme,
    DocumentSharingState docState,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Row(
        children: [
          _summaryChip(theme, '${docState.totalCount} People with access',
              LucideIcons.users, theme.colorScheme.primary),
          const SizedBox(width: 16),
          _summaryChip(theme, '${docState.publicLinks.length} Public links',
              LucideIcons.link2, Colors.teal),
          if (docState.hasExpiring) ...[
            const SizedBox(width: 16),
            _summaryChip(theme, 'Expiring soon', LucideIcons.clock3, Colors.orange),
          ],
          if (docState.hasExpired) ...[
            const SizedBox(width: 16),
            _summaryChip(theme, 'Has expired entries', LucideIcons.alertTriangle, Colors.red),
          ],
        ],
      ),
    );
  }

  Widget _summaryChip(ThemeData theme, String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        )),
      ],
    );
  }

  // ─── Tab Bar ──────────────────────────────────────────────────────────────

  Widget _buildTabBar(ThemeData theme, DocumentSharingState docState) {
    return Container(
      color: theme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(child: _tabLabel('Users',         docState.users.length,         theme, LucideIcons.user)),
          Tab(child: _tabLabel('Roles',         docState.roles.length,         theme, LucideIcons.users)),
          Tab(child: _tabLabel('Organizations', docState.organizations.length, theme, LucideIcons.building2)),
          Tab(child: _tabLabel('Public Links',  docState.publicLinks.length,   theme, LucideIcons.link2)),
        ],
      ),
    );
  }

  Widget _tabLabel(String label, int count, ThemeData theme, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 6),
        Text(label),
        if (count > 0) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ─── Share Dialog ─────────────────────────────────────────────────────────

  void _openShareDialog(
    BuildContext context,
    ThemeData theme,
    DocumentSharingNotifier notifier, {
    PermissionTargetType startTab = PermissionTargetType.user,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ShareDialog(
        documentId: widget.documentId,
        notifier: notifier,
        initialTab: startTab,
      ),
    );
  }
}

// ─── Permission List Tab ──────────────────────────────────────────────────────

class _PermissionList extends StatefulWidget {
  final List<DocumentPermission> permissions;
  final PermissionTargetType type;
  final String documentId;
  final DocumentSharingNotifier notifier;
  final VoidCallback onShare;
  final Color Function(PermissionLevel, ColorScheme) levelColor;
  final IconData Function(PermissionTargetType) typeIcon;

  const _PermissionList({
    super.key,
    required this.permissions,
    required this.type,
    required this.documentId,
    required this.notifier,
    required this.onShare,
    required this.levelColor,
    required this.typeIcon,
  });

  @override
  State<_PermissionList> createState() => _PermissionListState();
}

class _PermissionListState extends State<_PermissionList> {
  String _search = '';
  String _sortField = 'name';
  bool _sortAsc = true;
  PermissionLevel? _filterLevel;
  int _page = 0;
  static const _perPage = 8;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DocumentPermission> get _filtered {
    var list = widget.permissions.where((p) {
      if (_search.isNotEmpty && !p.targetName.toLowerCase().contains(_search)) {
        return false;
      }
      if (_filterLevel != null && p.permissionLevel != _filterLevel) {
        return false;
      }
      return true;
    }).toList();

    list.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case 'level':
          cmp = a.permissionLevel.rank.compareTo(b.permissionLevel.rank);
          break;
        case 'granted':
          cmp = a.grantedAt.compareTo(b.grantedAt);
          break;
        case 'expiry':
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          cmp = a.expiryDate!.compareTo(b.expiryDate!);
          break;
        default:
          cmp = a.targetName.compareTo(b.targetName);
      }
      return _sortAsc ? cmp : -cmp;
    });
    return list;
  }

  String get _typeLabel => switch (widget.type) {
        PermissionTargetType.user         => 'User',
        PermissionTargetType.role         => 'Role',
        PermissionTargetType.organization => 'Organization',
        PermissionTargetType.publicLink   => 'Link',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;
    final pageItems = filtered.skip(_page * _perPage).take(_perPage).toList();
    final totalPages = (filtered.length / _perPage).ceil().clamp(1, 999);

    if (widget.permissions.isEmpty) {
      return _buildEmpty(context, theme);
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToolbar(theme, filtered.length),
          const SizedBox(height: 16),
          _buildTableHeader(theme),
          const Divider(height: 1),
          Expanded(
            child: pageItems.isEmpty
                ? Center(child: Text('No results match your filter.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)))
                : ListView.separated(
                    itemCount: pageItems.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
                    itemBuilder: (ctx, i) =>
                        _buildRow(ctx, theme, pageItems[i])
                            .animate()
                            .fadeIn(delay: Duration(milliseconds: 40 * i)),
                  ),
          ),
          if (totalPages > 1) _buildPagination(theme, totalPages, filtered.length),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(widget.typeIcon(widget.type), size: 40,
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Text('No $_typeLabel permissions', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Grant access to a specific $_typeLabel to get started.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: widget.onShare,
            icon: const Icon(LucideIcons.plus, size: 16),
            label: Text('Add $_typeLabel Permission'),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(ThemeData theme, int count) {
    return Row(
      children: [
        SizedBox(
          width: 260,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() { _search = v.toLowerCase(); _page = 0; }),
            decoration: InputDecoration(
              hintText: 'Search $_typeLabel...',
              prefixIcon: const Icon(LucideIcons.search, size: 16),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x, size: 14),
                      onPressed: () { _searchCtrl.clear(); setState(() { _search = ''; _page = 0; }); },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<PermissionLevel?>(
              value: _filterLevel,
              hint: const Text('All Levels'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Levels')),
                ...PermissionLevel.values.map((l) =>
                  DropdownMenuItem(value: l, child: Text(l.label))),
              ],
              onChanged: (v) => setState(() { _filterLevel = v; _page = 0; }),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const Spacer(),
        Text(
          '$count ${count == 1 ? _typeLabel.toLowerCase() : '${_typeLabel.toLowerCase()}s'}',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildTableHeader(ThemeData theme) {
    Widget col(String label, String field, {int flex = 1}) {
      final active = _sortField == field;
      return Expanded(
        flex: flex,
        child: InkWell(
          onTap: () => setState(() {
            _sortAsc = _sortField == field ? !_sortAsc : true;
            _sortField = field;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Text(label, style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: active ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                )),
                const SizedBox(width: 4),
                if (active)
                  Icon(
                    _sortAsc ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                    size: 12, color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Row(
        children: [
          col('NAME / EMAIL', 'name', flex: 3),
          col('PERMISSION',   'level', flex: 2),
          col('GRANTED',      'granted', flex: 2),
          col('EXPIRY',       'expiry', flex: 2),
          const SizedBox(width: 100),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, ThemeData theme, DocumentPermission p) {
    final color = widget.levelColor(p.permissionLevel, theme.colorScheme);
    final isOwner = p.permissionLevel == PermissionLevel.owner;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Avatar + name (flex 3)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    (p.targetAvatar ?? p.targetName.substring(0, 1)).toUpperCase(),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.targetName,
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      Text('ID: ${p.targetId}',
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Permission (flex 2)
          Expanded(
            flex: 2,
            child: _PermissionBadge(level: p.permissionLevel, color: color),
          ),
          // Granted (flex 2)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('dd MMM yyyy').format(p.grantedAt), style: theme.textTheme.bodySmall),
                Text('by ${p.grantedBy}',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          // Expiry (flex 2)
          Expanded(
            flex: 2,
            child: p.expiryDate != null
                ? Row(
                    children: [
                      Icon(
                        p.isExpired ? LucideIcons.alertCircle
                            : p.expiresInWarning ? LucideIcons.clock3 : LucideIcons.calendar,
                        size: 12,
                        color: p.isExpired ? Colors.red : p.expiresInWarning ? Colors.orange : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yy').format(p.expiryDate!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: p.isExpired ? Colors.red : p.expiresInWarning ? Colors.orange : null,
                        ),
                      ),
                    ],
                  )
                : Text('No expiry', style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
          ),
          // Actions
          SizedBox(
            width: 100,
            child: isOwner
                ? Chip(
                    label: const Text('Owner'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.purple.withValues(alpha: 0.1),
                    labelStyle: const TextStyle(color: Colors.purple, fontSize: 11, fontWeight: FontWeight.bold),
                    side: BorderSide(color: Colors.purple.withValues(alpha: 0.3)),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(LucideIcons.sliders, size: 16),
                        tooltip: 'Change Permission',
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                            enabled: false,
                            child: Text('CHANGE PERMISSION',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                          ),
                          ...PermissionLevel.values
                              .where((l) => l != PermissionLevel.owner && l != p.permissionLevel)
                              .map((l) => PopupMenuItem(
                                    value: 'level:${l.label}',
                                    child: Row(
                                      children: [
                                        Icon(_levelIcon(l), size: 14),
                                        const SizedBox(width: 8),
                                        Text(l.label),
                                      ],
                                    ),
                                  )),
                          const PopupMenuDivider(),
                          PopupMenuItem(
                            value: 'revoke',
                            child: Row(
                              children: [
                                Icon(LucideIcons.userMinus, size: 14, color: Colors.red.shade700),
                                const SizedBox(width: 8),
                                Text('Revoke Access', style: TextStyle(color: Colors.red.shade700)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (val) {
                          if (val == 'revoke') {
                            widget.notifier.revokePermission(widget.documentId, p.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Access revoked for ${p.targetName}')));
                          } else if (val.startsWith('level:')) {
                            final newLevel = PermissionLevelExt.fromString(val.substring(6));
                            widget.notifier.updatePermissionLevel(widget.documentId, p.id, newLevel);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${p.targetName} — updated to ${newLevel.label}')));
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(LucideIcons.userMinus, size: 16, color: Colors.red.shade400),
                        tooltip: 'Revoke',
                        onPressed: () => _confirmRevoke(context, p),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  IconData _levelIcon(PermissionLevel l) {
    switch (l) {
      case PermissionLevel.view:     return LucideIcons.eye;
      case PermissionLevel.download: return LucideIcons.download;
      case PermissionLevel.edit:     return LucideIcons.filePen;
      case PermissionLevel.delete:   return LucideIcons.trash2;
      case PermissionLevel.share:    return LucideIcons.share2;
      case PermissionLevel.owner:    return LucideIcons.crown;
    }
  }

  void _confirmRevoke(BuildContext context, DocumentPermission p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Access'),
        content: Text('Remove ${p.permissionLevel.label} access for ${p.targetName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              widget.notifier.revokePermission(widget.documentId, p.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Access revoked for ${p.targetName}')));
            },
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(ThemeData theme, int totalPages, int total) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${_page + 1} of $totalPages  ·  $total total',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft, size: 16),
                onPressed: _page > 0 ? () => setState(() => _page--) : null,
              ),
              ...List.generate(totalPages.clamp(0, 5), (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                    backgroundColor: _page == i
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : null,
                  ),
                  onPressed: () => setState(() => _page = i),
                  child: Text('${i + 1}',
                      style: TextStyle(
                        fontWeight: _page == i ? FontWeight.bold : FontWeight.normal,
                        color: _page == i ? theme.colorScheme.primary : null,
                      )),
                ),
              )),
              IconButton(
                icon: const Icon(LucideIcons.chevronRight, size: 16),
                onPressed: _page < totalPages - 1 ? () => setState(() => _page++) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Permission Badge ─────────────────────────────────────────────────────────

class _PermissionBadge extends StatelessWidget {
  final PermissionLevel level;
  final Color color;
  const _PermissionBadge({required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(level.label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Public Links Tab ─────────────────────────────────────────────────────────

class _PublicLinksTab extends StatelessWidget {
  final List<DocumentPermission> permissions;
  final String documentId;
  final DocumentSharingNotifier notifier;
  final VoidCallback onShare;

  const _PublicLinksTab({
    super.key,
    required this.permissions,
    required this.documentId,
    required this.notifier,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (permissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(LucideIcons.link2, size: 40, color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text('No public links generated',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Generate a shareable link for external stakeholders.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onShare,
              icon: const Icon(LucideIcons.link, size: 16),
              label: const Text('Generate Link'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${permissions.length} Active ${permissions.length == 1 ? 'Link' : 'Links'}',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              FilledButton.tonalIcon(
                onPressed: onShare,
                icon: const Icon(LucideIcons.plus, size: 14),
                label: const Text('Generate Link'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: permissions.length,
              itemBuilder: (ctx, i) => _LinkCard(
                permission: permissions[i],
                documentId: documentId,
                notifier: notifier,
              ).animate().fadeIn(delay: Duration(milliseconds: 60 * i)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final DocumentPermission permission;
  final String documentId;
  final DocumentSharingNotifier notifier;

  const _LinkCard({
    required this.permission,
    required this.documentId,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = permission;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.link2, size: 18, color: Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.targetName,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Created ${DateFormat('dd MMM yyyy').format(p.grantedAt)} by ${p.grantedBy}',
                        style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              _PermissionBadge(level: p.permissionLevel, color: Colors.teal),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 18, color: Colors.red.shade400),
                tooltip: 'Revoke Link',
                onPressed: () {
                  notifier.revokePermission(documentId, p.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link revoked successfully')));
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    p.linkUrl ?? 'No URL generated',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(LucideIcons.copy, size: 16),
                  tooltip: 'Copy Link',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    if (p.linkUrl != null) {
                      Clipboard.setData(ClipboardData(text: p.linkUrl!));
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied to clipboard')));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (p.expiryDate != null) ...[
                Icon(
                  p.isExpired ? LucideIcons.alertCircle : LucideIcons.clock3,
                  size: 13,
                  color: p.isExpired ? Colors.red : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  p.isExpired
                      ? 'Expired ${DateFormat('dd MMM yy').format(p.expiryDate!)}'
                      : 'Expires ${DateFormat('dd MMM yy').format(p.expiryDate!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: p.isExpired ? Colors.red : Colors.orange),
                ),
                const SizedBox(width: 16),
              ],
              if (p.linkViewCount != null) ...[
                Icon(LucideIcons.eye, size: 13, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('${p.linkViewCount} views',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
              if (p.linkToken != null) ...[
                const SizedBox(width: 16),
                Icon(LucideIcons.keySquare, size: 13, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 4),
                Text('Token: ${p.linkToken}',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant, fontFamily: 'monospace')),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Share Dialog ─────────────────────────────────────────────────────────────

class _ShareDialog extends StatefulWidget {
  final String documentId;
  final DocumentSharingNotifier notifier;
  final PermissionTargetType initialTab;

  const _ShareDialog({
    required this.documentId,
    required this.notifier,
    required this.initialTab,
  });

  @override
  State<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<_ShareDialog> {
  late PermissionTargetType _shareType;
  String _targetName = '';
  PermissionLevel _permLevel = PermissionLevel.view;
  DateTime? _expiryDate;
  String? _generatedLink;
  String? _generatedToken;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();

  final _userSuggestions = const [
    'Alice Smith (alice@acmecorp.com)',
    'Bob Jones (bob@acmecorp.com)',
    'Charlie Davis (charlie@acmecorp.com)',
    'Dana White (dana@acmecorp.com)',
    'Eve Adams (eve@acmecorp.com)',
    'Frank Castle (frank@acmecorp.com)',
  ];
  final _roleSuggestions = const [
    'Finance Team', 'HR Managers', 'Compliance Officers', 'Executive Team', 'Auditors',
  ];
  final _orgSuggestions = const [
    'Acme Corp (External)', 'Partner Logistics Ltd', 'Vendor Network', 'Tech Partners Inc',
  ];

  @override
  void initState() {
    super.initState();
    _shareType = widget.initialTab;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _isLink => _shareType == PermissionTargetType.publicLink;

  List<String> get _suggestions {
    switch (_shareType) {
      case PermissionTargetType.user:         return _userSuggestions;
      case PermissionTargetType.role:         return _roleSuggestions;
      case PermissionTargetType.organization: return _orgSuggestions;
      default: return [];
    }
  }

  String get _targetLabel => switch (_shareType) {
        PermissionTargetType.user         => 'User',
        PermissionTargetType.role         => 'Role',
        PermissionTargetType.organization => 'Organization',
        PermissionTargetType.publicLink   => 'Link',
      };

  void _generateLink() {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    final token = '${widget.documentId.hashCode.abs().toString().substring(0, 3)}${ts.substring(ts.length - 6)}';
    setState(() {
      _generatedToken = token;
      _generatedLink = 'https://erp.acmecorp.com/share/$token';
    });
  }

  Future<void> _save() async {
    if (!_isLink) {
      if (!_formKey.currentState!.validate()) return;
    } else {
      if (_generatedLink == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please generate a link first')));
        return;
      }
      if (_targetName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add a link name / purpose')));
        return;
      }
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final now = DateTime.now();
    widget.notifier.addPermission(
      widget.documentId,
      DocumentPermission(
        id: 'perm_${now.millisecondsSinceEpoch}',
        documentId: widget.documentId,
        targetId: 't_${now.millisecondsSinceEpoch}',
        targetName: _targetName,
        targetAvatar: _targetName.length >= 2 ? _targetName.substring(0, 2).toUpperCase() : '?',
        type: _shareType,
        permissionLevel: _permLevel,
        expiryDate: _expiryDate,
        grantedAt: now,
        grantedBy: 'Alice Smith',
        isActive: true,
        linkUrl: _generatedLink,
        linkToken: _generatedToken,
        linkViewCount: _isLink ? 0 : null,
      ),
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissions saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─ Header ─
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.share2, size: 20, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share Document',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text('Grant access to users, roles, organizations, or via link',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // ─ Body ─
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type selector
                      _label(theme, 'Share With'),
                      const SizedBox(height: 8),
                      SegmentedButton<PermissionTargetType>(
                        style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                        segments: const [
                          ButtonSegment(value: PermissionTargetType.user,
                              icon: Icon(LucideIcons.user, size: 14), label: Text('User')),
                          ButtonSegment(value: PermissionTargetType.role,
                              icon: Icon(LucideIcons.users, size: 14), label: Text('Role')),
                          ButtonSegment(value: PermissionTargetType.organization,
                              icon: Icon(LucideIcons.building2, size: 14), label: Text('Org')),
                          ButtonSegment(value: PermissionTargetType.publicLink,
                              icon: Icon(LucideIcons.link2, size: 14), label: Text('Link')),
                        ],
                        selected: {_shareType},
                        onSelectionChanged: (set) => setState(() {
                          _shareType = set.first;
                          _nameCtrl.clear();
                          _targetName = '';
                          _generatedLink = null;
                          _generatedToken = null;
                        }),
                      ),
                      const SizedBox(height: 24),

                      if (_isLink) ...[
                        // ─ Link mode ─
                        _label(theme, 'Link Name / Purpose'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameCtrl,
                          onChanged: (v) => setState(() => _targetName = v),
                          decoration: const InputDecoration(
                            hintText: 'e.g. Vendor Review Link',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _label(theme, 'Generated Link'),
                        const SizedBox(height: 8),
                        if (_generatedLink != null)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.checkCircle, color: Colors.green, size: 16),
                                    const SizedBox(width: 8),
                                    const Text('Link generated',
                                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(LucideIcons.refreshCw, size: 14),
                                      tooltip: 'Regenerate',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: _generateLink,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(_generatedLink!,
                                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    IconButton(
                                      icon: const Icon(LucideIcons.copy, size: 14),
                                      tooltip: 'Copy',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: _generatedLink!));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Link copied')));
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            onPressed: _generateLink,
                            icon: const Icon(LucideIcons.link, size: 16),
                            label: const Text('Generate Shareable Link'),
                            style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                          ),
                      ] else ...[
                        // ─ User / Role / Org mode ─
                        _label(theme, _targetLabel),
                        const SizedBox(height: 8),
                        Autocomplete<String>(
                          optionsBuilder: (tv) {
                            if (tv.text.isEmpty) return _suggestions;
                            return _suggestions.where(
                                (s) => s.toLowerCase().contains(tv.text.toLowerCase()));
                          },
                          onSelected: (s) => setState(() => _targetName = s),
                          fieldViewBuilder: (ctx, ctrl, fn, onSub) {
                            _nameCtrl.addListener(() {
                              // Keep _targetName in sync
                            });
                            return TextFormField(
                              controller: ctrl,
                              focusNode: fn,
                              onChanged: (v) => setState(() => _targetName = v),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Please enter a $_targetLabel name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: _shareType == PermissionTargetType.user
                                    ? 'Search by name or email...'
                                    : 'Search $_targetLabel...',
                                prefixIcon: const Icon(LucideIcons.search, size: 16),
                                border: const OutlineInputBorder(),
                              ),
                            );
                          },
                          optionsViewBuilder: (ctx, onSel, opts) => Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 450,
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.all(8),
                                  itemCount: opts.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (ctx, i) {
                                    final opt = opts.elementAt(i);
                                    return ListTile(
                                      dense: true,
                                      leading: CircleAvatar(
                                        radius: 14,
                                        child: Text(opt[0].toUpperCase(),
                                            style: const TextStyle(fontSize: 11)),
                                      ),
                                      title: Text(opt),
                                      onTap: () => onSel(opt),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // ─ Permission level chips ─
                      _label(theme, 'Permission Level'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: PermissionLevel.values
                            .where((l) => l != PermissionLevel.owner)
                            .map((l) {
                          final sel = _permLevel == l;
                          final color = _chipColor(l, theme.colorScheme);
                          return ChoiceChip(
                            avatar: Icon(_levelIconSmall(l), size: 14,
                                color: sel ? Colors.white : color),
                            label: Text(l.label),
                            selected: sel,
                            onSelected: (_) => setState(() => _permLevel = l),
                            selectedColor: color,
                            backgroundColor: theme.colorScheme.surface,
                            labelStyle: TextStyle(
                              color: sel ? Colors.white : null,
                              fontWeight: sel ? FontWeight.w600 : null,
                            ),
                            side: BorderSide(color: sel ? color : theme.dividerColor),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Text(_permDescription(_permLevel),
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic)),
                      const SizedBox(height: 20),

                      // ─ Expiry date ─
                      _label(theme, 'Expiry Date (Optional)'),
                      const SizedBox(height: 8),
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now().add(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _expiryDate = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.calendar, size: 16,
                                  color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _expiryDate != null
                                      ? DateFormat('dd MMMM yyyy').format(_expiryDate!)
                                      : 'No expiry — access never expires',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _expiryDate == null
                                        ? theme.colorScheme.onSurfaceVariant
                                        : null,
                                  ),
                                ),
                              ),
                              if (_expiryDate != null)
                                IconButton(
                                  icon: const Icon(LucideIcons.x, size: 14),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => setState(() => _expiryDate = null),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ─ Access summary ─
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.info, size: 16, color: theme.colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _accessSummary(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ─ Actions ─
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: theme.dividerColor))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(LucideIcons.share2, size: 16),
                    label: Text(_isSaving ? 'Saving...' : 'Share Document'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(ThemeData theme, String text) {
    return Text(text, style: theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurfaceVariant,
    ));
  }

  Color _chipColor(PermissionLevel l, ColorScheme cs) {
    switch (l) {
      case PermissionLevel.view:     return Colors.grey.shade600;
      case PermissionLevel.download: return Colors.teal;
      case PermissionLevel.edit:     return cs.primary;
      case PermissionLevel.delete:   return Colors.red;
      case PermissionLevel.share:    return Colors.indigo;
      default:                       return Colors.purple;
    }
  }

  IconData _levelIconSmall(PermissionLevel l) {
    switch (l) {
      case PermissionLevel.view:     return LucideIcons.eye;
      case PermissionLevel.download: return LucideIcons.download;
      case PermissionLevel.edit:     return LucideIcons.filePen;
      case PermissionLevel.delete:   return LucideIcons.trash2;
      case PermissionLevel.share:    return LucideIcons.share2;
      default:                       return LucideIcons.crown;
    }
  }

  String _permDescription(PermissionLevel l) {
    switch (l) {
      case PermissionLevel.view:     return 'Can view the document online only. Cannot download or edit.';
      case PermissionLevel.download: return 'Can view and download the document. Cannot edit.';
      case PermissionLevel.edit:     return 'Can view, download, and edit the document content.';
      case PermissionLevel.delete:   return 'Can view, download, edit, and delete the document.';
      case PermissionLevel.share:    return 'Can manage who has access to this document.';
      default:                       return 'Full control including permanent deletion.';
    }
  }

  String _accessSummary() {
    final target = _isLink
        ? (_targetName.isEmpty ? 'Anyone with the link' : _targetName)
        : (_targetName.isEmpty ? 'the selected ${_targetLabel.toLowerCase()}' : _targetName);
    final expiryStr = _expiryDate != null
        ? ' until ${DateFormat('dd MMM yyyy').format(_expiryDate!)}'
        : ' with no expiry';
    return '$target will have ${_permLevel.label} access to this document$expiryStr.';
  }
}
