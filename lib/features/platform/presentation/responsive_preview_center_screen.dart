import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'platform_home_screen.dart';
import 'workspace_manager_screen.dart';
import 'module_catalog_screen.dart';
import 'platform_dashboard_screen.dart';
import 'system_status_screen.dart';
import 'platform_settings_screen.dart';
import 'design_system_audit_screen.dart';
import 'empty_state_library_screen.dart';
import 'skeleton_loading_library_screen.dart';
import 'feedback_center_screen.dart';
import 'toast_playground_screen.dart';
import 'keyboard_shortcut_center_screen.dart';
import 'industry_pack_launcher_screen.dart';

// Device Profiles
class DeviceProfile {
  final String name;
  final double width;
  final double height;
  final IconData icon;

  const DeviceProfile({
    required this.name,
    required this.width,
    required this.height,
    required this.icon,
  });
}

const List<DeviceProfile> mockDevices = [
  DeviceProfile(name: 'Mobile', width: 390, height: 844, icon: LucideIcons.smartphone),
  DeviceProfile(name: 'Tablet', width: 810, height: 1080, icon: LucideIcons.tablet),
  DeviceProfile(name: 'Laptop', width: 1280, height: 720, icon: LucideIcons.laptop),
  DeviceProfile(name: 'Desktop', width: 1440, height: 900, icon: LucideIcons.monitor),
  DeviceProfile(name: 'Large Display', width: 1920, height: 1080, icon: LucideIcons.monitorPlay),
];

// Screen Options
class PreviewScreenOption {
  final String name;
  final WidgetBuilder builder;

  const PreviewScreenOption({required this.name, required this.builder});
}

final List<PreviewScreenOption> previewScreens = [
  PreviewScreenOption(name: 'Dashboard', builder: (c) => const PlatformDashboardScreen()),
  PreviewScreenOption(name: 'Platform Home', builder: (c) => const PlatformHomeScreen()),
  PreviewScreenOption(name: 'Workspace Manager', builder: (c) => const WorkspaceManagerScreen()),
  PreviewScreenOption(name: 'Module Catalog', builder: (c) => const ModuleCatalogScreen()),
  PreviewScreenOption(name: 'System Status', builder: (c) => const SystemStatusScreen()),
  PreviewScreenOption(name: 'Settings Center', builder: (c) => const PlatformSettingsScreen()),
  PreviewScreenOption(name: 'Design System Audit', builder: (c) => const DesignSystemAuditScreen()),
  PreviewScreenOption(name: 'Empty States', builder: (c) => const EmptyStateLibraryScreen()),
  PreviewScreenOption(name: 'Skeleton Loading', builder: (c) => const SkeletonLoadingLibraryScreen()),
  PreviewScreenOption(name: 'Feedback Center', builder: (c) => const FeedbackCenterScreen()),
  PreviewScreenOption(name: 'Toast Playground', builder: (c) => const ToastPlaygroundScreen()),
  PreviewScreenOption(name: 'Keyboard Shortcuts', builder: (c) => const KeyboardShortcutCenterScreen()),
  PreviewScreenOption(name: 'Industry Packs', builder: (c) => const IndustryPackLauncherScreen()),
];

class ResponsivePreviewCenterScreen extends ConsumerStatefulWidget {
  const ResponsivePreviewCenterScreen({super.key});

  @override
  ConsumerState<ResponsivePreviewCenterScreen> createState() => _ResponsivePreviewCenterScreenState();
}

class _ResponsivePreviewCenterScreenState extends ConsumerState<ResponsivePreviewCenterScreen> {
  DeviceProfile _selectedDevice = mockDevices[2]; // Default to Laptop
  PreviewScreenOption _selectedScreen = previewScreens[0];
  bool _isLandscape = false;
  double _zoomLevel = 1.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final targetWidth = _isLandscape ? _selectedDevice.height : _selectedDevice.width;
    final targetHeight = _isLandscape ? _selectedDevice.width : _selectedDevice.height;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Responsive Preview Center'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                // Screen Selector
                Expanded(
                  child: DropdownButton<PreviewScreenOption>(
                    isExpanded: true,
                    value: _selectedScreen,
                    items: previewScreens.map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.name),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedScreen = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Device Selector
                Expanded(
                  child: DropdownButton<DeviceProfile>(
                    isExpanded: true,
                    value: _selectedDevice,
                    items: mockDevices.map((d) => DropdownMenuItem(
                      value: d,
                      child: Row(
                        children: [
                          Icon(d.icon, size: 16),
                          const SizedBox(width: 8),
                          Text('${d.name} (${d.width.toInt()}x${d.height.toInt()})'),
                        ],
                      ),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDevice = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Orientation Toggle
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, icon: Icon(LucideIcons.smartphone), label: Text('Portrait')),
                    ButtonSegment(value: true, icon: Icon(LucideIcons.monitor), label: Text('Landscape')),
                  ],
                  selected: {_isLandscape},
                  onSelectionChanged: (set) {
                    setState(() => _isLandscape = set.first);
                  },
                ),
                const SizedBox(width: 16),
                // Zoom Control
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.zoomOut),
                      onPressed: () => setState(() => _zoomLevel = (_zoomLevel - 0.1).clamp(0.2, 2.0)),
                    ),
                    Text('${(_zoomLevel * 100).toInt()}%', style: theme.textTheme.bodyMedium),
                    IconButton(
                      icon: const Icon(LucideIcons.zoomIn),
                      onPressed: () => setState(() => _zoomLevel = (_zoomLevel + 0.1).clamp(0.2, 2.0)),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Preview Area
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              alignment: Alignment.center,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Transform.scale(
                    scale: _zoomLevel,
                    child: Container(
                      width: targetWidth,
                      height: targetHeight,
                      margin: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border.all(color: theme.colorScheme.outline, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ResponsiveBreakpoints.builder(
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            size: Size(targetWidth, targetHeight),
                          ),
                          child: IgnorePointer(
                            ignoring: false, // Allow interactions within the preview
                            child: Navigator(
                              onGenerateRoute: (settings) {
                                return MaterialPageRoute(
                                  builder: (context) => _selectedScreen.builder(context),
                                );
                              },
                            ),
                          ),
                        ),
                        breakpoints: [
                          const Breakpoint(start: 0, end: 450, name: MOBILE),
                          const Breakpoint(start: 451, end: 800, name: TABLET),
                          const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                          const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
