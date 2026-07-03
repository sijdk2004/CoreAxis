import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';

import '../domain/report_sharing_model.dart';
import 'providers/report_sharing_provider.dart';

class ReportSharingScreen extends ConsumerStatefulWidget {
  const ReportSharingScreen({super.key});

  @override
  ConsumerState<ReportSharingScreen> createState() => _ReportSharingScreenState();
}

class _ReportSharingScreenState extends ConsumerState<ReportSharingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {}); // Rebuild to update floating action button context if needed
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(reportSharingProvider);
    final notifier = ref.read(reportSharingProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme),
          _buildToolbar(context, theme, notifier),
          _buildTabBar(theme),
          const Divider(height: 1),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAccessTable(context, theme, state, notifier, ShareType.user),
                _buildAccessTable(context, theme, state, notifier, ShareType.role),
                _buildAccessTable(context, theme, state, notifier, ShareType.organization),
                _buildAccessTable(context, theme, state, notifier, ShareType.externalLink),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Sharing Center',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Securely manage who has access to your reports across users, roles, and external links.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, ThemeData theme, ReportSharingNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              onChanged: (value) => notifier.setSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Search shares...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showShareDialog(context, notifier),
            icon: const Icon(LucideIcons.share2, size: 16),
            label: const Text('Share Report'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return TabBar(
      controller: _tabController,
      labelColor: theme.colorScheme.primary,
      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
      indicatorColor: theme.colorScheme.primary,
      tabs: const [
        Tab(text: 'Users', icon: Icon(LucideIcons.user)),
        Tab(text: 'Roles', icon: Icon(LucideIcons.users)),
        Tab(text: 'Organizations', icon: Icon(LucideIcons.building2)),
        Tab(text: 'External Links', icon: Icon(LucideIcons.link2)),
      ],
    );
  }

  Widget _buildAccessTable(BuildContext context, ThemeData theme, ReportSharingState state, ReportSharingNotifier notifier, ShareType type) {
    final shares = state.filteredShares(type);

    if (shares.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.shieldAlert, size: 64, color: theme.dividerColor),
            const SizedBox(height: 16),
            Text('No active shares found', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Use the "Share Report" button to grant access.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(theme.colorScheme.surface),
            dividerThickness: 1,
            dataRowMaxHeight: 64,
            columns: [
              const DataColumn(label: Text('Report Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text(type == ShareType.externalLink ? 'Audience' : 'Recipient', style: const TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Permission', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Shared On', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Expires', style: TextStyle(fontWeight: FontWeight.bold))),
              if (type == ShareType.externalLink) const DataColumn(label: Text('Link', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: shares.map((share) {
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        Icon(LucideIcons.fileText, size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(share.reportName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: theme.colorScheme.primary.withAlpha(25),
                          child: Icon(
                            _getIconForType(share.type),
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(share.recipientName),
                      ],
                    ),
                  ),
                  DataCell(
                    DropdownButtonHideUnderline(
                      child: DropdownButton<SharePermission>(
                        value: share.permission,
                        icon: const Icon(LucideIcons.chevronDown, size: 16),
                        style: theme.textTheme.bodyMedium,
                        items: SharePermission.values.map((perm) {
                          return DropdownMenuItem(
                            value: perm,
                            child: Text(_capitalize(perm.name)),
                          );
                        }).toList(),
                        onChanged: share.permission == SharePermission.owner 
                            ? null // Owners cannot have their permission reduced this way
                            : (value) {
                                if (value != null) {
                                  notifier.updatePermission(share.id, value);
                                }
                              },
                      ),
                    ),
                  ),
                  DataCell(Text(DateFormat('MMM dd, yyyy').format(share.sharedAt))),
                  DataCell(
                    Text(
                      share.expiresAt != null ? DateFormat('MMM dd, yyyy').format(share.expiresAt!) : 'Never',
                      style: TextStyle(
                        color: share.expiresAt != null && share.expiresAt!.isBefore(DateTime.now()) 
                            ? Colors.red 
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (type == ShareType.externalLink)
                    DataCell(
                      IconButton(
                        icon: const Icon(LucideIcons.copy, size: 16),
                        tooltip: 'Copy Link',
                        onPressed: () {
                          if (share.externalLink != null) {
                            Clipboard.setData(ClipboardData(text: share.externalLink!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link copied to clipboard')),
                            );
                          }
                        },
                      ),
                    ),
                  DataCell(
                    IconButton(
                      icon: const Icon(LucideIcons.xCircle, size: 18, color: Colors.red),
                      tooltip: 'Revoke Access',
                      onPressed: share.permission == SharePermission.owner 
                          ? null 
                          : () => notifier.revokeShare(share.id),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(ShareType type) {
    switch (type) {
      case ShareType.user: return LucideIcons.user;
      case ShareType.role: return LucideIcons.users;
      case ShareType.organization: return LucideIcons.building2;
      case ShareType.externalLink: return LucideIcons.link2;
    }
  }

  String _capitalize(String s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';

  void _showShareDialog(BuildContext context, ReportSharingNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => _ShareReportDialog(notifier: notifier),
    );
  }
}

class _ShareReportDialog extends StatefulWidget {
  final ReportSharingNotifier notifier;

  const _ShareReportDialog({required this.notifier});

  @override
  State<_ShareReportDialog> createState() => _ShareReportDialogState();
}

class _ShareReportDialogState extends State<_ShareReportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reportController = TextEditingController();
  final _recipientController = TextEditingController();
  
  ShareType _shareType = ShareType.user;
  SharePermission _permission = SharePermission.view;
  DateTime? _expiryDate;
  bool _sendNotification = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Share Report'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _reportController,
                  decoration: const InputDecoration(
                    labelText: 'Report Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Text('Share With', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: ShareType.values.map((type) {
                    return ChoiceChip(
                      label: Text(_capitalizeType(type.name)),
                      selected: _shareType == type,
                      onSelected: (selected) {
                        if (selected) setState(() => _shareType = type);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    labelText: _shareType == ShareType.externalLink ? 'Audience Description' : 'Recipient Name/Email',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<SharePermission>(
                        initialValue: _permission,
                        decoration: const InputDecoration(
                          labelText: 'Permission',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          SharePermission.view,
                          SharePermission.download,
                          SharePermission.edit,
                        ].map((perm) {
                          return DropdownMenuItem(
                            value: perm,
                            child: Text(_capitalizeType(perm.name)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => _permission = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _expiryDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date (Optional)',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_expiryDate != null 
                              ? DateFormat('MMM dd, yyyy').format(_expiryDate!) 
                              : 'No Expiry'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_shareType != ShareType.externalLink)
                  CheckboxListTile(
                    title: const Text('Send email notification'),
                    value: _sendNotification,
                    onChanged: (value) {
                      if (value != null) setState(() => _sendNotification = value);
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.notifier.createShare(
                reportName: _reportController.text,
                recipientName: _recipientController.text,
                type: _shareType,
                permission: _permission,
                expiresAt: _expiryDate,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text(_shareType == ShareType.externalLink ? 'Generate Link' : 'Share'),
        ),
      ],
    );
  }

  String _capitalizeType(String s) {
    if (s == 'externalLink') return 'External Link';
    return s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '';
  }

  @override
  void dispose() {
    _reportController.dispose();
    _recipientController.dispose();
    super.dispose();
  }
}
