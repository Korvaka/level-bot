import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  String _goalLabel(AppLocalizations l10n) {
    switch (program.goal) {
      case ProgramGoal.strength:
        return l10n.strengthGoal;
      case ProgramGoal.hypertrophy:
        return l10n.hypertrophyGoal;
      case ProgramGoal.endurance:
        return l10n.enduranceGoal;
      case ProgramGoal.powerlifting:
        return l10n.powerliftingGoal;
      case ProgramGoal.weightLoss:
        return l10n.weightLossGoal;
      case ProgramGoal.athletic:
        return l10n.athleticGoal;
      case ProgramGoal.general:
        return l10n.generalGoal;
    }
  }

  String _difficultyLabel(AppLocalizations l10n) {
    switch (program.difficulty) {
      case DifficultyLevel.beginner:
        return l10n.beginnerLevel;
      case DifficultyLevel.intermediate:
        return l10n.intermediateLevel;
      case DifficultyLevel.advanced:
        return l10n.advancedLevel;
      case DifficultyLevel.expert:
        return l10n.expertLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final muscleColor = _goalColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: muscleColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    muscleColor.withOpacity(0.25),
                    muscleColor.withOpacity(0.08),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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
                            color: muscleColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _goalLabel(l10n),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: muscleColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _difficultyLabel(l10n),
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
                    color: muscleColor.withOpacity(0.35),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: '${program.daysPerWeek}×/wk',
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.view_list_rounded,
                        label: '${program.days.length} ${l10n.days}',
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
        Icon(icon, size: 12, color: context.colorScheme.onSurfaceVariant),
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
