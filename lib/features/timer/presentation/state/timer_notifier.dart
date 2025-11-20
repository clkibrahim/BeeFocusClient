import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_state.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier()
    : super(
        const TimerState(
          mode: TimerMode.countdown,
          isRunning: false,
          totalSeconds: _defaultCountdownSeconds,
        ),
      );

  static const int _defaultCountdownSeconds = 25 * 60;
  static const int _stopwatchLoopSeconds = 60 * 60; // ring loops hourly

  Timer? _ticker;

  void toggleMode() {
    _stopTicker();
    final newMode = state.mode == TimerMode.countdown
        ? TimerMode.stopwatch
        : TimerMode.countdown;
    state = TimerState(
      mode: newMode,
      isRunning: false,
      totalSeconds: newMode == TimerMode.countdown
          ? _defaultCountdownSeconds
          : _stopwatchLoopSeconds,
      elapsedSeconds: 0,
    );
  }

  void toggleRunPause() {
    if (state.isRunning) {
      _stopTicker();
      state = state.copyWith(isRunning: false);
      return;
    }
    state = state.copyWith(isRunning: true);
    _startTicker();
  }

  void reset() {
    _stopTicker();
    state = TimerState(
      mode: state.mode,
      isRunning: false,
      totalSeconds: state.mode == TimerMode.countdown
          ? _defaultCountdownSeconds
          : _stopwatchLoopSeconds,
      elapsedSeconds: 0,
    );
  }

  void setCountdownMinutes(int minutes) {
    if (state.mode != TimerMode.countdown) return;
    _stopTicker();
    final seconds = (minutes * 60).clamp(1 * 60, 12 * 60 * 60);
    state = state.copyWith(
      isRunning: false,
      totalSeconds: seconds,
      elapsedSeconds: 0,
    );
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _onTick() {
    if (!state.isRunning) return;

    final nextElapsed = state.elapsedSeconds + 1;
    if (state.mode == TimerMode.countdown) {
      if (nextElapsed >= state.totalSeconds) {
        _stopTicker();
        state = state.copyWith(
          isRunning: false,
          elapsedSeconds: state.totalSeconds,
        );
        return;
      }
    }

    state = state.copyWith(elapsedSeconds: nextElapsed);
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
