import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.isRunning,
    required this.onReset,
    required this.onToggle,
  });

  final bool isRunning;
  final VoidCallback onReset;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundedIconButton(icon: Icons.refresh, onTap: onReset),
        const SizedBox(width: 24),
        _RoundedIconButton(
          diameter: 78,
          icon: isRunning ? Icons.pause : Icons.play_arrow,
          iconColor: Colors.white,
          background: AppColors.darkBrown,
          onTap: onToggle,
          shadow: true,
        ),
        const SizedBox(width: 24),
        const _RoundedIconButton(icon: Icons.volume_up_outlined),
      ],
    );
  }
}

class _RoundedIconButton extends StatelessWidget {
  const _RoundedIconButton({
    super.key,
    required this.icon,
    this.background = Colors.white,
    this.iconColor = AppColors.darkBrown,
    this.diameter = 54,
    this.onTap,
    this.shadow = false,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final double diameter;
  final VoidCallback? onTap;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: diameter,
        width: diameter,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: shadow
              ? const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Icon(icon, color: iconColor, size: 28),
      ),
    );
  }
}
