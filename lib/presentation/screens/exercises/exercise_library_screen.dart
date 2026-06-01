import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_error.dart';
import 'package:level_bot/presentation/widgets/common/app_loading.dart';
import 'package:level_bot/presentation/widgets/exercise/exercise_card.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() =>
      _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState
    extends ConsumerState<ExerciseLibraryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = ref.watch(filteredExercisesProvider);
    final muscleFilter = ref.watch(exerciseFilterMuscleProvider);
    final equipmentFilter = ref.watch(exerciseFilterEquipmentProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => ref
                  .read(exerciseSearchQueryProvider.notifier)
                  .state = v,
              decoration: InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(exerciseSearchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _FilterBar(
            muscleFilter: muscleFilter,
            equipmentFilter: equipmentFilter,
          ),
          Expanded(
            child: filteredExercises.when(
              loading: () => const AppLoading(),
              error: (e, _) => AppError(message: e.toString()),
              data: (exercises) {
                if (exercises.isEmpty) {
                  return const Center(
                    child: Text('No exercises found'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ExerciseCard(
                        exercise: exercises[index],
                        onTap: () => context.push(
                          '/exercises/${exercises[index].id}',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar({
    required this.muscleFilter,
    required this.equipmentFilter,
  });

  final MuscleGroup? muscleFilter;
  final Equipment? equipmentFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _FilterChip(
            label: 'All Muscles',
            isSelected: muscleFilter == null,
            onTap: () => ref
                .read(exerciseFilterMuscleProvider.notifier)
                .state = null,
          ),
          ...MuscleGroup.values.map((group) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: _FilterChip(
                  label: _muscleLabel(group),
                  isSelected: muscleFilter == group,
                  color: _muscleColor(group),
                  onTap: () => ref
                      .read(exerciseFilterMuscleProvider.notifier)
                      .state = group,
                ),
              )),
        ],
      ),
    );
  }

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
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? c.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? c : context.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? c : context.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
