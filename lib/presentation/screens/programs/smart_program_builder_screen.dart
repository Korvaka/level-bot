import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';

enum _WorkoutGoal { strength, hypertrophy, endurance, cardio }

class SmartProgramBuilderScreen extends ConsumerStatefulWidget {
  const SmartProgramBuilderScreen({super.key});

  @override
  ConsumerState<SmartProgramBuilderScreen> createState() =>
      _SmartProgramBuilderScreenState();
}

class _SmartProgramBuilderScreenState
    extends ConsumerState<SmartProgramBuilderScreen> {
  int _step = 0;
  final Set<MuscleGroup> _selectedMuscles = {};
  _WorkoutGoal _goal = _WorkoutGoal.hypertrophy;
  DifficultyLevel _level = DifficultyLevel.intermediate;
  final Set<Equipment> _equipment = {Equipment.barbell, Equipment.dumbbell, Equipment.bodyweight};

  static const _steps = ['Muscles', 'Goal', 'Level', 'Equipment'];

  void _nextStep() {
    if (_step < 3) setState(() => _step++);
  }

  void _prevStep() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Program Builder'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step, steps: _steps),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStep(context),
            ),
          ),
          _BottomNav(
            step: _step,
            totalSteps: _steps.length,
            canProceed: _canProceed(),
            onBack: _prevStep,
            onNext: _step == 3 ? () => _generateAndSave(context) : _nextStep,
            nextLabel: _step == 3 ? 'Generate Program' : 'Next',
          ),
        ],
      ),
    );
  }

  bool _canProceed() {
    switch (_step) {
      case 0: return _selectedMuscles.isNotEmpty;
      case 3: return _equipment.isNotEmpty;
      default: return true;
    }
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0: return _MuscleSelectionStep(
        key: const ValueKey(0),
        selected: _selectedMuscles,
        onToggle: (m) {
          HapticFeedback.lightImpact();
          setState(() {
            if (_selectedMuscles.contains(m)) {
              _selectedMuscles.remove(m);
            } else {
              _selectedMuscles.add(m);
            }
          });
        },
      );
      case 1: return _GoalSelectionStep(
        key: const ValueKey(1),
        selected: _goal,
        onSelect: (g) => setState(() => _goal = g),
      );
      case 2: return _LevelSelectionStep(
        key: const ValueKey(2),
        selected: _level,
        onSelect: (l) => setState(() => _level = l),
      );
      case 3: return _EquipmentSelectionStep(
        key: const ValueKey(3),
        selected: _equipment,
        onToggle: (e) {
          setState(() {
            if (_equipment.contains(e)) {
              _equipment.remove(e);
            } else {
              _equipment.add(e);
            }
          });
        },
      );
      default: return const SizedBox.shrink();
    }
  }

  void _generateAndSave(BuildContext context) {
    final exercises = ref.read(allExercisesProvider).value ?? [];
    final filtered = exercises.where((e) =>
      (_selectedMuscles.contains(e.primaryMuscle) ||
       e.secondaryMuscles.any(_selectedMuscles.contains)) &&
      (_equipment.contains(e.equipment) || e.equipment == Equipment.bodyweight)
    ).toList();

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching exercises found. Try different filters.')),
      );
      return;
    }

    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Program generated with ${filtered.length} exercises!'),
        backgroundColor: AppColors.success,
      ),
    );
    context.pop();
  }
}

// ---------------------------------------------------------------------------
// Step 1: Muscle Selection
// ---------------------------------------------------------------------------
class _MuscleSelectionStep extends StatelessWidget {
  const _MuscleSelectionStep({
    super.key,
    required this.selected,
    required this.onToggle,
  });
  final Set<MuscleGroup> selected;
  final void Function(MuscleGroup) onToggle;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Which muscles do you want to train?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Select one or more muscle groups',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: MuscleGroup.values
                .where((m) => m != MuscleGroup.cardio && m != MuscleGroup.fullBody)
                .map((m) {
              final isSelected = selected.contains(m);
              final color = _muscleColor(m);
              return GestureDetector(
                onTap: () => onToggle(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _muscleLabel(m),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? color : null,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: Goal Selection
// ---------------------------------------------------------------------------
class _GoalSelectionStep extends StatelessWidget {
  const _GoalSelectionStep({super.key, required this.selected, required this.onSelect});
  final _WorkoutGoal selected;
  final void Function(_WorkoutGoal) onSelect;

  @override
  Widget build(BuildContext context) {
    final goals = [
      (_WorkoutGoal.strength, '💪', 'Strength', 'Low reps, heavy weight\nBuild maximum power', AppColors.accent),
      (_WorkoutGoal.hypertrophy, '📈', 'Hypertrophy', 'Moderate reps, moderate weight\nMaximize muscle growth', AppColors.primary),
      (_WorkoutGoal.endurance, '🏃', 'Endurance', 'High reps, lighter weight\nBuild stamina', AppColors.secondary),
      (_WorkoutGoal.cardio, '❤️', 'Cardio', 'Cardio-focused exercises\nImprove cardiovascular health', AppColors.cardio),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your main goal?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          ...goals.map((g) {
            final isSelected = selected == g.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onSelect(g.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? g.$5.withOpacity(0.12) : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? g.$5 : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(color: g.$5.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4)),
                    ] : [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(g.$2, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.$3, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(g.$4, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: g.$5),
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
}

// ---------------------------------------------------------------------------
// Step 3: Level Selection
// ---------------------------------------------------------------------------
class _LevelSelectionStep extends StatelessWidget {
  const _LevelSelectionStep({super.key, required this.selected, required this.onSelect});
  final DifficultyLevel selected;
  final void Function(DifficultyLevel) onSelect;

  @override
  Widget build(BuildContext context) {
    final levels = [
      (DifficultyLevel.beginner, '🌱', 'Beginner', 'New to training\n0-1 year of experience', Colors.green),
      (DifficultyLevel.intermediate, '🔥', 'Intermediate', 'Regular training\n1-3 years of experience', Colors.orange),
      (DifficultyLevel.advanced, '⚡', 'Advanced', 'Experienced athlete\n3+ years of experience', AppColors.primary),
      (DifficultyLevel.expert, '🏆', 'Expert', 'Elite level\nProfessional/competitive', AppColors.accentYellow),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What is your experience level?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          ...levels.map((l) {
            final isSelected = selected == l.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onSelect(l.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected ? l.$5.withOpacity(0.12) : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? l.$5 : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(l.$2, style: const TextStyle(fontSize: 32)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.$3, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(l.$4, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: l.$5),
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
}

// ---------------------------------------------------------------------------
// Step 4: Equipment Selection
// ---------------------------------------------------------------------------
class _EquipmentSelectionStep extends StatelessWidget {
  const _EquipmentSelectionStep({super.key, required this.selected, required this.onToggle});
  final Set<Equipment> selected;
  final void Function(Equipment) onToggle;

  @override
  Widget build(BuildContext context) {
    final equipmentList = [
      (Equipment.barbell, '🏋️', 'Barbell'),
      (Equipment.dumbbell, '💪', 'Dumbbell'),
      (Equipment.machine, '⚙️', 'Machine'),
      (Equipment.cable, '🔗', 'Cable'),
      (Equipment.kettlebell, '🔔', 'Kettlebell'),
      (Equipment.bodyweight, '🤸', 'Bodyweight'),
      (Equipment.resistanceBand, '🎗️', 'Resistance Band'),
      (Equipment.none, '🙌', 'No Equipment'),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What equipment do you have?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: equipmentList.map((e) {
              final isSelected = selected.contains(e.$1);
              return GestureDetector(
                onTap: () => onToggle(e.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.$2, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        e.$3,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          color: isSelected ? AppColors.primary : null,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep, required this.steps});
  final int currentStep;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDone || isActive
                          ? AppColors.primary
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (i < steps.length - 1) const SizedBox(width: 4),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.step,
    required this.totalSteps,
    required this.canProceed,
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
  });
  final int step;
  final int totalSteps;
  final bool canProceed;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            if (step > 0)
              OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back'),
              ),
            if (step > 0) const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: canProceed ? onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  nextLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
Color _muscleColor(MuscleGroup m) {
  switch (m) {
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

String _muscleLabel(MuscleGroup m) {
  switch (m) {
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
