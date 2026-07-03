import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/accessibility_settings_model.dart';

final accessibilityProvider = NotifierProvider<AccessibilityNotifier, AccessibilitySettingsModel>(() {
  return AccessibilityNotifier();
});

class AccessibilityNotifier extends Notifier<AccessibilitySettingsModel> {
  @override
  AccessibilitySettingsModel build() {
    return const AccessibilitySettingsModel();
  }

  void toggleHighContrast(bool value) {
    state = state.copyWith(highContrast: value);
  }

  void toggleLargeFonts(bool value) {
    state = state.copyWith(largeFonts: value);
  }

  void toggleReducedMotion(bool value) {
    state = state.copyWith(reducedMotion: value);
  }

  void toggleScreenReaderLabels(bool value) {
    state = state.copyWith(screenReaderLabels: value);
  }

  void toggleKeyboardNavigation(bool value) {
    state = state.copyWith(keyboardNavigation: value);
  }

  void toggleFocusIndicators(bool value) {
    state = state.copyWith(focusIndicators: value);
  }

  void setColorBlindMode(ColorBlindMode mode) {
    state = state.copyWith(colorBlindMode: mode);
  }
}
