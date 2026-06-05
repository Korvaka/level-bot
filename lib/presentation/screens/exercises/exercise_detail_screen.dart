import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_error.dart';
import 'package:level_bot/presentation/widgets/common/app_loading.dart';
import 'package:level_bot/presentation/widgets/exercise/video_player_widget.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseByIdProvider(exerciseId));

    return exerciseAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppError(message: e.toString()),
      ),
      data: (exercise) => _ExerciseDetailContent(exercise: exercise),
    );
  }
}

class _ExerciseDetailContent extends StatelessWidget {
  const _ExerciseDetailContent({required this.exercise});
  final ExerciseEntity exercise;

  Color _muscleColor(MuscleGroup g) {
    switch (g) {
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

  String _muscleLabel(MuscleGroup g) => g.name.replaceFirst(
        g.name[0],
        g.name[0].toUpperCase(),
      );

  @override
  Widget build(BuildContext context) {
    final primaryColor = _muscleColor(exercise.primaryMuscle);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_border_rounded),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                exercise.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.6),
                      primaryColor.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.fitness_center_rounded,
                    size: 80,
                    color: primaryColor.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBadges(context, primaryColor),
                  const SizedBox(height: 24),
                  if (exercise.videos.isNotEmpty) ...[
                    _buildVideoPlayer(context),
                    const SizedBox(height: 24),
                  ],
                  _buildMuscles(context),
                  const SizedBox(height: 24),
                  _buildDescription(context),
                  const SizedBox(height: 24),
                  _buildInstructions(context),
                  if (exercise.commonMistakes.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildCommonMistakes(context),
                  ],
                  if (exercise.tips.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildTips(context),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          AppLocalizations.of(context)!.addToWorkout,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildBadges(BuildContext context, Color primaryColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Badge(
          label: exercise.equipment.name.replaceFirst(
              exercise.equipment.name[0],
              exercise.equipment.name[0].toUpperCase()),
          icon: Icons.fitness_center_rounded,
          color: AppColors.primary,
        ),
        _Badge(
          label: exercise.difficulty.name.replaceFirst(
              exercise.difficulty.name[0],
              exercise.difficulty.name[0].toUpperCase()),
          icon: Icons.bar_chart_rounded,
          color: _getDifficultyColor(exercise.difficulty),
        ),
        _Badge(
          label: exercise.category.name.replaceFirst(
              exercise.category.name[0],
              exercise.category.name[0].toUpperCase()),
          icon: Icons.category_outlined,
          color: AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildMuscles(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.musclesLabel, style: context.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            _MuscleTag(
              label: _muscleLabel(exercise.primaryMuscle),
              color: _muscleColor(exercise.primaryMuscle),
              isPrimary: true,
            ),
            ...exercise.secondaryMuscles.map((m) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _MuscleTag(
                    label: _muscleLabel(m),
                    color: _muscleColor(m),
                    isPrimary: false,
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.description, style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          exercise.description,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.howToPerform, style: context.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...exercise.instructions.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: context.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    final primary = exercise.primaryVideo!;
    final hasMultiple = exercise.videos.length > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.videosLabel,
            style: context.textTheme.titleMedium),
        const SizedBox(height: 12),
        ExerciseVideoPlayer(
          url: primary.url,
          thumbnailUrl: primary.thumbnailUrl,
          showControls: true,
        ),
        if (hasMultiple) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: exercise.videos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final v = exercise.videos[i];
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: v.isPrimary
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: v.thumbnailUrl != null
                          ? Image.network(v.thumbnailUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.play_circle_outline_rounded,
                              color: AppColors.primary),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommonMistakes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.commonMistakes,
            style: context.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...exercise.commonMistakes.map((mistake) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      mistake,
                      style: context.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildTips(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.proTips, style: context.textTheme.titleMedium),
        const SizedBox(height: 12),
        ...exercise.tips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: AppColors.accentYellow,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip,
                      style: context.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Color _getDifficultyColor(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner: return AppColors.success;
      case DifficultyLevel.intermediate: return AppColors.warning;
      case DifficultyLevel.advanced: return AppColors.accentOrange;
      case DifficultyLevel.expert: return AppColors.error;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MuscleTag extends StatelessWidget {
  const _MuscleTag({
    required this.label,
    required this.color,
    required this.isPrimary,
  });
  final String label;
  final Color color;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(isPrimary ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPrimary)
            Icon(Icons.star_rounded, size: 12, color: color),
          if (isPrimary) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
