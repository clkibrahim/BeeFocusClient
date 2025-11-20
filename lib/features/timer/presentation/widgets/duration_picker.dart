import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DurationPicker extends StatefulWidget {
  const DurationPicker({
    super.key,
    required this.minutes,
    required this.onSelect,
  });

  final int minutes;
  final ValueChanged<int> onSelect;

  @override
  State<DurationPicker> createState() => _DurationPickerState();
}

class _DurationPickerState extends State<DurationPicker> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    final initial = widget.minutes.clamp(1, 180);
    _controller = FixedExtentScrollController(initialItem: initial - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer, color: AppColors.darkBrown),
            const SizedBox(width: 10),
            Text(
              '${widget.minutes} dk',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.expand_more, color: AppColors.mutedBrown),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  height: 4,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Dakika seç',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: CupertinoPicker.builder(
                    scrollController: _controller,
                    itemExtent: 44,
                    childCount: 180,
                    onSelectedItemChanged: (_) {},
                    selectionOverlay:
                        const CupertinoPickerDefaultSelectionOverlay(
                          background: Colors.transparent,
                        ),
                    itemBuilder: (context, index) {
                      final value = index + 1;
                      final isSelected = value == widget.minutes;
                      return Center(
                        child: Text(
                          '$value dk',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: isSelected
                                    ? AppColors.darkBrown
                                    : AppColors.mutedBrown,
                              ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBrown,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      final selected = _controller.selectedItem + 1;
                      Navigator.of(ctx).pop();
                      widget.onSelect(selected);
                    },
                    child: const Text('Onayla'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
