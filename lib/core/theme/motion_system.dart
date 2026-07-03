import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// CoreAxis ERP Standardized Motion System
/// 
/// This file defines the global animation presets used across the entire platform
/// to ensure a cohesive, professional, and snappy user experience.
class CoreAxisMotion {
  // Standard Durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration relaxed = Duration(milliseconds: 500);
  
  // Standard Curves
  static const Curve enterCurve = Curves.easeOutCubic;
  static const Curve exitCurve = Curves.easeInCubic;
  static const Curve emphasizeCurve = Curves.easeInOutBack;
}

/// Extension on Animate to provide reusable, chainable animations.
extension CoreAxisMotionExtensions on Animate {
  /// Standard fade-in for data entering the screen.
  Animate coreFadeIn({Duration? delay}) => fadeIn(
        duration: CoreAxisMotion.standard,
        curve: CoreAxisMotion.enterCurve,
        delay: delay,
      );

  /// Standard slide-up often used with fade for list items or cards.
  Animate coreSlideUp({Duration? delay, double begin = 0.1}) => slideY(
        begin: begin,
        end: 0,
        duration: CoreAxisMotion.standard,
        curve: CoreAxisMotion.enterCurve,
        delay: delay,
      );

  /// Subtle scale-up for dialogs or popovers.
  Animate coreScaleUp({Duration? delay}) => scale(
        begin: const Offset(0.95, 0.95),
        end: const Offset(1, 1),
        duration: CoreAxisMotion.standard,
        curve: CoreAxisMotion.enterCurve,
        delay: delay,
      );

  /// Emphasized scale for interactive feedback (like button presses or toggles).
  Animate corePop({Duration? delay}) => scale(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1, 1),
        duration: CoreAxisMotion.relaxed,
        curve: CoreAxisMotion.emphasizeCurve,
        delay: delay,
      );
      
  /// Continuous shimmer effect for loading skeletons.
  Animate coreShimmerLoading() => shimmer(
        duration: const Duration(milliseconds: 1500),
        color: Colors.white24,
      );

  /// Entrance animation for chart bars or data points.
  Animate coreChartEntry({Duration? delay}) => scaleY(
        begin: 0,
        end: 1,
        alignment: Alignment.bottomCenter,
        duration: CoreAxisMotion.relaxed,
        curve: CoreAxisMotion.enterCurve,
        delay: delay,
      );
}
