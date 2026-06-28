import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/presentation/widgets/premium_dashboard_widgets.dart';
import 'providers/user_profile_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userProfileProvider.notifier).init(widget.userId);
    });
  }

  void _saveChanges() async {
    await ref.read(userProfileProvider.notifier).saveChanges();
    if (mounted) {
      final error = ref.read(userProfileProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved successfully.'), backgroundColor: Colors.green));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(userProfileProvider);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: () => context.go('/platform/users/${widget.userId}'),
          ),
          title: const Text('User Profile & Preferences'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: FilledButton.icon(
                onPressed: state.isSaving ? null : _saveChanges,
                icon: state.isSaving 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(LucideIcons.save, size: 18),
                label: Text(state.isSaving ? 'Saving...' : 'Save Changes'),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: !isDesktop,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            tabs: const [
              Tab(icon: Icon(LucideIcons.user), text: 'Personal Info'),
              Tab(icon: Icon(LucideIcons.settings), text: 'Preferences'),
              Tab(icon: Icon(LucideIcons.palette), text: 'Appearance'),
              Tab(icon: Icon(LucideIcons.bell), text: 'Notifications'),
              Tab(icon: Icon(LucideIcons.shield), text: 'Security'),
            ],
          ),
        ),
        body: state.isLoading || state.profile == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _PersonalInfoTab(),
                  _PreferencesTab(),
                  _AppearanceTab(),
                  _NotificationsTab(),
                  _SecurityTab(),
                ],
              ),
      ),
    );
  }
}

// ── Personal Info Tab ────────────────────────────────────────────────────────
class _PersonalInfoTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    final profile = state.profile!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Personal Information', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Update your basic profile details and avatars.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(profile.firstName[0] + profile.lastName[0], style: TextStyle(fontSize: 24, color: theme.colorScheme.primary)),
                    ),
                    const SizedBox(width: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock: Opening file picker for Avatar...')));
                      },
                      icon: const Icon(LucideIcons.upload, size: 16),
                      label: const Text('Change Avatar'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: profile.firstName,
                        decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                        onChanged: (val) => ref.read(userProfileProvider.notifier).updatePersonalInfo(firstName: val),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: profile.lastName,
                        decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                        onChanged: (val) => ref.read(userProfileProvider.notifier).updatePersonalInfo(lastName: val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: profile.email,
                  decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
                  onChanged: (val) => ref.read(userProfileProvider.notifier).updatePersonalInfo(email: val),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: profile.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                  onChanged: (val) => ref.read(userProfileProvider.notifier).updatePersonalInfo(phone: val),
                ),
                const SizedBox(height: 32),
                Text('Digital Signature', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Upload your digital signature for approval workflows.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 16),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: Border.all(color: theme.colorScheme.outlineVariant, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock: Opening file picker for Signature...')));
                      },
                      icon: const Icon(LucideIcons.imagePlus),
                      label: const Text('Upload Signature Image'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade();
  }
}

// ── Preferences Tab ──────────────────────────────────────────────────────────
class _PreferencesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    final profile = state.profile!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('System Preferences', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Customize how the ERP platform behaves for your account.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                
                DropdownButtonFormField<String>(
                  value: profile.language,
                  decoration: const InputDecoration(labelText: 'Language', border: OutlineInputBorder()),
                  items: ['English', 'Spanish', 'French', 'German'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) ref.read(userProfileProvider.notifier).updatePreferences(language: val);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: profile.timeZone,
                  decoration: const InputDecoration(labelText: 'Time Zone', border: OutlineInputBorder()),
                  items: [
                    'UTC-8 (Pacific Time)',
                    'UTC-5 (Eastern Time)',
                    'UTC+0 (GMT)',
                    'UTC+1 (Central European Time)',
                    'UTC+5:30 (India Standard Time)'
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) ref.read(userProfileProvider.notifier).updatePreferences(timeZone: val);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: profile.dateFormat,
                  decoration: const InputDecoration(labelText: 'Date Format', border: OutlineInputBorder()),
                  items: ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) ref.read(userProfileProvider.notifier).updatePreferences(dateFormat: val);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: profile.currency,
                  decoration: const InputDecoration(labelText: 'Preferred Currency', border: OutlineInputBorder()),
                  items: ['USD (\$)', 'EUR (€)', 'GBP (£)', 'INR (₹)'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val != null) ref.read(userProfileProvider.notifier).updatePreferences(currency: val);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade();
  }
}

// ── Appearance Tab ───────────────────────────────────────────────────────────
class _AppearanceTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    final profile = state.profile!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Appearance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Customize the visual look and layout of the platform.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                
                Text('Theme Mode', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Light', icon: Icon(LucideIcons.sun), label: Text('Light')),
                    ButtonSegment(value: 'Dark', icon: Icon(LucideIcons.moon), label: Text('Dark')),
                    ButtonSegment(value: 'System', icon: Icon(LucideIcons.monitor), label: Text('System')),
                  ],
                  selected: {profile.themeMode},
                  onSelectionChanged: (set) => ref.read(userProfileProvider.notifier).updateAppearance(themeMode: set.first),
                ),
                const SizedBox(height: 32),

                Text('Sidebar Layout', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Expanded', icon: Icon(LucideIcons.sidebar), label: Text('Expanded')),
                    ButtonSegment(value: 'Collapsed', icon: Icon(LucideIcons.minimize), label: Text('Collapsed')),
                  ],
                  selected: {profile.sidebarMode},
                  onSelectionChanged: (set) => ref.read(userProfileProvider.notifier).updateAppearance(sidebarMode: set.first),
                ),
                const SizedBox(height: 32),

                Text('Information Density', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Standard', icon: Icon(LucideIcons.layoutList), label: Text('Standard')),
                    ButtonSegment(value: 'Compact', icon: Icon(LucideIcons.alignJustify), label: Text('Compact (Tables)')),
                  ],
                  selected: {profile.density},
                  onSelectionChanged: (set) => ref.read(userProfileProvider.notifier).updateAppearance(density: set.first),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade();
  }
}

// ── Notifications Tab ────────────────────────────────────────────────────────
class _NotificationsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    final profile = state.profile!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notification Channels', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Select how you want to be notified of platform events.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                
                SwitchListTile(
                  title: const Text('Email Notifications'),
                  subtitle: const Text('Receive summaries and alerts via email.'),
                  secondary: const Icon(LucideIcons.mail),
                  value: profile.emailEnabled,
                  onChanged: (val) => ref.read(userProfileProvider.notifier).updateNotifications(emailEnabled: val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive alerts directly in your browser or mobile app.'),
                  secondary: const Icon(LucideIcons.bellRing),
                  value: profile.pushEnabled,
                  onChanged: (val) => ref.read(userProfileProvider.notifier).updateNotifications(pushEnabled: val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('SMS Notifications'),
                  subtitle: const Text('Receive critical alerts via text message.'),
                  secondary: const Icon(LucideIcons.smartphone),
                  value: profile.smsEnabled,
                  onChanged: (val) => ref.read(userProfileProvider.notifier).updateNotifications(smsEnabled: val),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('WhatsApp Notifications'),
                  subtitle: const Text('Receive updates on your registered WhatsApp number.'),
                  secondary: const Icon(LucideIcons.messageCircle),
                  value: profile.whatsappEnabled,
                  onChanged: (val) => ref.read(userProfileProvider.notifier).updateNotifications(whatsappEnabled: val),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade();
  }
}

// ── Security Tab ─────────────────────────────────────────────────────────────
class _SecurityTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userProfileProvider);
    final profile = state.profile!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Authentication & Security', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Manage your password and Multi-Factor Authentication settings.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 32),
                    
                    SwitchListTile(
                      title: const Text('Multi-Factor Authentication (MFA)'),
                      subtitle: const Text('Require a secondary code when logging in.'),
                      secondary: Icon(LucideIcons.shieldCheck, color: profile.mfaEnabled ? Colors.green : Colors.grey),
                      value: profile.mfaEnabled,
                      onChanged: (val) => ref.read(userProfileProvider.notifier).updateSecurity(mfaEnabled: val),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () {
                         showDialog(context: context, builder: (ctx) => AlertDialog(
                           title: const Text('Change Password'),
                           content: const Text('A password reset link would be sent to your email or an inline form would appear here.'),
                           actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
                         ));
                      },
                      icon: const Icon(LucideIcons.key),
                      label: const Text('Change Password'),
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: profile.sessionTimeout,
                      decoration: const InputDecoration(labelText: 'Idle Session Timeout', border: OutlineInputBorder()),
                      items: ['15 minutes', '30 minutes', '1 hour', '4 hours', '8 hours'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                      onChanged: (val) {
                        if (val != null) ref.read(userProfileProvider.notifier).updateSecurity(sessionTimeout: val);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Trusted Devices & Active Sessions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Manage devices that are currently logged into your account.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    ...profile.trustedDevices.map((device) => ListTile(
                      leading: const Icon(LucideIcons.laptop),
                      title: Text(device),
                      subtitle: const Text('Active now'),
                      trailing: TextButton(
                        onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mock: Revoked session for $device')));
                        },
                        child: const Text('Revoke', style: TextStyle(color: Colors.red)),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fade();
  }
}
