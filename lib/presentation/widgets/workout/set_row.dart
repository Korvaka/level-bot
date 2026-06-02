import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/workout_set_entity.dart';

class SetRow extends StatefulWidget {
  const SetRow({
    super.key,
    required this.set,
    required this.exerciseId,
    required this.onCompleted,
    required this.onRemove,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  final WorkoutSetEntity set;
  final String exerciseId;
  final void Function(bool) onCompleted;
  final VoidCallback onRemove;
  final void Function(double) onWeightChanged;
  final void Function(int) onRepsChanged;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  Color get _rowColor {
    if (widget.set.isCompleted) {
      return AppColors.success.withOpacity(0.08);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: _rowColor,
      child: Row(
        children: [
          GestureDetector(
            onLongPress: widget.onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.set.isCompleted
                    ? AppColors.success.withOpacity(0.2)
                    : Theme.of(context)
                        .colorScheme
                        .outline
                        .withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  widget.set.setNumber.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.set.isCompleted
                        ? AppColors.success
                        : Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: _SetInput(
              controller: _weightController,
              hint: '0',
              suffix: 'kg',
              onChanged: (v) {
                final d = double.tryParse(v);
                if (d != null) widget.onWeightChanged(d);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _SetInput(
              controller: _repsController,
              hint: '0',
              suffix: 'reps',
              isInteger: true,
              onChanged: (v) {
                final i = int.tryParse(v);
                if (i != null) widget.onRepsChanged(i);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  widget.set.rpe?.toStringAsFixed(1) ?? '-',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => widget.onCompleted(!widget.set.isCompleted),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: widget.set.isCompleted
                    ? AppColors.success
                    : Theme.of(context)
                        .colorScheme
                        .outline
                        .withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 20,
                color: widget.set.isCompleted
                    ? Colors.white
                    : Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetInput extends StatelessWidget {
  const _SetInput({
    required this.controller,
    required this.hint,
    this.suffix,
    this.isInteger = false,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String? suffix;
  final bool isInteger;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: isInteger
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: isInteger
            ? [FilteringTextInputFormatter.digitsOnly]
            : [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
          filled: false,
          suffixText: suffix,
          suffixStyle: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
