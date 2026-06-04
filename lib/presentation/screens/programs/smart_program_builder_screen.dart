import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';

// ---------------------------------------------------------------------------
// Local goal enum
// ---------------------------------------------------------------------------

enum _BuilderGoal { strength, hypertrophy, endurance, cardio }

// ---------------------------------------------------------------------------
// Generated day model
// ---------------------------------------------------------------------------

class _GeneratedDay {
  _GeneratedDay({
    required this.name,
    required this.targetMuscles,
    required this.exercises,
  });

  final String name;
  final List<MuscleGroup> targetMuscles;
  final List<ExerciseEntity> exercises;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SmartProgramBuilderScreen extends ConsumerStatefulWidget {
  const SmartProgramBuilderScreen({super.key});

  @override
  ConsumerState<SmartProgramBuilderScreen> createState() =>
      _SmartProgramBuilderScreenState();
}

class _SmartProgramBuilderScreenState
    extends ConsumerState<SmartProgramBuilderScreen> {
  int _step = 0; // 0-3 are wizard steps, 4 is preview

  // Step 0: muscles
  final Set<MuscleGroup> _selectedMuscles = {};

  // Step 1: goal
  _BuilderGoal _goal = _BuilderGoal.hypertrophy;

  // Step 2: difficulty
  DifficultyLevel _difficulty = DifficultyLevel.intermediate;

  // Step 3: equipment
  final Set<Equipment> _selectedEquipment = {Equipment.barbell};

  // Step 4: generated
  List<_GeneratedDay> _generatedDays = [];

  // ---------------------------------------------------------------------------
  // Label / color helpers
  // ---------------------------------------------------------------------------

  /// Used internally (e.g. for generating day names) – always English.
  String _muscleLabel(MuscleGroup g) {
    switch (g) {
      case MuscleGroup.chest: return 'Chest';
      case MuscleGroup.back: return 'Back';
      case MuscleGroup.shoulders: return 'Shoulders';
      case MuscleGroup.biceps: return 'Biceps';
      case MuscleGroup.triceps: return 'Triceps';
      case MuscleGroup.forearms: return 'Forearms';
      case MuscleGroup.abs: return 'Abs';
      case MuscleGroup.quads: return 'Quads';
      case MuscleGroup.hamstrings: return 'Hamstrings';
      case MuscleGroup.glutes: return 'Glutes';
      case MuscleGroup.calves: return 'Calves';
      case MuscleGroup.cardio: return 'Cardio';
      case MuscleGroup.fullBody: return 'Full Body';
    }
  }

  /// Localized muscle label for UI display.
  String _muscleLabelL10n(AppLocalizations l10n, MuscleGroup g) {
    switch (g) {
      case MuscleGroup.chest: return l10n.chest;
      case MuscleGroup.back: return l10n.back;
      case MuscleGroup.shoulders: return l10n.shoulders;
      case MuscleGroup.biceps: return l10n.biceps;
      case MuscleGroup.triceps: return l10n.triceps;
      case MuscleGroup.forearms: return l10n.forearms;
      case MuscleGroup.abs: return l10n.abs;
      case MuscleGroup.quads: return l10n.quads;
      case MuscleGroup.hamstrings: return l10n.hamstrings;
      case MuscleGroup.glutes: return l10n.glutes;
      case MuscleGroup.calves: return l10n.calves;
      case MuscleGroup.cardio: return l10n.cardio;
      case MuscleGroup.fullBody: return l10n.fullBody;
    }
  }

  Color _muscleColor(MuscleGroup g) {
    switch (g) {
      case MuscleGroup.chest:
        return AppColors.chest;
      case MuscleGroup.back:
        return AppColors.back;
      case MuscleGroup.shoulders:
        return AppColors.shoulders;
      case MuscleGroup.biceps:
        return AppColors.biceps;
      case MuscleGroup.triceps:
        return AppColors.triceps;
      case MuscleGroup.forearms:
        return AppColors.forearms;
      case MuscleGroup.abs:
        return AppColors.abs;
      case MuscleGroup.quads:
        return AppColors.quads;
      case MuscleGroup.hamstrings:
        return AppColors.hamstrings;
      case MuscleGroup.glutes:
        return AppColors.glutes;
      case MuscleGroup.calves:
        return AppColors.calves;
      case MuscleGroup.cardio:
        return AppColors.cardio;
      case MuscleGroup.fullBody:
        return AppColors.primary;
    }
  }

  String _equipmentLabel(Equipment e) {
    switch (e) {
      case Equipment.barbell:
        return 'Barbell';
      case Equipment.dumbbell:
        return 'Dumbbell';
      case Equipment.machine:
        return 'Machine';
      case Equipment.cable:
        return 'Cable';
      case Equipment.bodyweight:
        return 'Bodyweight';
      case Equipment.resistanceBand:
        return 'Resistance Band';
      case Equipment.kettlebell:
        return 'Kettlebell';
      case Equipment.ezBar:
        return 'EZ Bar';
      case Equipment.trapBar:
        return 'Trap Bar';
      case Equipment.smithMachine:
        return 'Smith Machine';
      case Equipment.cardioMachine:
        return 'Cardio Machine';
      case Equipment.none:
        return 'No Equipment';
    }
  }

  IconData _equipmentIcon(Equipment e) {
    switch (e) {
      case Equipment.barbell:
        return Icons.sports_gymnastics;
      case Equipment.dumbbell:
        return Icons.fitness_center_rounded;
      case Equipment.machine:
        return Icons.precision_manufacturing_rounded;
      case Equipment.cable:
        return Icons.cable_rounded;
      case Equipment.bodyweight:
        return Icons.accessibility_new_rounded;
      case Equipment.resistanceBand:
        return Icons.radio_button_unchecked_rounded;
      case Equipment.kettlebell:
        return Icons.sports_martial_arts_rounded;
      case Equipment.ezBar:
        return Icons.horizontal_rule_rounded;
      case Equipment.trapBar:
        return Icons.change_history_rounded;
      case Equipment.smithMachine:
        return Icons.grid_on_rounded;
      case Equipment.cardioMachine:
        return Icons.directions_run_rounded;
      case Equipment.none:
        return Icons.do_not_disturb_alt_rounded;
    }
  }

  String _goalLabel(_BuilderGoal g) {
    switch (g) {
      case _BuilderGoal.strength:
        return 'Strength';
      case _BuilderGoal.hypertrophy:
        return 'Hypertrophy';
      case _BuilderGoal.endurance:
        return 'Endurance';
      case _BuilderGoal.cardio:
        return 'Cardio';
    }
  }

  String _goalSubtitle(_BuilderGoal g) {
    switch (g) {
      case _BuilderGoal.strength:
        return 'Build maximum force output with heavy compound lifts';
      case _BuilderGoal.hypertrophy:
        return 'Maximise muscle size with moderate volume and intensity';
      case _BuilderGoal.endurance:
        return 'Improve stamina and muscular endurance over time';
      case _BuilderGoal.cardio:
        return 'Boost cardiovascular fitness and burn calories';
    }
  }

  IconData _goalIcon(_BuilderGoal g) {
    switch (g) {
      case _BuilderGoal.strength:
        return Icons.bolt_rounded;
      case _BuilderGoal.hypertrophy:
        return Icons.fitness_center_rounded;
      case _BuilderGoal.endurance:
        return Icons.loop_rounded;
      case _BuilderGoal.cardio:
        return Icons.directions_run_rounded;
    }
  }

  Color _goalColor(_BuilderGoal g) {
    switch (g) {
      case _BuilderGoal.strength:
        return AppColors.accent;
      case _BuilderGoal.hypertrophy:
        return AppColors.primary;
      case _BuilderGoal.endurance:
        return AppColors.secondary;
      case _BuilderGoal.cardio:
        return AppColors.cardio;
    }
  }

  String _difficultyLabel(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
    }
  }

  String _difficultySubtitle(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:
        return 'New to training or returning after a long break';
      case DifficultyLevel.intermediate:
        return '6+ months of consistent training experience';
      case DifficultyLevel.advanced:
        return '2+ years of structured training experience';
      case DifficultyLevel.expert:
        return 'Competitive athlete or trainer with 4+ years';
    }
  }

  String _difficultyEmoji(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:
        return '🌱';
      case DifficultyLevel.intermediate:
        return '💪';
      case DifficultyLevel.advanced:
        return '🔥';
      case DifficultyLevel.expert:
        return '⚡';
    }
  }

  Color _difficultyColor(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner:
        return AppColors.success;
      case DifficultyLevel.intermediate:
        return AppColors.accentYellow;
      case DifficultyLevel.advanced:
        return AppColors.accentOrange;
      case DifficultyLevel.expert:
        return AppColors.accent;
    }
  }

  // ---------------------------------------------------------------------------
  // Program generation
  // ---------------------------------------------------------------------------

  List<_GeneratedDay> _generateProgram(List<ExerciseEntity> allExercises) {
    final muscles = _selectedMuscles.isEmpty
        ? MuscleGroup.values.toSet()
        : _selectedMuscles;

    var pool = allExercises.where((e) {
      final muscleMatch = muscles.contains(e.primaryMuscle) ||
          e.secondaryMuscles.any(muscles.contains);
      final equipmentMatch = _selectedEquipment.isEmpty ||
          _selectedEquipment.contains(e.equipment);
      return muscleMatch && equipmentMatch;
    }).toList();

    // Sort by proximity to selected difficulty
    final diffOrder = DifficultyLevel.values;
    final targetIdx = diffOrder.indexOf(_difficulty);
    pool.sort((a, b) {
      final distA = (diffOrder.indexOf(a.difficulty) - targetIdx).abs();
      final distB = (diffOrder.indexOf(b.difficulty) - targetIdx).abs();
      return distA.compareTo(distB);
    });

    // Determine number of days
    final muscleCount = muscles.length;
    final int dayCount;
    if (muscleCount <= 3) {
      dayCount = 3;
    } else if (muscleCount <= 6) {
      dayCount = 4;
    } else {
      dayCount = 5;
    }

    // Group muscles into days
    final muscleList = muscles.toList();
    final List<List<MuscleGroup>> dayMuscles =
        List.generate(dayCount, (_) => []);
    for (int i = 0; i < muscleList.length; i++) {
      dayMuscles[i % dayCount].add(muscleList[i]);
    }

    // Assign exercises
    const maxExPerDay = 6;
    return List.generate(dayCount, (i) {
      final targets = dayMuscles[i];
      final dayExercises = pool.where((e) {
        return targets.isEmpty ||
            targets.contains(e.primaryMuscle) ||
            e.secondaryMuscles.any(targets.contains);
      }).take(maxExPerDay).toList();

      final label = targets.map(_muscleLabel).take(2).join(' & ');
      return _GeneratedDay(
        name: 'Day ${i + 1}${label.isNotEmpty ? ' – $label' : ''}',
        targetMuscles: targets,
        exercises: dayExercises,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  bool get _canProceed {
    switch (_step) {
      case 0:
        return true; // muscles optional
      case 3:
        return _selectedEquipment.isNotEmpty;
      default:
        return true;
    }
  }

  void _next(List<ExerciseEntity> exercises) {
    if (!_canProceed) return;
    HapticFeedback.lightImpact();
    if (_step == 3) {
      setState(() {
        _generatedDays = _generateProgram(exercises);
        _step = 4;
      });
    } else {
      setState(() => _step++);
    }
  }

  void _back() {
    HapticFeedback.lightImpact();
    if (_step == 0) {
      context.pop();
    } else {
      setState(() => _step--);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercisesAsync = ref.watch(allExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.smartProgramBuilder),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: exercisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (exercises) => _buildContent(context, exercises),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<ExerciseEntity> exercises) {
    return Column(
      children: [
        if (_step < 4) _ProgressBar(step: _step, total: 4),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: KeyedSubtree(
              key: ValueKey(_step),
              child: _buildStep(context, exercises),
            ),
          ),
        ),
        if (_step < 4)
          _BottomNav(
            step: _step,
            canProceed: _canProceed,
            onNext: () => _next(exercises),
            onBack: _back,
          ),
      ],
    );
  }

  Widget _buildStep(BuildContext context, List<ExerciseEntity> exercises) {
    switch (_step) {
      case 0:
        return _buildMuscleStep(context);
      case 1:
        return _buildGoalStep(context);
      case 2:
        return _buildDifficultyStep(context);
      case 3:
        return _buildEquipmentStep(context);
      case 4:
        return _buildPreviewStep(context, exercises);
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // Step 0 – Muscles
  // ---------------------------------------------------------------------------

  Widget _buildMuscleStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.accessibility_new_rounded,
            iconColor: AppColors.primary,
            title: l10n.targetMusclesStep,
            subtitle: l10n.targetMusclesHint,
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MuscleGroup.values.map((muscle) {
              final isSelected = _selectedMuscles.contains(muscle);
              final color = _muscleColor(muscle);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _selectedMuscles.remove(muscle);
                    } else {
                      _selectedMuscles.add(muscle);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.18)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.3),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Icon(Icons.check_circle_rounded,
                              size: 14, color: color),
                        ),
                      Text(
                        _muscleLabelL10n(l10n, muscle),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isSelected
                              ? color
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedMuscles.isEmpty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(
                  'No selection = all muscles included',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 – Goal
  // ---------------------------------------------------------------------------

  Widget _buildGoalStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.track_changes_rounded,
            iconColor: AppColors.accentOrange,
            title: l10n.trainingGoalStep,
            subtitle: l10n.trainingGoalHint,
          ),
          const SizedBox(height: 20),
          ..._BuilderGoal.values.map((g) {
            final isSelected = _goal == g;
            final color = _goalColor(g);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _goal = g);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.12)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.25),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_goalIcon(g), color: color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _goalLabel(g),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? color : null,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _goalSubtitle(g),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            color: color, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 – Difficulty
  // ---------------------------------------------------------------------------

  Widget _buildDifficultyStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final levels = DifficultyLevel.values;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.signal_cellular_alt_rounded,
            iconColor: AppColors.secondary,
            title: l10n.experienceLevelStep,
            subtitle: l10n.experienceLevelHint,
          ),
          const SizedBox(height: 20),
          ...levels.map((d) {
            final isSelected = _difficulty == d;
            final color = _difficultyColor(d);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _difficulty = d);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.12)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? color
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.25),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            _difficultyEmoji(d),
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _difficultyLabel(d),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? color : null,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _difficultySubtitle(d),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded,
                            color: color, size: 22),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3 – Equipment
  // ---------------------------------------------------------------------------

  Widget _buildEquipmentStep(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.handyman_rounded,
            iconColor: AppColors.forearms,
            title: l10n.availableEquipmentStep,
            subtitle:
                'Select everything available to you. At least one required.',
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: Equipment.values.map((e) {
              final isSelected = _selectedEquipment.contains(e);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected && _selectedEquipment.length > 1) {
                      _selectedEquipment.remove(e);
                    } else if (!isSelected) {
                      _selectedEquipment.add(e);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.14)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.25),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _equipmentIcon(e),
                        size: 18,
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _equipmentLabel(e),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedEquipment.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Please select at least one equipment type',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 4 – Preview
  // ---------------------------------------------------------------------------

  Widget _buildPreviewStep(
      BuildContext context, List<ExerciseEntity> exercises) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_generatedDays.length}-Day Program',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${_goalLabel(_goal)} · ${_difficultyLabel(_difficulty)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _generatedDays.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                _DayPreviewCard(day: _generatedDays[i]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _back,
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Regenerate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    final l10n = AppLocalizations.of(context)!;
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.programSaved),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    context.pop();
                  },
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save to Programs'),
                  style: FilledButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step ${step + 1} of $total',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                _stepTitle(step),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (step + 1) / total,
              minHeight: 4,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(int s) {
    switch (s) {
      case 0:
        return 'Muscles';
      case 1:
        return 'Goal';
      case 2:
        return 'Level';
      case 3:
        return 'Equipment';
      default:
        return '';
    }
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.step,
    required this.canProceed,
    required this.onNext,
    required this.onBack,
  });

  final int step;
  final bool canProceed;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          if (step > 0) ...[
            OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(80, 48),
              ),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              onPressed: canProceed ? onNext : null,
              style: FilledButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(step == 3 ? 'Generate Program' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayPreviewCard extends StatelessWidget {
  const _DayPreviewCard({required this.day});

  final _GeneratedDay day;

  Color _muscleColor(MuscleGroup g) {
    switch (g) {
      case MuscleGroup.chest:
        return AppColors.chest;
      case MuscleGroup.back:
        return AppColors.back;
      case MuscleGroup.shoulders:
        return AppColors.shoulders;
      case MuscleGroup.biceps:
        return AppColors.biceps;
      case MuscleGroup.triceps:
        return AppColors.triceps;
      case MuscleGroup.forearms:
        return AppColors.forearms;
      case MuscleGroup.abs:
        return AppColors.abs;
      case MuscleGroup.quads:
        return AppColors.quads;
      case MuscleGroup.hamstrings:
        return AppColors.hamstrings;
      case MuscleGroup.glutes:
        return AppColors.glutes;
      case MuscleGroup.calves:
        return AppColors.calves;
      case MuscleGroup.cardio:
        return AppColors.cardio;
      case MuscleGroup.fullBody:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = day.targetMuscles.isNotEmpty
        ? _muscleColor(day.targetMuscles.first)
        : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    day.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                  ),
                ),
                Text(
                  '${day.exercises.length} exercises',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: primaryColor.withOpacity(0.7),
                      ),
                ),
              ],
            ),
          ),
          // Exercise list
          if (day.exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                'No exercises found for selected equipment',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else
            ...day.exercises.asMap().entries.map((entry) {
              final i = entry.key;
              final ex = entry.value;
              final exColor = _muscleColor(ex.primaryMuscle);
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: exColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color: exColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ex.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: exColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ex.equipment.name,
                            style: TextStyle(
                              color: exColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < day.exercises.length - 1)
                    Divider(
                      height: 1,
                      indent: 14,
                      endIndent: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.12),
                    ),
                ],
              );
            }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
