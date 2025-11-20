import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/presentation/widgets/app_drawer.dart';
import '../state/timer_notifier.dart';
import '../state/timer_state.dart';
import '../widgets/duration_picker.dart';
import '../widgets/mode_selector.dart';
import '../widgets/subject_dropdown.dart';
import '../widgets/timer_controls.dart';
import '../widgets/timer_ring.dart';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beeController;
  late final Animation<double> _beeOffset;
  late final Animation<double> _beeTilt;

  @override
  void initState() {
    super.initState();
    _beeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _beeOffset = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _beeController, curve: Curves.easeInOut));
    _beeTilt = Tween<double>(
      begin: -0.04,
      end: 0.04,
    ).animate(CurvedAnimation(parent: _beeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _beeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('BeeFocus'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books_outlined),
            onPressed: () => context.goNamed('subjects'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            ModeSelector(
              mode: timerState.mode,
              onModeChanged: notifier.toggleMode,
            ),
            if (timerState.mode == TimerMode.countdown) ...[
              const SizedBox(height: 12),
              DurationPicker(
                minutes: (timerState.totalSeconds ~/ 60),
                onSelect: (m) => notifier.setCountdownMinutes(m),
              ),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TimerRing(
                    mode: timerState.mode,
                    isRunning: timerState.isRunning,
                    progress: timerState.progress,
                    beeOffset: _beeOffset,
                    beeTilt: _beeTilt,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    timerState.formattedTime,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    timerState.mode == TimerMode.countdown
                        ? 'Sayaç'
                        : 'Kronometre',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  TimerControls(
                    isRunning: timerState.isRunning,
                    onReset: notifier.reset,
                    onToggle: notifier.toggleRunPause,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SubjectDropdown(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
