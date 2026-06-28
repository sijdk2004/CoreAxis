import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';

class TenantSettingsState {
  // General
  final String name;
  final String code;
  final String timezone;
  final String language;
  final String currency;

  // Branding
  final String logoUrl;
  final String primaryColor;
  final String secondaryColor;
  final String faviconUrl;
  final String loginBackgroundUrl;

  // Localization
  final String country;
  final String dateFormat;
  final String numberFormat;
  final String fiscalYearStart;

  // Security
  final String passwordPolicy;
  final int sessionTimeoutMinutes;
  final bool mfaEnabled;
  final String ipRestrictions;

  // Notifications
  final bool emailNotifications;
  final bool smsNotifications;
  final bool whatsappNotifications;
  final bool pushNotifications;

  // Feature Flags
  final bool workflowEngineEnabled;
  final bool aiAssistantEnabled;
  final bool documentsEnabled;
  final bool reportsEnabled;
  final bool auditLogsEnabled;
  final bool approvalEngineEnabled;

  TenantSettingsState({
    this.name = '',
    this.code = '',
    this.timezone = 'UTC',
    this.language = 'English',
    this.currency = 'USD',
    this.logoUrl = 'https://ui-avatars.com/api/?name=Stellar&background=random',
    this.primaryColor = '#1976D2',
    this.secondaryColor = '#FFC107',
    this.faviconUrl = 'https://ui-avatars.com/api/?name=Stellar&background=random',
    this.loginBackgroundUrl = '',
    this.country = 'United States',
    this.dateFormat = 'MM/DD/YYYY',
    this.numberFormat = '1,234.56',
    this.fiscalYearStart = 'January',
    this.passwordPolicy = 'Strong (8+ chars, upper, lower, numbers, symbols)',
    this.sessionTimeoutMinutes = 60,
    this.mfaEnabled = false,
    this.ipRestrictions = '',
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.whatsappNotifications = false,
    this.pushNotifications = false,
    this.workflowEngineEnabled = true,
    this.aiAssistantEnabled = false,
    this.documentsEnabled = true,
    this.reportsEnabled = true,
    this.auditLogsEnabled = true,
    this.approvalEngineEnabled = true,
  });

  TenantSettingsState copyWith({
    String? name,
    String? code,
    String? timezone,
    String? language,
    String? currency,
    String? logoUrl,
    String? primaryColor,
    String? secondaryColor,
    String? faviconUrl,
    String? loginBackgroundUrl,
    String? country,
    String? dateFormat,
    String? numberFormat,
    String? fiscalYearStart,
    String? passwordPolicy,
    int? sessionTimeoutMinutes,
    bool? mfaEnabled,
    String? ipRestrictions,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? whatsappNotifications,
    bool? pushNotifications,
    bool? workflowEngineEnabled,
    bool? aiAssistantEnabled,
    bool? documentsEnabled,
    bool? reportsEnabled,
    bool? auditLogsEnabled,
    bool? approvalEngineEnabled,
  }) {
    return TenantSettingsState(
      name: name ?? this.name,
      code: code ?? this.code,
      timezone: timezone ?? this.timezone,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      loginBackgroundUrl: loginBackgroundUrl ?? this.loginBackgroundUrl,
      country: country ?? this.country,
      dateFormat: dateFormat ?? this.dateFormat,
      numberFormat: numberFormat ?? this.numberFormat,
      fiscalYearStart: fiscalYearStart ?? this.fiscalYearStart,
      passwordPolicy: passwordPolicy ?? this.passwordPolicy,
      sessionTimeoutMinutes: sessionTimeoutMinutes ?? this.sessionTimeoutMinutes,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
      ipRestrictions: ipRestrictions ?? this.ipRestrictions,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      whatsappNotifications: whatsappNotifications ?? this.whatsappNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      workflowEngineEnabled: workflowEngineEnabled ?? this.workflowEngineEnabled,
      aiAssistantEnabled: aiAssistantEnabled ?? this.aiAssistantEnabled,
      documentsEnabled: documentsEnabled ?? this.documentsEnabled,
      reportsEnabled: reportsEnabled ?? this.reportsEnabled,
      auditLogsEnabled: auditLogsEnabled ?? this.auditLogsEnabled,
      approvalEngineEnabled: approvalEngineEnabled ?? this.approvalEngineEnabled,
    );
  }
}

class TenantSettingsScreen extends ConsumerStatefulWidget {
  final String tenantId;
  const TenantSettingsScreen({super.key, required this.tenantId});

  @override
  ConsumerState<TenantSettingsScreen> createState() => _TenantSettingsScreenState();
}

class _TenantSettingsScreenState extends ConsumerState<TenantSettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSaving = false;
  bool _isLoading = true;
  late TenantSettingsState _currentState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _currentState = TenantSettingsState(
          name: 'Stellar Tech (Tenant ${widget.tenantId})',
          code: widget.tenantId,
        );
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    
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

  void _updateState(TenantSettingsState newState) {
    setState(() {
      _currentState = newState;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Tenant Settings'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/platform/tenants/${widget.tenantId}');
            }
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0, top: 8, bottom: 8),
            child: FilledButton.icon(
              icon: _isSaving 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(LucideIcons.save, size: 18),
              label: const Text('Save Changes'),
              onPressed: _isSaving || _isLoading ? null : _handleSave,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Branding'),
            Tab(text: 'Localization'),
            Tab(text: 'Security'),
            Tab(text: 'Notifications'),
            Tab(text: 'Feature Flags'),
          ],
        ),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : TabBarView(
            controller: _tabController,
            children: [
              _buildGeneralTab(context, _currentState),
              _buildBrandingTab(context, _currentState),
              _buildLocalizationTab(context, _currentState),
              _buildSecurityTab(context, _currentState),
              _buildNotificationsTab(context, _currentState),
              _buildFeatureFlagsTab(context, _currentState),
            ],
          ),
    );
  }

  Widget _buildSectionHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildGeneralTab(BuildContext context, TenantSettingsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('General Information', 'Basic configuration for this tenant.'),
                _buildTextField('Tenant Name', state.name, (val) => _updateState(state.copyWith(name: val))),
                const SizedBox(height: 24),
                _buildTextField('Tenant Code', state.code, (val) => _updateState(state.copyWith(code: val))),
                const SizedBox(height: 24),
                _buildDropdown('Timezone', state.timezone, ['UTC', 'America/New_York', 'Europe/London', 'Asia/Kolkata'], (val) => _updateState(state.copyWith(timezone: val))),
                const SizedBox(height: 24),
                _buildDropdown('Language', state.language, ['English', 'Spanish', 'French', 'German'], (val) => _updateState(state.copyWith(language: val))),
                const SizedBox(height: 24),
                _buildDropdown('Currency', state.currency, ['USD', 'EUR', 'GBP', 'INR'], (val) => _updateState(state.copyWith(currency: val))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingTab(BuildContext context, TenantSettingsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Branding & Theming', 'Customize the look and feel of the tenant application.'),
                _buildTextField('Logo URL', state.logoUrl, (val) => _updateState(state.copyWith(logoUrl: val))),
                const SizedBox(height: 24),
                _buildTextField('Primary Color (Hex)', state.primaryColor, (val) => _updateState(state.copyWith(primaryColor: val))),
                const SizedBox(height: 24),
                _buildTextField('Secondary Color (Hex)', state.secondaryColor, (val) => _updateState(state.copyWith(secondaryColor: val))),
                const SizedBox(height: 24),
                _buildTextField('Favicon URL', state.faviconUrl, (val) => _updateState(state.copyWith(faviconUrl: val))),
                const SizedBox(height: 24),
                _buildTextField('Login Background Image URL', state.loginBackgroundUrl, (val) => _updateState(state.copyWith(loginBackgroundUrl: val))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalizationTab(BuildContext context, TenantSettingsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Localization', 'Configure regional settings for users in this tenant.'),
                _buildDropdown('Country', state.country, ['United States', 'United Kingdom', 'Canada', 'India'], (val) => _updateState(state.copyWith(country: val))),
                const SizedBox(height: 24),
                _buildDropdown('Date Format', state.dateFormat, ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'], (val) => _updateState(state.copyWith(dateFormat: val))),
                const SizedBox(height: 24),
                _buildDropdown('Number Format', state.numberFormat, ['1,234.56', '1.234,56', '1 234,56'], (val) => _updateState(state.copyWith(numberFormat: val))),
                const SizedBox(height: 24),
                _buildDropdown('Fiscal Year Start', state.fiscalYearStart, ['January', 'April', 'July', 'October'], (val) => _updateState(state.copyWith(fiscalYearStart: val))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityTab(BuildContext context, TenantSettingsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Security Policies', 'Manage authentication and access policies.'),
                _buildDropdown('Password Policy', state.passwordPolicy, [
                  'Standard (8+ chars)',
                  'Strong (8+ chars, upper, lower, numbers, symbols)',
                  'Very Strong (12+ chars, complex)'
                ], (val) => _updateState(state.copyWith(passwordPolicy: val))),
                const SizedBox(height: 24),
                _buildDropdown('Session Timeout (Minutes)', state.sessionTimeoutMinutes.toString(), ['15', '30', '60', '120'], (val) => _updateState(state.copyWith(sessionTimeoutMinutes: int.parse(val!)))),
                const SizedBox(height: 24),
                _buildSwitch('Require Multi-Factor Authentication (MFA)', state.mfaEnabled, (val) => _updateState(state.copyWith(mfaEnabled: val))),
                const SizedBox(height: 24),
                _buildTextField('IP Restrictions (Comma separated IPs)', state.ipRestrictions, (val) => _updateState(state.copyWith(ipRestrictions: val))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsTab(BuildContext context, TenantSettingsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Notification Channels', 'Enable or disable communication channels.'),
                _buildSwitch('Email Notifications', state.emailNotifications, (val) => _updateState(state.copyWith(emailNotifications: val))),
                const SizedBox(height: 16),
                _buildSwitch('SMS Notifications', state.smsNotifications, (val) => _updateState(state.copyWith(smsNotifications: val))),
                const SizedBox(height: 16),
                _buildSwitch('WhatsApp Notifications', state.whatsappNotifications, (val) => _updateState(state.copyWith(whatsappNotifications: val))),
                const SizedBox(height: 16),
                _buildSwitch('Push Notifications', state.pushNotifications, (val) => _updateState(state.copyWith(pushNotifications: val))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureFlagsTab(BuildContext context, TenantSettingsState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Platform Modules', 'Enable or disable specific features for this tenant.'),
                _buildSwitch('Workflow Engine', state.workflowEngineEnabled, (val) => _updateState(state.copyWith(workflowEngineEnabled: val))),
                const SizedBox(height: 16),
                _buildSwitch('AI Assistant', state.aiAssistantEnabled, (val) => _updateState(state.copyWith(aiAssistantEnabled: val))),
                const SizedBox(height: 16),
                _buildSwitch('Documents Management', state.documentsEnabled, (val) => _updateState(state.copyWith(documentsEnabled: val))),
                const SizedBox(height: 16),
                _buildSwitch('Advanced Reports', state.reportsEnabled, (val) => _updateState(state.copyWith(reportsEnabled: val))),
                const SizedBox(height: 16),
                _buildSwitch('Audit Logs', state.auditLogsEnabled, (val) => _updateState(state.copyWith(auditLogsEnabled: val))),
                const SizedBox(height: 16),
                _buildSwitch('Approval Engine', state.approvalEngineEnabled, (val) => _updateState(state.copyWith(approvalEngineEnabled: val))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSwitch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
