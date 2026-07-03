import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'industry_pack_details_screen.dart';

class IndustryPackConfigurationScreen extends ConsumerStatefulWidget {
  final String packId;
  const IndustryPackConfigurationScreen({super.key, required this.packId});

  @override
  ConsumerState<IndustryPackConfigurationScreen> createState() => _IndustryPackConfigurationScreenState();
}

class _IndustryPackConfigurationScreenState extends ConsumerState<IndustryPackConfigurationScreen> {
  int _selectedTabIndex = 0;
  bool _isSaving = false;
  bool _isValidating = false;
  bool _showPreview = false;
  String _previewMode = 'Desktop'; // Desktop, Tablet, Mobile

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'General', 'icon': LucideIcons.settings},
    {'title': 'Modules', 'icon': LucideIcons.blocks},
    {'title': 'Navigation', 'icon': LucideIcons.compass},
    {'title': 'Dependencies', 'icon': LucideIcons.gitFork},
    {'title': 'Integrations', 'icon': LucideIcons.plug},
    {'title': 'Security', 'icon': LucideIcons.shieldAlert},
    {'title': 'Licensing', 'icon': LucideIcons.key},
    {'title': 'Feature Flags', 'icon': LucideIcons.flag},
    {'title': 'System Configuration', 'icon': LucideIcons.server},
  ];

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuration saved successfully'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _handleValidate() async {
    setState(() => _isValidating = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isValidating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Validation complete. See right panel.'), backgroundColor: Colors.blue),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pack = ref.watch(industryPackDetailProvider(widget.packId));
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);
    final hasRightPanelSpace = ResponsiveBreakpoints.of(context).largerThan(DESKTOP);

    if (pack == null) {
      return const Scaffold(body: Center(child: Text('Pack not found')));
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pack.name} Configuration', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Version ${pack.version} • ${pack.industry} • Status: Healthy', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.refreshCcw, size: 16),
            label: const Text('Reset'),
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: _isValidating ? null : _handleValidate,
            icon: _isValidating
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(LucideIcons.checkCircle2, size: 16),
            label: Text(_isValidating ? 'Validating...' : 'Validate'),
          ),
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pack published to users'), backgroundColor: Colors.purple),
                );
            },
            icon: const Icon(LucideIcons.uploadCloud, size: 16),
            label: const Text('Publish'),
            style: FilledButton.styleFrom(backgroundColor: pack.themeColor.withValues(alpha: 0.1), foregroundColor: pack.themeColor),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _isSaving ? null : _handleSave,
            icon: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(LucideIcons.save, size: 16),
            label: Text(_isSaving ? 'Saving...' : 'Save Configuration'),
            style: FilledButton.styleFrom(backgroundColor: pack.themeColor),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar Tabs
          if (isDesktop) _buildSidebar(theme, pack),
          if (isDesktop) const VerticalDivider(width: 1),
          // Main Content
          Expanded(
            child: Column(
              children: [
                if (!isDesktop) _buildHorizontalTabs(theme, pack),
                if (!isDesktop) const Divider(height: 1),
                Expanded(child: _buildContentArea(theme, pack)),
              ],
            ),
          ),
          // Right Validation/Preview Panel
          if (hasRightPanelSpace) const VerticalDivider(width: 1),
          if (hasRightPanelSpace) _buildRightPanel(theme, pack),
        ],
      ),
      endDrawer: !hasRightPanelSpace
          ? Drawer(
              width: 350,
              child: _buildRightPanel(theme, pack, isDrawer: true),
            )
          : null,
      floatingActionButton: !hasRightPanelSpace
          ? FloatingActionButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              backgroundColor: pack.themeColor,
              child: const Icon(LucideIcons.panelRightClose, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSidebar(ThemeData theme, IndustryPackDetail pack) {
    return Container(
      width: 250,
      color: theme.colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? pack.themeColor.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 20,
                      color: isSelected ? pack.themeColor : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tab['title'] as String,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? pack.themeColor : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalTabs(ThemeData theme, IndustryPackDetail pack) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tab['title'] as String),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedTabIndex = index),
              selectedColor: pack.themeColor.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? pack.themeColor : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentArea(ThemeData theme, IndustryPackDetail pack) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _tabs[_selectedTabIndex]['title'] as String,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_selectedTabIndex == 1) // Modules
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.plus, size: 16),
                  label: const Text('Install Module'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _buildCurrentTabContent(theme, pack),
        ],
      ),
    );
  }

  Widget _buildRightPanel(ThemeData theme, IndustryPackDetail pack, {bool isDrawer = false}) {
    return Container(
      width: isDrawer ? null : 350,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Validation'), icon: Icon(LucideIcons.checkSquare)),
                      ButtonSegment(value: true, label: Text('Preview'), icon: Icon(LucideIcons.monitorPlay)),
                    ],
                    selected: {_showPreview},
                    onSelectionChanged: (val) => setState(() => _showPreview = val.first),
                    showSelectedIcon: false,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showPreview ? _buildPreviewPanel(theme, pack) : _buildValidationPanel(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationPanel(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildValidationItem(theme, 'Navigation Complete', true),
        _buildValidationItem(theme, 'Dependencies Valid', true),
        _buildValidationItem(theme, 'Permissions Configured', true),
        _buildValidationItem(theme, 'Routes Registered', true),
        _buildValidationItem(theme, 'Missing Module Icon', false, isWarning: true),
        _buildValidationItem(theme, 'Unused Permission Role', false, isWarning: true),
      ],
    );
  }

  Widget _buildValidationItem(ThemeData theme, String text, bool isSuccess, {bool isWarning = false}) {
    final color = isSuccess ? Colors.green : (isWarning ? Colors.orange : Colors.red);
    final icon = isSuccess ? LucideIcons.checkCircle2 : (isWarning ? LucideIcons.alertTriangle : LucideIcons.xCircle);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: color.withValues(alpha: 1.0, red: color.r * 0.8, green: color.g * 0.8, blue: color.b * 0.8), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewPanel(ThemeData theme, IndustryPackDetail pack) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Desktop', icon: Icon(LucideIcons.monitor)),
              ButtonSegment(value: 'Tablet', icon: Icon(LucideIcons.tablet)),
              ButtonSegment(value: 'Mobile', icon: Icon(LucideIcons.smartphone)),
            ],
            selected: {_previewMode},
            onSelectionChanged: (val) => setState(() => _previewMode = val.first),
            showSelectedIcon: false,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor, width: 4),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _previewMode == 'Desktop' ? LucideIcons.monitor : (_previewMode == 'Tablet' ? LucideIcons.tablet : LucideIcons.smartphone),
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text('$_previewMode Preview\n(Mock Visualization)', textAlign: TextAlign.center, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentTabContent(ThemeData theme, IndustryPackDetail pack) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildGeneralTab(theme, pack);
      case 1:
        return _buildModulesTab(theme, pack);
      case 2:
        return _buildNavigationTab(theme, pack);
      case 3:
        return _buildDependenciesTab(theme, pack);
      case 4:
        return _buildIntegrationsTab(theme, pack);
      case 5:
        return _buildGenericConfigTab(theme, 'Security Policies', [
          _buildSwitchTile(theme, 'Tenant Isolation', 'Strict database schema isolation', true),
          _buildSwitchTile(theme, 'Audit Logging', 'Log every read/write action', true),
          _buildSwitchTile(theme, 'End-to-End Encryption', 'Encrypt data at rest', false),
        ]);
      case 6:
        return _buildLicensingTab(theme, pack);
      case 7:
        return _buildGenericConfigTab(theme, 'Feature Flags', [
          _buildSwitchTile(theme, 'AI Assistant', 'Enable Copilot', true),
          _buildSwitchTile(theme, 'Advanced Reports', 'Access to PowerBI embedded', true),
          _buildSwitchTile(theme, 'Workflow Engine', 'Custom automated flows', true),
          _buildSwitchTile(theme, 'Document Versioning', 'Keep history of file uploads', false),
          _buildSwitchTile(theme, 'Experimental Features', 'Bleeding edge updates', false),
        ]);
      case 8:
        return _buildSystemConfigTab(theme, pack);
      default:
        return const SizedBox();
    }
  }

  Widget _buildGeneralTab(ThemeData theme, IndustryPackDetail pack) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(theme, 'Pack Identity', [
          Row(
            children: [
               Expanded(child: _buildTextField(theme, 'Pack Name', defaultValue: pack.name)),
               const SizedBox(width: 16),
               Expanded(child: _buildTextField(theme, 'Display Name', defaultValue: '${pack.name} UI')),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(theme, 'Description', defaultValue: 'A comprehensive configuration pack for the ${pack.industry} industry.', maxLines: 3),
          const SizedBox(height: 16),
          Row(
            children: [
               Expanded(child: _buildTextField(theme, 'Industry Type', defaultValue: pack.industry)),
               const SizedBox(width: 16),
               Expanded(child: _buildTextField(theme, 'Version', defaultValue: pack.version)),
               const SizedBox(width: 16),
               Expanded(child: _buildTextField(theme, 'Package ID', defaultValue: pack.id)),
            ],
          ),
        ]),
        const SizedBox(height: 24),
        _buildSectionCard(theme, 'Environment Behavior', [
          _buildDropdownField(theme, 'Default Landing Page', ['Dashboard', 'Workspace', 'CRM'], 'Dashboard'),
          const SizedBox(height: 16),
          _buildSwitchTile(theme, 'Enabled', 'Is this pack active?', true),
          const Divider(),
          _buildSwitchTile(theme, 'Read Only', 'Disable all write actions', false),
          const Divider(),
          _buildSwitchTile(theme, 'Maintenance Mode', 'Show maintenance screen to non-admins', false),
        ]),
      ],
    );
  }

  Widget _buildModulesTab(ThemeData theme, IndustryPackDetail pack) {
    final modules = [
      {'name': 'Dashboard', 'req': false, 'enabled': true},
      {'name': 'CRM', 'req': false, 'enabled': true},
      {'name': 'Customers', 'req': false, 'enabled': true},
      {'name': 'Product Catalog', 'req': false, 'enabled': true},
      {'name': 'Quotations', 'req': false, 'enabled': true},
      {'name': 'Sales Orders', 'req': true, 'enabled': true},
      {'name': 'BOM', 'req': true, 'enabled': false},
      {'name': 'Production', 'req': true, 'enabled': true},
      {'name': 'Inventory', 'req': true, 'enabled': true},
      {'name': 'Delivery', 'req': false, 'enabled': true},
      {'name': 'Finance', 'req': true, 'enabled': true},
      {'name': 'Reports', 'req': false, 'enabled': true},
      {'name': 'AI', 'req': true, 'enabled': false},
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: modules.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final mod = modules[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            title: Text(mod['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text((mod['req'] as bool) ? 'Requires License' : 'Standard Module'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index == 0) Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: pack.themeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text('Default', style: TextStyle(color: pack.themeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Switch(value: mod['enabled'] as bool, onChanged: (v){}, activeThumbColor: pack.themeColor),
                IconButton(icon: const Icon(LucideIcons.moreVertical), onPressed: (){}),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationTab(ThemeData theme, IndustryPackDetail pack) {
    return Column(
      children: [
        _buildSectionCard(theme, 'Layout', [
          _buildDropdownField(theme, 'Sidebar Position', ['Left', 'Right', 'Hidden'], 'Left'),
          const SizedBox(height: 16),
          _buildSwitchTile(theme, 'Default Expanded', 'Keep sidebar open by default', true),
          const Divider(),
          _buildSwitchTile(theme, 'Show Icons', 'Show icons next to module names', true),
          const Divider(),
          _buildSwitchTile(theme, 'Show Badges', 'Show notification counts', true),
        ]),
        const SizedBox(height: 24),
        _buildSectionCard(theme, 'Organization', [
           _buildSwitchTile(theme, 'Group Modules', 'Categorize into folders', true),
           const Divider(),
           _buildSwitchTile(theme, 'Favorite Modules', 'Allow users to pin modules', true),
        ]),
      ],
    );
  }

  Widget _buildDependenciesTab(ThemeData theme, IndustryPackDetail pack) {
    return _buildSectionCard(theme, 'Dependency Graph', [
      Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
             Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 _buildDepCard(theme, 'CRM', Colors.blue),
                 const Icon(LucideIcons.arrowDown),
                 _buildDepCard(theme, 'Quotation', Colors.blue),
                 const Icon(LucideIcons.arrowDown),
                 _buildDepCard(theme, 'Sales Orders', Colors.orange),
                 const Icon(LucideIcons.arrowDown),
                 _buildDepCard(theme, 'Production', Colors.orange),
                 const Icon(LucideIcons.arrowDown),
                 _buildDepCard(theme, 'Inventory', Colors.green),
                 const Icon(LucideIcons.arrowDown),
                 _buildDepCard(theme, 'Delivery', Colors.green),
                 const Icon(LucideIcons.arrowDown),
                 _buildDepCard(theme, 'Finance', Colors.purple),
               ],
             )
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(onPressed: (){}, icon: const Icon(LucideIcons.refreshCw, size: 16), label: const Text('Resolve Dependencies')),
          const SizedBox(width: 8),
          FilledButton.icon(onPressed: (){}, icon: const Icon(LucideIcons.checkCircle2, size: 16), label: const Text('Validate Tree'), style: FilledButton.styleFrom(backgroundColor: Colors.green)),
        ],
      )
    ]);
  }

  Widget _buildDepCard(ThemeData theme, String title, Color c) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        border: Border.all(color: c),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: c)),
    );
  }

  Widget _buildIntegrationsTab(ThemeData theme, IndustryPackDetail pack) {
     final integrations = ['ERP API', 'Webhook', 'Email', 'SMS', 'WhatsApp', 'Document Engine', 'Workflow Engine', 'Approval Engine', 'AI'];
     return Column(
       children: integrations.map((i) => Padding(
         padding: const EdgeInsets.only(bottom: 12),
         child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: theme.colorScheme.surface,
             borderRadius: BorderRadius.circular(12),
             border: Border.all(color: theme.dividerColor),
           ),
           child: Row(
             children: [
               Icon(LucideIcons.link2, color: theme.colorScheme.onSurfaceVariant),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(i, style: const TextStyle(fontWeight: FontWeight.bold)),
                     const SizedBox(height: 4),
                     Text('Connected via standard connector', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                   ],
                 )
               ),
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                 decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                 child: const Text('Connected', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
               ),
               const SizedBox(width: 16),
               OutlinedButton(onPressed: (){}, child: const Text('Test Connection')),
             ],
           ),
         ),
       )).toList(),
     );
  }

  Widget _buildLicensingTab(ThemeData theme, IndustryPackDetail pack) {
    return _buildSectionCard(theme, 'License Details', [
      _buildDropdownField(theme, 'License Type', ['Community', 'Professional', 'Enterprise'], 'Enterprise'),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: _buildTextField(theme, 'Maximum Users', defaultValue: 'Unlimited')),
          const SizedBox(width: 16),
          Expanded(child: _buildTextField(theme, 'Maximum Organizations', defaultValue: '100')),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: _buildTextField(theme, 'Storage Allocation', defaultValue: '5 TB')),
          const SizedBox(width: 16),
          Expanded(child: _buildTextField(theme, 'Expiry Date', defaultValue: '2029-12-31')),
        ],
      ),
    ]);
  }

  Widget _buildSystemConfigTab(ThemeData theme, IndustryPackDetail pack) {
    return _buildSectionCard(theme, 'System Preferences', [
      _buildDropdownField(theme, 'Theme Selection', ['System Default', 'Material 3', 'High Contrast'], 'Material 3'),
      const SizedBox(height: 16),
      _buildDropdownField(theme, 'Icon Set', ['Lucide', 'Material', 'Cupertino'], 'Lucide'),
      const SizedBox(height: 16),
      _buildDropdownField(theme, 'Default Time Zone', ['UTC', 'America/New_York', 'Asia/Kolkata'], 'UTC'),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(child: _buildDropdownField(theme, 'Language', ['English (US)', 'Spanish', 'French'], 'English (US)')),
          const SizedBox(width: 16),
          Expanded(child: _buildDropdownField(theme, 'Currency', ['USD (\$)', 'EUR (€)', 'INR (₹)'], 'USD (\$)')),
        ],
      )
    ]);
  }

  Widget _buildGenericConfigTab(ThemeData theme, String title, List<Widget> children) {
    return _buildSectionCard(theme, title, children);
  }

  Widget _buildSectionCard(ThemeData theme, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String label, {String? defaultValue, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: defaultValue,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(ThemeData theme, String label, List<String> options, String selected) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selected,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: (val) {},
        ),
      ],
    );
  }

  Widget _buildSwitchTile(ThemeData theme, String title, String subtitle, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          value: initialValue,
          onChanged: (val) => setState(() => initialValue = val),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          contentPadding: EdgeInsets.zero,
        );
      }
    );
  }
}
