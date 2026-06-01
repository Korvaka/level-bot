import 'package:flutter/material.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/entities/program_entity.dart';

class ProgramCard extends StatelessWidget {
  const ProgramCard({
    super.key,
    required this.program,
    this.onTap,
    this.showAuthor = false,
  });

  final ProgramEntity program;
  final VoidCallback? onTap;
  final bool showAuthor;

  Color _goalColor() {
    switch (program.goal) {
      case ProgramGoal.strength:
        return AppColors.accent;
      case ProgramGoal.hypertrophy:
        return AppColors.primary;
      case ProgramGoal.endurance:
        return AppColors.secondary;
      case ProgramGoal.powerlifting:
        return AppColors.accentOrange;
      case ProgramGoal.weightLoss:
        return AppColors.error;
      case ProgramGoal.athletic:
        return AppColors.info;
      case ProgramGoal.general:
        return AppColors.textSecondaryDark;
    }
  }

  String _goalLabel() {
    switch (program.goal) {
      case ProgramGoal.strength: return 'Strength';
      case ProgramGoal.hypertrophy: return 'Hypertrophy';
      case ProgramGoal.endurance: return 'Endurance';
      case ProgramGoal.powerlifting: return 'Powerlifting';
      case ProgramGoal.weightLoss: return 'Weight Loss';
      case ProgramGoal.athletic: return 'Athletic';
      case ProgramGoal.general: return 'General';
    }
  }

  String _difficultyLabel() {
    switch (program.difficulty) {
      case DifficultyLevel.beginner: return 'Beginner';
      case DifficultyLevel.intermediate: return 'Intermediate';
      case DifficultyLevel.advanced: return 'Advanced';
      case DifficultyLevel.expert: return 'Expert';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _goalColor().withOpacity(0.3),
                    _goalColor().withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _goalColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _goalLabel(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _goalColor(),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _difficultyLabel(),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.fitness_center_rounded,
                    size: 40,
                    color: _goalColor().withOpacity(0.4),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name,
                    style: context.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: '${program.daysPerWeek}x/week',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.view_list_rounded,
                        label: '${program.days.length} days',
                      ),
                      if (program.isPublic) ...[
                        const Spacer(),
                        Icon(
                          Icons.people_outline_rounded,
                          size: 14,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          program.usersCount.toString(),
                          style: context.textTheme.labelSmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (program.description != null &&
                      program.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      program.description!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
