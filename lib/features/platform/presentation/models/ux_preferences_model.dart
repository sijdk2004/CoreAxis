enum ThemePreference { light, dark, system }
enum DensityPreference { compact, comfortable, spacious }
enum SidebarPreference { expanded, collapsed, floating }
enum DashboardLayoutPreference { standard, compact, analytical }

class UxPreferencesModel {
  final ThemePreference theme;
  final DensityPreference density;
  final SidebarPreference sidebar;
  final DashboardLayoutPreference dashboardLayout;
  final bool animationsEnabled;
  final bool notificationsEnabled;
  final String language;
  final String dateFormat;
  final String timeZone;
  final bool highContrast;
  final bool enableShortcuts;

  const UxPreferencesModel({
    this.theme = ThemePreference.system,
    this.density = DensityPreference.comfortable,
    this.sidebar = SidebarPreference.expanded,
    this.dashboardLayout = DashboardLayoutPreference.standard,
    this.animationsEnabled = true,
    this.notificationsEnabled = true,
    this.language = 'English (US)',
    this.dateFormat = 'MM/DD/YYYY',
    this.timeZone = 'UTC -08:00 (Pacific Time)',
    this.highContrast = false,
    this.enableShortcuts = true,
  });

  UxPreferencesModel copyWith({
    ThemePreference? theme,
    DensityPreference? density,
    SidebarPreference? sidebar,
    DashboardLayoutPreference? dashboardLayout,
    bool? animationsEnabled,
    bool? notificationsEnabled,
    String? language,
    String? dateFormat,
    String? timeZone,
    bool? highContrast,
    bool? enableShortcuts,
  }) {
    return UxPreferencesModel(
      theme: theme ?? this.theme,
      density: density ?? this.density,
      sidebar: sidebar ?? this.sidebar,
      dashboardLayout: dashboardLayout ?? this.dashboardLayout,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      dateFormat: dateFormat ?? this.dateFormat,
      timeZone: timeZone ?? this.timeZone,
      highContrast: highContrast ?? this.highContrast,
      enableShortcuts: enableShortcuts ?? this.enableShortcuts,
    );
  }
}
