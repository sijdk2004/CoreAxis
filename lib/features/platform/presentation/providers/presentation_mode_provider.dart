import 'package:flutter_riverpod/flutter_riverpod.dart';

class PresentationModeState {
  final bool isLaserPointerActive;
  final bool isFocusModeActive;
  final double zoomLevel;
  final int currentModuleIndex;

  const PresentationModeState({
    this.isLaserPointerActive = false,
    this.isFocusModeActive = false,
    this.zoomLevel = 1.0,
    this.currentModuleIndex = 0,
  });

  PresentationModeState copyWith({
    bool? isLaserPointerActive,
    bool? isFocusModeActive,
    double? zoomLevel,
    int? currentModuleIndex,
  }) {
    return PresentationModeState(
      isLaserPointerActive: isLaserPointerActive ?? this.isLaserPointerActive,
      isFocusModeActive: isFocusModeActive ?? this.isFocusModeActive,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      currentModuleIndex: currentModuleIndex ?? this.currentModuleIndex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PresentationModeState &&
      other.isLaserPointerActive == isLaserPointerActive &&
      other.isFocusModeActive == isFocusModeActive &&
      other.zoomLevel == zoomLevel &&
      other.currentModuleIndex == currentModuleIndex;
  }

  @override
  int get hashCode => Object.hash(
    isLaserPointerActive,
    isFocusModeActive,
    zoomLevel,
    currentModuleIndex,
  );
}

final presentationModeProvider = NotifierProvider<PresentationModeNotifier, PresentationModeState>(() {
  return PresentationModeNotifier();
});

class PresentationModeNotifier extends Notifier<PresentationModeState> {
  @override
  PresentationModeState build() {
    return const PresentationModeState();
  }

  void toggleLaserPointer() {
    state = state.copyWith(isLaserPointerActive: !state.isLaserPointerActive);
  }

  void toggleFocusMode() {
    state = state.copyWith(isFocusModeActive: !state.isFocusModeActive);
  }

  void setZoomLevel(double level) {
    state = state.copyWith(zoomLevel: level.clamp(0.5, 2.0));
  }

  void nextModule(int maxModules) {
    if (state.currentModuleIndex < maxModules - 1) {
      state = state.copyWith(currentModuleIndex: state.currentModuleIndex + 1);
    }
  }

  void previousModule() {
    if (state.currentModuleIndex > 0) {
      state = state.copyWith(currentModuleIndex: state.currentModuleIndex - 1);
    }
  }
}
