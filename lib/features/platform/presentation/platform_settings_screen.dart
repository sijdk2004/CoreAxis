import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

// --- STATE ---
class PlatformSettingsState {
  final String platformName;
  final String supportEmail;
  final String environment;
  final String themeMode;
  final Color primaryColor;
  final String language;
  final String timezone;
  final String dateFormat;
  final bool enforce2FA;
  final String sessionTimeout;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool inAppNotifications;
  final bool aiEnabled;
  final String aiModel;
  final String exportFormat;
  final String auditRetention;
  final String storageQuota;

  const PlatformSettingsState({
    this.platformName = 'CoreAxis ERP',
    this.supportEmail = 'support@coreaxis.com',
    this.environment = 'Production',
    this.themeMode = 'System',
    this.primaryColor = const Color(0xFF2563EB),
    this.language = 'English (US)',
    this.timezone = 'UTC',
    this.dateFormat = 'MM/DD/YYYY',
    this.enforce2FA = true,
    this.sessionTimeout = '30 Minutes',
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.inAppNotifications = true,
    this.aiEnabled = true,
    this.aiModel = 'GPT-4 (Enterprise)',
    this.exportFormat = 'PDF',
    this.auditRetention = '1 Year',
    this.storageQuota = '100 GB',
  });

  PlatformSettingsState copyWith({
    String? platformName,
    String? supportEmail,
    String? environment,
    String? themeMode,
    Color? primaryColor,
    String? language,
    String? timezone,
    String? dateFormat,
    bool? enforce2FA,
    String? sessionTimeout,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? inAppNotifications,
    bool? aiEnabled,
    String? aiModel,
    String? exportFormat,
    String? auditRetention,
    String? storageQuota,
  }) {
    return PlatformSettingsState(
      platformName: platformName ?? this.platformName,
      supportEmail: supportEmail ?? this.supportEmail,
      environment: environment ?? this.environment,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      dateFormat: dateFormat ?? this.dateFormat,
      enforce2FA: enforce2FA ?? this.enforce2FA,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      inAppNotifications: inAppNotifications ?? this.inAppNotifications,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiModel: aiModel ?? this.aiModel,
      exportFormat: exportFormat ?? this.exportFormat,
      auditRetention: auditRetention ?? this.auditRetention,
      storageQuota: storageQuota ?? this.storageQuota,
    );
  }
}

class PlatformSettingsNotifier extends Notifier<PlatformSettingsState> {
  @override
  PlatformSettingsState build() => const PlatformSettingsState();

  void updateSetting({
    String? platformName,
    String? supportEmail,
    String? environment,
    String? themeMode,
    Color? primaryColor,
    String? language,
    String? timezone,
    String? dateFormat,
    bool? enforce2FA,
    String? sessionTimeout,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? inAppNotifications,
    bool? aiEnabled,
    String? aiModel,
    String? exportFormat,
    String? auditRetention,
    String? storageQuota,
  }) {
    state = state.copyWith(
      platformName: platformName,
      supportEmail: supportEmail,
      environment: environment,
      themeMode: themeMode,
      primaryColor: primaryColor,
      language: language,
      timezone: timezone,
      dateFormat: dateFormat,
      enforce2FA: enforce2FA,
      sessionTimeout: sessionTimeout,
      emailNotifications: emailNotifications,
      smsNotifications: smsNotifications,
      inAppNotifications: inAppNotifications,
      aiEnabled: aiEnabled,
      aiModel: aiModel,
      exportFormat: exportFormat,
      auditRetention: auditRetention,
      storageQuota: storageQuota,
    );
  }
}

final platformSettingsProvider = NotifierProvider<PlatformSettingsNotifier, PlatformSettingsState>(PlatformSettingsNotifier.new);

// --- MODELS FOR MOCK TABLES ---
class MockLicense {
  final String id;
  final String user;
  final String role;
  final String licenseType;
  final String status;
  final DateTime assignedDate;

  MockLicense({
    required this.id,
    required this.user,
    required this.role,
    required this.licenseType,
    required this.status,
    required this.assignedDate,
  });
}

// --- SCREEN ---
class PlatformSettingsScreen extends ConsumerStatefulWidget {
  const PlatformSettingsScreen({super.key});

  @override
  ConsumerState<PlatformSettingsScreen> createState() => _PlatformSettingsScreenState();
}

class _PlatformSettingsScreenState extends ConsumerState<PlatformSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaving = false;
  
  // Search and sort for license table
  String _licenseSearchQuery = '';
  int _licenseSortColumnIndex = 0;
  bool _licenseSortAscending = true;
  
  final List<MockLicense> _mockLicenses = [
    MockLicense(id: 'LIC-001', user: 'Alice Johnson', role: 'System Admin', licenseType: 'Enterprise', status: 'Active', assignedDate: DateTime.now().subtract(const Duration(days: 365))),
    MockLicense(id: 'LIC-002', user: 'Bob Smith', role: 'Manager', licenseType: 'Professional', status: 'Active', assignedDate: DateTime.now().subtract(const Duration(days: 180))),
    MockLicense(id: 'LIC-003', user: 'Charlie Davis', role: 'User', licenseType: 'Basic', status: 'Revoked', assignedDate: DateTime.now().subtract(const Duration(days: 90))),
    MockLicense(id: 'LIC-004', user: 'Diana Evans', role: 'Developer', licenseType: 'Enterprise', status: 'Active', assignedDate: DateTime.now().subtract(const Duration(days: 45))),
    MockLicense(id: 'LIC-005', user: 'Evan Wright', role: 'Auditor', licenseType: 'Professional', status: 'Expired', assignedDate: DateTime.now().subtract(const Duration(days: 400))),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 11, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final state = ref.watch(platformSettingsProvider);
    final notifier = ref.read(platformSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Platform Settings Center'),
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0, top: 8, bottom: 8),
            child: FilledButton.icon(
              icon: _isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(LucideIcons.save, size: 18),
              label: const Text('Save Changes'),
              onPressed: _isSaving ? null : _handleSave,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Appearance'),
            Tab(text: 'Localization'),
            Tab(text: 'Security'),
            Tab(text: 'Notifications'),
            Tab(text: 'AI'),
            Tab(text: 'Reports'),
            Tab(text: 'Audit'),
            Tab(text: 'Storage'),
            Tab(text: 'Licensing'),
            Tab(text: 'System Information'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralTab(theme, state, notifier, isDesktop),
          _buildAppearanceTab(theme, state, notifier, isDesktop),
          _buildLocalizationTab(theme, state, notifier, isDesktop),
          _buildSecurityTab(theme, state, notifier, isDesktop),
          _buildNotificationsTab(theme, state, notifier, isDesktop),
          _buildAITab(theme, state, notifier, isDesktop),
          _buildReportsTab(theme, state, notifier, isDesktop),
          _buildAuditTab(theme, state, notifier, isDesktop),
          _buildStorageTab(theme, state, notifier, isDesktop),
          _buildLicensingTab(theme, isDesktop),
          _buildSystemInfoTab(theme, isDesktop),
        ],
      ),
    );
  }

  Widget _buildTabContainer(bool isDesktop, List<Widget> children) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map((c) => Padding(padding: const EdgeInsets.only(bottom: 24.0), child: c)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),
        ],
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String label, String value, Function(String) onChanged, {bool isPassword = false, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surface,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: Icon(LucideIcons.chevronDown, size: 20),
              style: theme.textTheme.bodyLarge,
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(ThemeData theme, String title, String subtitle, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  // --- TABS ---

  Widget _buildGeneralTab(ThemeData theme, PlatformSettingsState state, PlatformSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'General Settings', 'Configure core platform identity and environment settings.'),
      _buildTextField(theme, 'Platform Name', state.platformName, (val) => notifier.updateSetting(platformName: val)),
      _buildTextField(theme, 'Support Email', state.supportEmail, (val) => notifier.updateSetting(supportEmail: val)),
      _buildDropdown(theme, 'Environment', state.environment, ['Production', 'Staging', 'Development'], (val) => notifier.updateSetting(environment: val)),
    ]);
  }

  Widget _buildAppearanceTab(ThemeData theme, PlatformSettingsState state, PlatformSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Appearance', 'Customize the look and feel of the platform.'),
      _buildDropdown(theme, 'Theme Mode', state.themeMode, ['System', 'Light', 'Dark'], (val) => notifier.updateSetting(themeMode: val)),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Primary Color', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              const Color(0xFF2563EB), // Blue
              const Color(0xFF16A34A), // Green
              const Color(0xFFDC2626), // Red
              const Color(0xFF9333EA), // Purple
              const Color(0xFFF59E0B), // Yellow
            ].map((color) {
              final isSelected = state.primaryColor.value == color.value;
              return InkWell(
                onTap: () => notifier.updateSetting(primaryColor: color),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? theme.colorScheme.onSurface : Colors.transparent, width: 3),
                  ),
                  child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ]);
  }

  Widget _buildLocalizationTab(ThemeData theme, PlatformSettingsState state, PlatformSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Localization', 'Set global language, timezone, and formatting rules.'),
      _buildDropdown(theme, 'Language', state.language, ['English (US)', 'English (UK)', 'Spanish', 'French', 'German', 'Japanese'], (val) => notifier.updateSetting(language: val)),
      _buildDropdown(theme, 'Timezone', state.timezone, ['UTC', 'America/New_York', 'America/Los_Angeles', 'Europe/London', 'Asia/Tokyo'], (val) => notifier.updateSetting(timezone: val)),
      _buildDropdown(theme, 'Date Format', state.dateFormat, ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'], (val) => notifier.updateSetting(dateFormat: val)),
    ]);
  }

  Widget _buildSecurityTab(ThemeData theme, PlatformSettingsState state, PlatformSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Security', 'Manage authentication policies and session controls.'),
      _buildSwitchTile(theme, 'Enforce Two-Factor Authentication (2FA)', 'Require all administrative users to use 2FA.', state.enforce2FA, (val) => notifier.updateSetting(enforce2FA: val)),
      _buildDropdown(theme, 'Session Timeout', state.sessionTimeout, ['15 Minutes', '30 Minutes', '1 Hour', '24 Hours'], (val) => notifier.updateSetting(sessionTimeout: val)),
    ]);
  }

  Widget _buildNotificationsTab(ThemeData theme, PlatformSettingsState state, PlatformSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Notifications', 'Configure system-wide alert channels.'),
      _buildSwitchTile(theme, 'Email Notifications', 'Send system alerts via email.', state.emailNotifications, (val) => notifier.updateSetting(emailNotifications: val)),
      _buildSwitchTile(theme, 'SMS Notifications', 'Send critical alerts via SMS text messages.', state.smsNotifications, (val) => notifier.updateSetting(smsNotifications: val)),
      _buildSwitchTile(theme, 'In-App Notifications', 'Show toast and dashboard alerts inside the app.', state.inAppNotifications, (val) => notifier.updateSetting(inAppNotifications: val)),
    ]);
  }

  Widget _buildAITab(ThemeData theme, PlatformSettingsState state, PlatformSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'AI Configuration', 'Manage AI Copilot and automation models.'),
      _buildSwitchTile(theme, 'Enable AI Features', 'Turn on AI Copilot for all active tenants.', state.aiEnabled, (val) => notifier.updateSetting(aiEnabled: val)),
      if (state.aiEnabled) ...[
        _buildDropdown(theme, 'Default AI Model', state.aiModel, ['GPT-4 (Enterprise)', 'GPT-3.5 Turbo', 'Claude 3 Opus', 'Custom Model'], (val) => notifier.updateSetting(aiModel: val)),
      ]
    ]);
  }

  Widget _buildReportsTab(ThemeData theme, PlatformSettingsState state, PlatformSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Reports', 'Configure default exporting options.'),
      _buildDropdown(theme, 'Default Export Format', state.exportFormat, ['PDF', 'Excel (XLSX)', 'CSV', 'JSON'], (val) => notifier.updateSetting(exportFormat: val)),
    ]);
  }

  Widget _buildAuditTab(ThemeData theme, PlatformSettingsState state, PlatformSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Audit & Compliance', 'Settings for audit trails and logs.'),
      _buildDropdown(theme, 'Audit Log Retention', state.auditRetention, ['30 Days', '90 Days', '1 Year', 'Indefinite'], (val) => notifier.updateSetting(auditRetention: val)),
    ]);
  }

  Widget _buildStorageTab(ThemeData theme, PlatformSettingsState state, PlatformSettingsNotifier notifier, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'Storage', 'File upload and blob storage constraints.'),
      _buildDropdown(theme, 'Default Tenant Storage Quota', state.storageQuota, ['10 GB', '50 GB', '100 GB', '1 TB', 'Unlimited'], (val) => notifier.updateSetting(storageQuota: val)),
    ]);
  }

  Widget _buildLicensingTab(ThemeData theme, bool isDesktop) {
    // Filter and sort
    var filtered = _mockLicenses.where((l) => 
      l.user.toLowerCase().contains(_licenseSearchQuery.toLowerCase()) || 
      l.id.toLowerCase().contains(_licenseSearchQuery.toLowerCase())
    ).toList();
    
    filtered.sort((a, b) {
      if (_licenseSortColumnIndex == 0) {
        return _licenseSortAscending ? a.id.compareTo(b.id) : b.id.compareTo(a.id);
      } else if (_licenseSortColumnIndex == 1) {
        return _licenseSortAscending ? a.user.compareTo(b.user) : b.user.compareTo(a.user);
      } else if (_licenseSortColumnIndex == 4) {
        return _licenseSortAscending ? a.status.compareTo(b.status) : b.status.compareTo(a.status);
      }
      return 0;
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 32.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(theme, 'Licensing & Seats', 'Manage active licenses across the platform.'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search licenses...',
                    prefixIcon: Icon(LucideIcons.search, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _licenseSearchQuery = val),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                icon: Icon(LucideIcons.filter, size: 18),
                label: const Text('Filter'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(theme.colorScheme.surfaceContainerHighest),
                sortColumnIndex: _licenseSortColumnIndex,
                sortAscending: _licenseSortAscending,
                columns: [
                  DataColumn(
                    label: const SizedBox(width: 100, child: Text('License ID')),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _licenseSortColumnIndex = columnIndex;
                        _licenseSortAscending = ascending;
                      });
                    },
                  ),
                  DataColumn(
                    label: const SizedBox(width: 150, child: Text('User')),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _licenseSortColumnIndex = columnIndex;
                        _licenseSortAscending = ascending;
                      });
                    },
                  ),
                  const DataColumn(label: SizedBox(width: 120, child: Text('Role'))),
                  const DataColumn(label: SizedBox(width: 120, child: Text('Type'))),
                  DataColumn(
                    label: const SizedBox(width: 100, child: Text('Status')),
                    onSort: (columnIndex, ascending) {
                      setState(() {
                        _licenseSortColumnIndex = columnIndex;
                        _licenseSortAscending = ascending;
                      });
                    },
                  ),
                  const DataColumn(label: SizedBox(width: 120, child: Text('Assigned Date'))),
                  const DataColumn(label: SizedBox(width: 80, child: Text('Actions'))),
                ],
                rows: filtered.map((l) {
                  final statusColor = l.status == 'Active' ? Colors.green : (l.status == 'Revoked' ? Colors.red : Colors.orange);
                  return DataRow(
                    cells: [
                      DataCell(Text(l.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(l.user)),
                      DataCell(Text(l.role)),
                      DataCell(Text(l.licenseType)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(l.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      DataCell(Text(DateFormat('MMM dd, yyyy').format(l.assignedDate))),
                      DataCell(
                        IconButton(
                          icon: Icon(LucideIcons.moreVertical, size: 18),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Pagination Mock
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Showing ${filtered.length} of ${_mockLicenses.length} licenses', style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              Row(
                children: [
                  IconButton(icon: Icon(LucideIcons.chevronLeft), onPressed: () {}),
                  const Text('Page 1 of 1'),
                  IconButton(icon: Icon(LucideIcons.chevronRight), onPressed: null),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemInfoTab(ThemeData theme, bool isDesktop) {
    return _buildTabContainer(isDesktop, [
      _buildSectionHeader(theme, 'System Information', 'Technical details and current version.'),
      _buildInfoRow(theme, 'Version', 'v2.4.1 (Stable)'),
      _buildInfoRow(theme, 'Build Number', '84920'),
      _buildInfoRow(theme, 'Architecture', 'x86_64'),
      _buildInfoRow(theme, 'Database Schema', 'v14.2'),
      _buildInfoRow(theme, 'Dart/Flutter', 'Dart 3.x / Flutter 3.x'),
      _buildInfoRow(theme, 'Server OS', 'Ubuntu 22.04 LTS'),
      const SizedBox(height: 32),
      Center(
        child: FilledButton.tonalIcon(
          icon: Icon(LucideIcons.refreshCw, size: 18),
          label: const Text('Check for Updates'),
          onPressed: () {},
        ),
      ),
    ]);
  }

  Widget _buildInfoRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
