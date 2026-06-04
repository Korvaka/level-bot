import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/utils/formatters.dart';
import 'package:level_bot/domain/entities/workout_session_entity.dart';
import 'package:level_bot/domain/entities/workout_set_entity.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/workout_provider.dart';
import 'package:level_bot/presentation/widgets/workout/rest_timer.dart';
import 'package:level_bot/presentation/widgets/workout/set_row.dart';
import 'package:uuid/uuid.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final workoutState = ref.watch(activeWorkoutProvider);

    if (!workoutState.isActive) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.startWorkout),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: _NoActiveWorkout(),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) { if (!didPop) _confirmCancel(context); },
      child: Scaffold(
        appBar: _buildAppBar(context, workoutState),
        body: Column(
          children: [
            if (workoutState.isRestTimerRunning)
              RestTimer(
                seconds: workoutState.restTimerSeconds,
                totalSeconds: workoutState.totalRestSeconds,
                onSkip: () => ref
                    .read(activeWorkoutProvider.notifier)
                    .stopRestTimer(),
                onAddTime: () => ref
                    .read(activeWorkoutProvider.notifier)
                    .addRestTime(),
              ),
            Expanded(
              child: workoutState.session?.exercises.isEmpty == true
                  ? _EmptyWorkout(onAddExercise: () => _showAddExercise(context))
                  : _ExerciseList(
                      session: workoutState.session!,
                      onAddExercise: () => _showAddExercise(context),
                    ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(context, workoutState),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ActiveWorkoutState state) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => _confirmCancel(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.session?.workoutDayName ?? 'Workout',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          Text(
            Formatters.formatTimer(state.elapsedSeconds),
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notes_outlined),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ActiveWorkoutState state) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: context.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => _showAddExercise(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.addExercise),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () => _finishWorkout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      l10n.finishWorkout,
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishWorkout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final error =
        await ref.read(activeWorkoutProvider.notifier).completeWorkout();
    if (!context.mounted) return;
    if (error != null) {
      context.showErrorSnackBar(error);
    } else {
      context.showSnackBar(l10n.workoutCompleted);
      context.pop();
    }
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelWorkout),
        content: Text(l10n.cancelWorkoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.continueWorkout),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.cancelWorkout,
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(activeWorkoutProvider.notifier).cancelWorkout();
      if (context.mounted) context.pop();
    }
  }

  void _showAddExercise(BuildContext context) {
    // TODO: Show exercise picker bottom sheet
  }
}

class _ExerciseList extends ConsumerWidget {
  const _ExerciseList({
    required this.session,
    required this.onAddExercise,
  });

  final WorkoutSessionEntity session;
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: session.exercises.length,
      itemBuilder: (context, index) {
        final exercise = session.exercises[index];
        return _ExerciseCard(
          exercise: exercise,
          sessionId: session.id,
        );
      },
    );
  }
}

class _ExerciseCard extends ConsumerStatefulWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.sessionId,
  });

  final SessionExercise exercise;
  final String sessionId;

  @override
  ConsumerState<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<_ExerciseCard> {
  final _uuid = const Uuid();

  void _addSet() {
    final lastSet = widget.exercise.sets.isNotEmpty
        ? widget.exercise.sets.last
        : null;

    final newSet = WorkoutSetEntity(
      id: _uuid.v4(),
      setNumber: widget.exercise.sets.length + 1,
      weight: lastSet?.weight,
      reps: lastSet?.reps,
      restSeconds: lastSet?.restSeconds ?? 90,
    );

    ref.read(activeWorkoutProvider.notifier).addSet(
          exerciseId: widget.exercise.id,
          workoutSetEntity: newSet,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.exercise.exerciseName,
                    style: context.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz_rounded),
                  onPressed: () {},
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SizedBox(width: 32),
                Expanded(
                  flex: 3,
                  child: Text(
                    'WEIGHT',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'REPS',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'RPE',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ...widget.exercise.sets.map((set) => SetRow(
                set: set,
                exerciseId: widget.exercise.id,
                onCompleted: (completed) {
                  ref.read(activeWorkoutProvider.notifier).updateSet(
                        exerciseId: widget.exercise.id,
                        setId: set.id,
                        isCompleted: completed,
                      );
                  if (completed && set.restSeconds != null) {
                    ref
                        .read(activeWorkoutProvider.notifier)
                        .startRestTimer(set.restSeconds!);
                  }
                },
                onRemove: () {
                  ref.read(activeWorkoutProvider.notifier).removeSet(
                        exerciseId: widget.exercise.id,
                        setId: set.id,
                      );
                },
                onWeightChanged: (w) {
                  ref.read(activeWorkoutProvider.notifier).updateSet(
                        exerciseId: widget.exercise.id,
                        setId: set.id,
                        weight: w,
                      );
                },
                onRepsChanged: (r) {
                  ref.read(activeWorkoutProvider.notifier).updateSet(
                        exerciseId: widget.exercise.id,
                        setId: set.id,
                        reps: r,
                      );
                },
              )),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Set'),
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoActiveWorkout extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.fitness_center_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            Text('Ready to train?', style: context.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Start a new workout or choose a program',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                final currentUser = ref.read(currentUserProvider);
                if (currentUser == null) return;
                ref
                    .read(activeWorkoutProvider.notifier)
                    .startWorkout(userId: currentUser.id);
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Empty Workout'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyWorkout extends StatelessWidget {
  const _EmptyWorkout({required this.onAddExercise});
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 64,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises added',
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add exercises to start tracking',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onAddExercise,
            icon: const Icon(Icons.add_rounded),
            label: Text(AppLocalizations.of(context)!.addExercise),
          ),
        ],
      ),
    );
  }
}
