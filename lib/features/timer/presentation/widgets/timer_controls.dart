import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TimerControls extends StatelessWidget {
  const TimerControls({
    super.key,
    required this.isRunning,
    required this.isPaused,
    required this.onStart,
    required this.onStop,
    required this.onContinue,
    required this.onFinish,
  });

  final bool isRunning;
  final bool isPaused;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onContinue;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    if (!isRunning && !isPaused) {
      // Başlangıç: sadece başlat düğmesi
      return _RoundedIconButton(
        diameter: 64,
        icon: Icons.play_arrow,
        iconColor: Colors.white,
        background: AppColors.darkBrown,
        onTap: onStart,
        shadow: true,
      );
    }

    if (isRunning) {
      // Çalışırken: sadece durdurma düğmesi
      return _RoundedIconButton(
        diameter: 64,
        icon: Icons.stop,
        iconColor: Colors.white,
        background: AppColors.darkBrown,
        onTap: onStop,
        shadow: true,
      );
    }

    // Duraklatılmış: devam + bitir
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RoundedIconButton(
          diameter: 64,
          icon: Icons.play_arrow,
          background: Colors.white,
          iconColor: AppColors.darkBrown,
          onTap: onContinue,
        ),
        const SizedBox(width: 24),
        _RoundedIconButton(
          diameter: 64,
          icon: Icons.check,
          background: AppColors.darkBrown,
          iconColor: Colors.white,
          onTap: onFinish,
          shadow: true,
        ),
      ],
    );
  }
}

class _RoundedIconButton extends StatefulWidget {
  const _RoundedIconButton({
    required this.icon,
    this.background = Colors.white,
    this.iconColor = AppColors.darkBrown,
    this.diameter = 54,
    this.iconSize = 28,
    this.onTap,
    this.shadow = false,
  });

  final IconData icon;
  final Color background;
  final Color iconColor;
  final double diameter;
  final double iconSize;
  final VoidCallback? onTap;
  final bool shadow;

  @override
  State<_RoundedIconButton> createState() => _RoundedIconButtonState();
}

class _RoundedIconButtonState extends State<_RoundedIconButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
  }

  void _handleTapEnd([TapUpDetails? _]) {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.92 : 1.0;

    return GestureDetector
    (
      onTap: widget.onTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapEnd,
      onTapCancel: _handleTapEnd,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Container(
          height: widget.diameter,
          width: widget.diameter,
          decoration: BoxDecoration(
            color: widget.background,
            shape: BoxShape.circle,
            boxShadow: widget.shadow
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
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
          child:
              Icon(widget.icon, color: widget.iconColor, size: widget.iconSize),
        ),
      ),
    );
  }
}
