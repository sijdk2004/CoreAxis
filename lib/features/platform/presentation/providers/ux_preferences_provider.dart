import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ux_preferences_model.dart';

final uxPreferencesProvider = NotifierProvider<UxPreferencesNotifier, UxPreferencesModel>(() {
  return UxPreferencesNotifier();
});

class UxPreferencesNotifier extends Notifier<UxPreferencesModel> {
  @override
  UxPreferencesModel build() {
    return const UxPreferencesModel();
  }

  void updateTheme(ThemePreference pref) => state = state.copyWith(theme: pref);
  void updateDensity(DensityPreference pref) => state = state.copyWith(density: pref);
  void updateSidebar(SidebarPreference pref) => state = state.copyWith(sidebar: pref);
  void updateDashboardLayout(DashboardLayoutPreference pref) => state = state.copyWith(dashboardLayout: pref);
  void toggleAnimations(bool value) => state = state.copyWith(animationsEnabled: value);
  void toggleNotifications(bool value) => state = state.copyWith(notificationsEnabled: value);
  void updateLanguage(String value) => state = state.copyWith(language: value);
  void updateDateFormat(String value) => state = state.copyWith(dateFormat: value);
  void updateTimeZone(String value) => state = state.copyWith(timeZone: value);
  void toggleHighContrast(bool value) => state = state.copyWith(highContrast: value);
  void toggleShortcuts(bool value) => state = state.copyWith(enableShortcuts: value);

  void resetToDefaults() {
    state = const UxPreferencesModel();
  }
}
