import 'package:flutter/material.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
    this.trailing,
  });

  final ExerciseEntity exercise;
  final VoidCallback? onTap;
  final Widget? trailing;

  Color _muscleColor() {
    switch (exercise.primaryMuscle) {
      case MuscleGroup.chest: return AppColors.chest;
      case MuscleGroup.back: return AppColors.back;
      case MuscleGroup.shoulders: return AppColors.shoulders;
      case MuscleGroup.biceps: return AppColors.biceps;
      case MuscleGroup.triceps: return AppColors.triceps;
      case MuscleGroup.forearms: return AppColors.forearms;
      case MuscleGroup.abs: return AppColors.abs;
      case MuscleGroup.quads: return AppColors.quads;
      case MuscleGroup.hamstrings: return AppColors.hamstrings;
      case MuscleGroup.glutes: return AppColors.glutes;
      case MuscleGroup.calves: return AppColors.calves;
      case MuscleGroup.cardio: return AppColors.cardio;
      case MuscleGroup.fullBody: return AppColors.primary;
    }
  }

  String _muscleLabel() {
    final name = exercise.primaryMuscle.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  String _equipmentLabel() {
    final name = exercise.equipment.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final muscleColor = _muscleColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: muscleColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: muscleColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: context.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: muscleColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _muscleLabel(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: muscleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _equipmentLabel(),
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.colorScheme.onSurfaceVariant,
                ),
          ],
        ),
      ),
    );
  }
}
