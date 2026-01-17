import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sessions_repository.dart';
import 'sessions_providers.dart';
import 'timer_state.dart';

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  final sessionsRepository = ref.watch(sessionsRepositoryProvider);
  return TimerNotifier(sessionsRepository);
});

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier(this._sessionsRepository)
    : super(
        const TimerState(
          mode: TimerMode.countdown,
          isRunning: false,
          isPaused: false,
          totalSeconds: _defaultCountdownSeconds,
        ),
      );

  static const int _defaultCountdownSeconds = 25 * 60;
  static const int _stopwatchLoopSeconds = 60 * 60; // ring loops hourly

  Timer? _ticker;
  final SessionsRepository _sessionsRepository;

  String? _currentSubjectId;
  DateTime? _currentStartAt;
  String? _remoteSessionId; // Backend'den gelen session ID

  bool get _hasActiveSession => _currentStartAt != null;

  void toggleMode() {
    _stopTicker();
    _currentSubjectId = null;
    _currentStartAt = null;
    _remoteSessionId = null;
    final newMode = state.mode == TimerMode.countdown
        ? TimerMode.stopwatch
        : TimerMode.countdown;
    state = TimerState(
      mode: newMode,
      isRunning: false,
      isPaused: false,
      totalSeconds: newMode == TimerMode.countdown
          ? _defaultCountdownSeconds
          : _stopwatchLoopSeconds,
      elapsedSeconds: 0,
    );
  }

  /// İlk kez veya duraklatıldıktan sonra pomodoroyu başlat/başlatmaya devam et.
  /// subjectId null olabilir; bu durumda derssiz bir oturum olarak kaydedilir.
  void startPomodoro(String? subjectId) async {
    if (state.isRunning) return;

    if (!_hasActiveSession) {
      // Yeni oturum başlamadan önce eski senkronize edilmemiş session'ları gönder
      _sessionsRepository.syncUnsyncedSessions();

      // Yeni oturum
      _currentSubjectId = subjectId;
      _currentStartAt = DateTime.now().toUtc();

      // API'ye session başlat
      if (_currentSubjectId != null) {
        _remoteSessionId = await _sessionsRepository.startSession(
          subjectId: _currentSubjectId!,
          startTime: _currentStartAt!,
          sessionType: state.mode == TimerMode.countdown
              ? 0
              : 1, // 0=Pomodoro, 1=Stopwatch
          durationGoalMinutes: state.mode == TimerMode.countdown
              ? (state.totalSeconds ~/ 60)
              : null,
        );
      }
    }

    state = state.copyWith(isRunning: true, isPaused: false);
    _startTicker();
  }

  /// Çalışan pomodoroyu duraklat.
  void pausePomodoro() {
    if (!state.isRunning) return;
    _stopTicker();
    state = state.copyWith(isRunning: false, isPaused: true);
  }

  /// Duraklamış pomodoroyu devam ettir.
  void continuePomodoro() {
    if (state.isRunning || !_hasActiveSession) return;
    state = state.copyWith(isRunning: true, isPaused: false);
    _startTicker();
  }

  /// Pomodoroyu bitir ve oturumu kaydet.
  void finishPomodoro() {
    _stopTicker();
    _finalizeSession();
    state = TimerState(
      mode: state.mode,
      isRunning: false,
      isPaused: false,
      totalSeconds: state.mode == TimerMode.countdown
          ? _defaultCountdownSeconds
          : _stopwatchLoopSeconds,
      elapsedSeconds: 0,
    );
  }

  void setCountdownMinutes(int minutes) {
    if (state.mode != TimerMode.countdown) return;
    // Aktif veya duraklamış oturum varken süre değişmesin
    if (state.isRunning || state.isPaused || state.elapsedSeconds > 0) return;
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
          isPaused: false,
          elapsedSeconds: state.totalSeconds,
        );
        _finalizeSession();
        // Süre dolunca otomatik yeni pomodoro için sıfırla
        state = TimerState(
          mode: state.mode,
          isRunning: false,
          isPaused: false,
          totalSeconds: state.mode == TimerMode.countdown
              ? _defaultCountdownSeconds
              : _stopwatchLoopSeconds,
          elapsedSeconds: 0,
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

  void _finalizeSession() {
    if (_currentSubjectId == null || _currentStartAt == null) {
      _currentSubjectId = null;
      _currentStartAt = null;
      _remoteSessionId = null;
      return;
    }

    // Süre 0 ise kayıt alma
    if (state.elapsedSeconds <= 0) {
      _currentSubjectId = null;
      _currentStartAt = null;
      _remoteSessionId = null;
      return;
    }

    final endTime = DateTime.now().toUtc();

    // Session'ı API'ye finish olarak gönder ve yerel veritabanına kaydet
    _sessionsRepository.finishSession(
      remoteSessionId: _remoteSessionId,
      subjectId: _currentSubjectId!,
      startTime: _currentStartAt!,
      endTime: endTime,
      totalSeconds: state.elapsedSeconds,
    );

    _currentSubjectId = null;
    _currentStartAt = null;
    _remoteSessionId = null;
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
