enum ColorBlindMode { none, protanopia, deuteranopia, tritanopia }

class AccessibilitySettingsModel {
  final bool highContrast;
  final bool largeFonts;
  final bool reducedMotion;
  final bool screenReaderLabels;
  final bool keyboardNavigation;
  final bool focusIndicators;
  final ColorBlindMode colorBlindMode;

  const AccessibilitySettingsModel({
    this.highContrast = false,
    this.largeFonts = false,
    this.reducedMotion = false,
    this.screenReaderLabels = false,
    this.keyboardNavigation = false,
    this.focusIndicators = false,
    this.colorBlindMode = ColorBlindMode.none,
  });

  AccessibilitySettingsModel copyWith({
    bool? highContrast,
    bool? largeFonts,
    bool? reducedMotion,
    bool? screenReaderLabels,
    bool? keyboardNavigation,
    bool? focusIndicators,
    ColorBlindMode? colorBlindMode,
  }) {
    return AccessibilitySettingsModel(
      highContrast: highContrast ?? this.highContrast,
      largeFonts: largeFonts ?? this.largeFonts,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      screenReaderLabels: screenReaderLabels ?? this.screenReaderLabels,
      keyboardNavigation: keyboardNavigation ?? this.keyboardNavigation,
      focusIndicators: focusIndicators ?? this.focusIndicators,
      colorBlindMode: colorBlindMode ?? this.colorBlindMode,
    );
  }

  /// Calculates a mock accessibility score out of 100 based on enabled features.
  int get calculateScore {
    int score = 40; // Base score out of the box
    if (highContrast) score += 10;
    if (largeFonts) score += 10;
    if (reducedMotion) score += 10;
    if (screenReaderLabels) score += 10;
    if (keyboardNavigation) score += 10;
    if (focusIndicators) score += 10;
    return score;
  }
}
