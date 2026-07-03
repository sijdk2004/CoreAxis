import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

// --- STATE ---
enum PreviewMode { desktop, tablet, mobile }
enum SidebarStyle { solid, transparent, light, dark }

class IndustryBrandingState {
  final String appName;
  final Color primaryColor;
  final Color secondaryColor;
  final String? logoPath;
  final String? faviconPath;
  final String? loginBackgroundPath;
  final String? dashboardBannerPath;
  final SidebarStyle sidebarStyle;
  final PreviewMode previewMode;
  final bool isSaving;

  const IndustryBrandingState({
    this.appName = 'FurniFlow',
    this.primaryColor = const Color(0xFF2563EB),
    this.secondaryColor = const Color(0xFF475569),
    this.logoPath,
    this.faviconPath,
    this.loginBackgroundPath,
    this.dashboardBannerPath,
    this.sidebarStyle = SidebarStyle.solid,
    this.previewMode = PreviewMode.desktop,
    this.isSaving = false,
  });

  IndustryBrandingState copyWith({
    String? appName,
    Color? primaryColor,
    Color? secondaryColor,
    String? logoPath,
    String? faviconPath,
    String? loginBackgroundPath,
    String? dashboardBannerPath,
    SidebarStyle? sidebarStyle,
    PreviewMode? previewMode,
    bool? isSaving,
  }) {
    return IndustryBrandingState(
      appName: appName ?? this.appName,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logoPath: logoPath ?? this.logoPath,
      faviconPath: faviconPath ?? this.faviconPath,
      loginBackgroundPath: loginBackgroundPath ?? this.loginBackgroundPath,
      dashboardBannerPath: dashboardBannerPath ?? this.dashboardBannerPath,
      sidebarStyle: sidebarStyle ?? this.sidebarStyle,
      previewMode: previewMode ?? this.previewMode,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class IndustryBrandingNotifier extends Notifier<IndustryBrandingState> {
  @override
  IndustryBrandingState build() => const IndustryBrandingState();

  void updateAppName(String name) => state = state.copyWith(appName: name);
  void updatePrimaryColor(Color color) => state = state.copyWith(primaryColor: color);
  void updateSecondaryColor(Color color) => state = state.copyWith(secondaryColor: color);
  void updateSidebarStyle(SidebarStyle style) => state = state.copyWith(sidebarStyle: style);
  void setPreviewMode(PreviewMode mode) => state = state.copyWith(previewMode: mode);
  
  // Mock file uploads
  void uploadLogo() => state = state.copyWith(logoPath: 'mock_logo.png');
  void uploadFavicon() => state = state.copyWith(faviconPath: 'mock_favicon.ico');
  void uploadLoginBackground() => state = state.copyWith(loginBackgroundPath: 'mock_bg.jpg');
  void uploadDashboardBanner() => state = state.copyWith(dashboardBannerPath: 'mock_banner.jpg');

  Future<void> saveSettings(BuildContext context) async {
    state = state.copyWith(isSaving: true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate network request
    state = state.copyWith(isSaving: false);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(LucideIcons.checkCircle2, color: Colors.white),
              SizedBox(width: 12),
              Text('Branding settings saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

final industryBrandingProvider = NotifierProvider<IndustryBrandingNotifier, IndustryBrandingState>(IndustryBrandingNotifier.new);

// --- SCREEN ---
class IndustryBrandingScreen extends ConsumerWidget {
  final String packId;
  const IndustryBrandingScreen({super.key, required this.packId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(industryBrandingProvider);
    final notifier = ref.read(industryBrandingProvider.notifier);
    final theme = Theme.of(context);
    final isDesktop = ResponsiveBreakpoints.of(context).largerThan(TABLET);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Industry Branding'),
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        actions: [
          FilledButton.icon(
            onPressed: state.isSaving ? null : () => notifier.saveSettings(context),
            icon: state.isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(LucideIcons.save, size: 16),
            label: Text(state.isSaving ? 'Saving...' : 'Save Settings'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isDesktop 
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Column: Settings
                SizedBox(
                  width: 400,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildSettingsForm(context, ref, state, notifier, theme),
                  ),
                ),
                const VerticalDivider(width: 1),
                // Right Column: Preview
                Expanded(
                  child: Column(
                    children: [
                      _buildPreviewToolbar(context, state, notifier, theme),
                      const Divider(height: 1),
                      Expanded(
                        child: Container(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          child: Center(
                            child: _buildLivePreview(context, state, theme),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPreviewToolbar(context, state, notifier, theme),
                  const SizedBox(height: 16),
                  Container(
                    height: 500,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Center(child: _buildLivePreview(context, state, theme)),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildSettingsForm(context, ref, state, notifier, theme),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsForm(BuildContext context, WidgetRef ref, IndustryBrandingState state, IndustryBrandingNotifier notifier, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Brand Identity', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: state.appName,
          decoration: const InputDecoration(
            labelText: 'App Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(LucideIcons.type),
          ),
          onChanged: notifier.updateAppName,
        ),
        const SizedBox(height: 24),
        
        Text('Colors', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildColorPicker(theme, 'Primary Color', state.primaryColor, (c) => notifier.updatePrimaryColor(c)),
        const SizedBox(height: 16),
        _buildColorPicker(theme, 'Secondary Color', state.secondaryColor, (c) => notifier.updateSecondaryColor(c)),
        const SizedBox(height: 24),

        Text('Assets', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildAssetUploader(theme, 'Logo', state.logoPath, notifier.uploadLogo),
        const SizedBox(height: 12),
        _buildAssetUploader(theme, 'Favicon', state.faviconPath, notifier.uploadFavicon),
        const SizedBox(height: 12),
        _buildAssetUploader(theme, 'Login Background', state.loginBackgroundPath, notifier.uploadLoginBackground),
        const SizedBox(height: 12),
        _buildAssetUploader(theme, 'Dashboard Banner', state.dashboardBannerPath, notifier.uploadDashboardBanner),
        const SizedBox(height: 24),

        Text('Layout & Styling', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        DropdownButtonFormField<SidebarStyle>(
          initialValue: state.sidebarStyle,
          decoration: const InputDecoration(
            labelText: 'Sidebar Style',
            border: OutlineInputBorder(),
          ),
          items: SidebarStyle.values.map((style) {
            return DropdownMenuItem(
              value: style,
              child: Text(style.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) notifier.updateSidebarStyle(val);
          },
        ),
      ],
    );
  }

  Widget _buildColorPicker(ThemeData theme, String label, Color currentColor, Function(Color) onSelect) {
    // Mock color palette options
    final colors = [
      const Color(0xFF2563EB), // Blue
      const Color(0xFF16A34A), // Green
      const Color(0xFFDC2626), // Red
      const Color(0xFF9333EA), // Purple
      const Color(0xFFEA580C), // Orange
      const Color(0xFF475569), // Slate
      const Color(0xFF000000), // Black
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            final isSelected = color == currentColor;
            return InkWell(
              onTap: () => onSelect(color),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: theme.colorScheme.onSurface, width: 2) : null,
                ),
                child: isSelected ? const Icon(LucideIcons.check, color: Colors.white, size: 16) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAssetUploader(ThemeData theme, String label, String? currentPath, VoidCallback onUpload) {
    final hasAsset = currentPath != null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(hasAsset ? LucideIcons.image : LucideIcons.uploadCloud, color: hasAsset ? Colors.green : theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(hasAsset ? currentPath : 'No file chosen', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onUpload,
            child: Text(hasAsset ? 'Replace' : 'Upload'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewToolbar(BuildContext context, IndustryBrandingState state, IndustryBrandingNotifier notifier, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      color: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SegmentedButton<PreviewMode>(
            segments: const [
              ButtonSegment(value: PreviewMode.desktop, icon: Icon(LucideIcons.monitor), label: Text('Desktop')),
              ButtonSegment(value: PreviewMode.tablet, icon: Icon(LucideIcons.tablet), label: Text('Tablet')),
              ButtonSegment(value: PreviewMode.mobile, icon: Icon(LucideIcons.smartphone), label: Text('Mobile')),
            ],
            selected: {state.previewMode},
            onSelectionChanged: (set) => notifier.setPreviewMode(set.first),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreview(BuildContext context, IndustryBrandingState state, ThemeData theme) {
    // Calculate dimensions based on mode
    double width;
    double height;
    switch (state.previewMode) {
      case PreviewMode.desktop:
        width = 800;
        height = 600;
        break;
      case PreviewMode.tablet:
        width = 500;
        height = 700;
        break;
      case PreviewMode.mobile:
        width = 320;
        height = 650;
        break;
    }

    // Colors based on Sidebar Style
    Color sidebarBgColor;
    Color sidebarTextColor;
    switch (state.sidebarStyle) {
      case SidebarStyle.solid:
        sidebarBgColor = state.primaryColor;
        sidebarTextColor = Colors.white;
        break;
      case SidebarStyle.light:
        sidebarBgColor = Colors.white;
        sidebarTextColor = Colors.black87;
        break;
      case SidebarStyle.dark:
        sidebarBgColor = const Color(0xFF1E293B);
        sidebarTextColor = Colors.white;
        break;
      case SidebarStyle.transparent:
        sidebarBgColor = state.primaryColor.withValues(alpha: 0.1);
        sidebarTextColor = theme.colorScheme.onSurface;
        break;
    }

    final isMobilePreview = state.previewMode == PreviewMode.mobile;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Topbar
          Container(
            height: 48,
            color: state.primaryColor.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                if (isMobilePreview) const Icon(LucideIcons.menu, size: 20),
                if (isMobilePreview) const SizedBox(width: 16),
                Icon(LucideIcons.layers, color: state.primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(state.appName, style: TextStyle(fontWeight: FontWeight.bold, color: state.primaryColor, fontSize: 16)),
                const Spacer(),
                const Icon(LucideIcons.bell, size: 16),
                const SizedBox(width: 16),
                CircleAvatar(radius: 12, backgroundColor: state.secondaryColor),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // Sidebar (hidden on mobile)
                if (!isMobilePreview)
                  Container(
                    width: 180,
                    color: sidebarBgColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildMockSidebarItem('Dashboard', LucideIcons.layoutDashboard, sidebarTextColor, true, state.primaryColor),
                        _buildMockSidebarItem('Modules', LucideIcons.blocks, sidebarTextColor, false, state.primaryColor),
                        _buildMockSidebarItem('Settings', LucideIcons.settings, sidebarTextColor, false, state.primaryColor),
                      ],
                    ),
                  ),
                // Main Content
                Expanded(
                  child: Container(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Banner
                        Container(
                          height: 100,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: state.dashboardBannerPath != null ? state.secondaryColor : state.primaryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            gradient: state.dashboardBannerPath != null 
                                ? LinearGradient(colors: [state.primaryColor, state.secondaryColor]) 
                                : null,
                          ),
                          child: Center(
                            child: state.dashboardBannerPath != null 
                              ? const Text('Banner Image Loaded', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                              : Icon(LucideIcons.image, size: 32, color: state.primaryColor),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildMockCard(theme, 'Total Users', '1,240', state.primaryColor)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildMockCard(theme, 'Revenue', '\$45K', state.secondaryColor)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockSidebarItem(String label, IconData icon, Color textColor, bool isSelected, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 4),
      color: isSelected ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
      child: Row(
        children: [
          Icon(icon, size: 16, color: textColor.withValues(alpha: isSelected ? 1 : 0.7)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: textColor.withValues(alpha: isSelected ? 1 : 0.7), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMockCard(ThemeData theme, String title, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: accentColor)),
        ],
      ),
    );
  }
}
