enum TimerMode { countdown, stopwatch }

class TimerState {
  const TimerState({
    this.mode = TimerMode.countdown,
    this.isRunning = false,
    this.totalSeconds = 25 * 60,
    this.elapsedSeconds = 0,
  });

  final TimerMode mode;
  final bool isRunning;
  final int totalSeconds;
  final int elapsedSeconds;

  int get _remainingSeconds =>
      (totalSeconds - elapsedSeconds).clamp(0, totalSeconds);

  int get displaySeconds =>
      mode == TimerMode.countdown ? _remainingSeconds : elapsedSeconds;

  String get formattedTime {
    final minutes = displaySeconds ~/ 60;
    final seconds = displaySeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (totalSeconds <= 0) return 0;
    if (mode == TimerMode.countdown) {
      return (elapsedSeconds / totalSeconds).clamp(0, 1);
    }
    return ((elapsedSeconds % totalSeconds) / totalSeconds).clamp(0, 1);
  }

  TimerState copyWith({
    TimerMode? mode,
    bool? isRunning,
    int? totalSeconds,
    int? elapsedSeconds,
  }) {
    return TimerState(
      mode: mode ?? this.mode,
      isRunning: isRunning ?? this.isRunning,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}
