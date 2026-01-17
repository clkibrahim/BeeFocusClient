import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../subjects/data/subject_model.dart';

class SubjectDropdown extends StatelessWidget {
  const SubjectDropdown({super.key, this.subject});

  final Subject? subject;

  @override
  Widget build(BuildContext context) {
    final label = subject?.name ?? 'Ders seçilmedi';
    final color = _colorFromHex(subject?.colorHex) ?? AppColors.softPink;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          const Icon(Icons.expand_more, color: AppColors.mutedBrown),
        ],
      ),
    );
  }

  Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      final value = int.parse(hex.replaceAll('#', ''), radix: 16);
      if (hex.length == 6) {
        return Color(0xFF000000 | value);
      }
      if (hex.length == 8) {
        return Color(value);
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
