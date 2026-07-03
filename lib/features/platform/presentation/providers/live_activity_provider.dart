import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_event_model.dart';

class LiveActivityState {
  final List<ActivityEventModel> events;
  final int totalActivityCount;
  final bool isRunning;
  final double speedMultiplier;

  const LiveActivityState({
    required this.events,
    required this.totalActivityCount,
    required this.isRunning,
    required this.speedMultiplier,
  });

  LiveActivityState copyWith({
    List<ActivityEventModel>? events,
    int? totalActivityCount,
    bool? isRunning,
    double? speedMultiplier,
  }) {
    return LiveActivityState(
      events: events ?? this.events,
      totalActivityCount: totalActivityCount ?? this.totalActivityCount,
      isRunning: isRunning ?? this.isRunning,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
    );
  }
}

class LiveActivityNotifier extends Notifier<LiveActivityState> {
  Timer? _timer;
  
  @override
  LiveActivityState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return const LiveActivityState(
      events: [],
      totalActivityCount: 0,
      isRunning: false,
      speedMultiplier: 1.0,
    );
  }

  void togglePlayPause() {
    if (state.isRunning) {
      _timer?.cancel();
      state = state.copyWith(isRunning: false);
    } else {
      state = state.copyWith(isRunning: true);
      _scheduleNextEvent();
    }
  }

  void setSpeedMultiplier(double speed) {
    state = state.copyWith(speedMultiplier: speed);
    if (state.isRunning) {
      _timer?.cancel();
      _scheduleNextEvent();
    }
  }

  void _scheduleNextEvent() {
    if (!state.isRunning) return;

    // Base delay of 2 seconds, adjusted by speed multiplier
    final delayMs = (2000 / state.speedMultiplier).round();
    
    _timer = Timer(Duration(milliseconds: delayMs), () {
      _addRandomEvent();
      _scheduleNextEvent();
    });
  }

  void _addRandomEvent() {
    final newEvent = ActivityEventModel.generateRandom();
    
    // Keep max 50 events in the list for performance
    final updatedEvents = [newEvent, ...state.events];
    if (updatedEvents.length > 50) {
      updatedEvents.removeLast();
    }

    state = state.copyWith(
      events: updatedEvents,
      totalActivityCount: state.totalActivityCount + 1,
    );
  }

  void clearEvents() {
    state = state.copyWith(
      events: [],
      totalActivityCount: 0,
    );
  }
}

final liveActivityProvider = NotifierProvider<LiveActivityNotifier, LiveActivityState>(
  LiveActivityNotifier.new,
);
