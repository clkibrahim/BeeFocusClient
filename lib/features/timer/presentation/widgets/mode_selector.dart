import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../state/timer_state.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  final TimerMode mode;
  final VoidCallback onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _ModeButton(
            label: 'Sayaç',
            selected: mode == TimerMode.countdown,
            onTap: mode == TimerMode.countdown ? null : onModeChanged,
          ),
          _ModeButton(
            label: 'Kronometre',
            selected: mode == TimerMode.stopwatch,
            onTap: mode == TimerMode.stopwatch ? null : onModeChanged,
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                )
              : null,
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: selected ? AppColors.darkBrown : AppColors.mutedBrown,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
