import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_text_field.dart';
import 'package:uuid/uuid.dart';

class CreateExerciseScreen extends ConsumerStatefulWidget {
  const CreateExerciseScreen({super.key});

  @override
  ConsumerState<CreateExerciseScreen> createState() =>
      _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends ConsumerState<CreateExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uuid = const Uuid();

  MuscleGroup _primaryMuscle = MuscleGroup.chest;
  final Set<MuscleGroup> _secondaryMuscles = {};
  Equipment _equipment = Equipment.barbell;
  ExerciseCategory _category = ExerciseCategory.compound;
  DifficultyLevel _difficulty = DifficultyLevel.intermediate;
  final List<TextEditingController> _instructionControllers = [
    TextEditingController(),
  ];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final c in _instructionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createExercise),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionHeader(title: l10n.basicInfo),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nameController,
              label: l10n.exerciseNameLabel,
              hint: l10n.exerciseNameHint,
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _descriptionController,
              label: l10n.description,
              hint: l10n.descriptionHint,
              maxLines: 3,
              minLines: 2,
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.primaryMuscle),
            const SizedBox(height: 12),
            _MuscleSelector(
              selected: {_primaryMuscle},
              singleSelect: true,
              onChanged: (groups) =>
                  setState(() => _primaryMuscle = groups.first),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.secondaryMuscles),
            const SizedBox(height: 12),
            _MuscleSelector(
              selected: _secondaryMuscles,
              singleSelect: false,
              excluded: {_primaryMuscle},
              onChanged: (groups) =>
                  setState(() {
                    _secondaryMuscles.clear();
                    _secondaryMuscles.addAll(groups);
                  }),
            ),
            const SizedBox(height: 24),
            _SectionHeader(title: l10n.equipment),
            const SizedBox(height: 12),
            _EquipmentSelector(
              selected: _equipment,
              onChanged: (e) => setState(() => _equipment = e),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: l10n.category),
                      const SizedBox(height: 12),
                      _CategorySelector(
                        selected: _category,
                        onChanged: (c) => setState(() => _category = c),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(title: l10n.difficulty),
                      const SizedBox(height: 12),
                      _DifficultySelector(
                        selected: _difficulty,
                        onChanged: (d) => setState(() => _difficulty = d),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _SectionHeader(title: l10n.instructions),
                const Spacer(),
                TextButton.icon(
                  onPressed: _addInstruction,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Step'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._instructionControllers.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(top: 12, right: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: AppTextField(
                            controller: entry.value,
                            hint: 'Step ${entry.key + 1}...',
                            maxLines: 2,
                            minLines: 1,
                          ),
                        ),
                        if (_instructionControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                size: 20),
                            color: Colors.red,
                            onPressed: () => _removeInstruction(entry.key),
                          ),
                      ],
                    ),
                  ),
                ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _addInstruction() {
    setState(() => _instructionControllers.add(TextEditingController()));
  }

  void _removeInstruction(int index) {
    setState(() {
      _instructionControllers[index].dispose();
      _instructionControllers.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() => _isSaving = true);

    final instructions = _instructionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final exercise = ExerciseEntity(
      id: _uuid.v4(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      primaryMuscle: _primaryMuscle,
      secondaryMuscles: _secondaryMuscles.toList(),
      equipment: _equipment,
      category: _category,
      difficulty: _difficulty,
      instructions: instructions,
      isCustom: true,
      createdBy: currentUser.id,
    );

    final error = await ref
        .read(exerciseNotifierProvider.notifier)
        .createCustomExercise(exercise);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      context.showErrorSnackBar(error);
    } else {
      context.showSnackBar(AppLocalizations.of(context)!.exerciseCreatedSuccess);
      context.pop();
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: context.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _MuscleSelector extends StatelessWidget {
  const _MuscleSelector({
    required this.selected,
    required this.singleSelect,
    required this.onChanged,
    this.excluded = const {},
  });

  final Set<MuscleGroup> selected;
  final bool singleSelect;
  final void Function(Set<MuscleGroup>) onChanged;
  final Set<MuscleGroup> excluded;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: MuscleGroup.values
          .where((m) => !excluded.contains(m))
          .map((m) {
        final isSelected = selected.contains(m);
        final color = _muscleColor(m);
        return GestureDetector(
          onTap: () {
            final newSet = Set<MuscleGroup>.from(selected);
            if (singleSelect) {
              newSet.clear();
              newSet.add(m);
            } else {
              if (isSelected) {
                newSet.remove(m);
              } else {
                newSet.add(m);
              }
            }
            onChanged(newSet);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? color
                    : context.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              _muscleLabel(l10n, m),
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? color
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _muscleLabel(AppLocalizations l10n, MuscleGroup m) {
    switch (m) {
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
}

class _EquipmentSelector extends StatelessWidget {
  const _EquipmentSelector({
    required this.selected,
    required this.onChanged,
  });

  final Equipment selected;
  final void Function(Equipment) onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: Equipment.values.map((e) {
        final isSelected = selected == e;
        return GestureDetector(
          onTap: () => onChanged(e),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : context.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              _equipmentLabel(e),
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _equipmentLabel(Equipment e) {
    switch (e) {
      case Equipment.barbell: return 'Barbell';
      case Equipment.dumbbell: return 'Dumbbell';
      case Equipment.machine: return 'Machine';
      case Equipment.cable: return 'Cable';
      case Equipment.bodyweight: return 'Bodyweight';
      case Equipment.resistanceBand: return 'Band';
      case Equipment.kettlebell: return 'Kettlebell';
      case Equipment.ezBar: return 'EZ Bar';
      case Equipment.trapBar: return 'Trap Bar';
      case Equipment.smithMachine: return 'Smith Machine';
      case Equipment.cardioMachine: return 'Cardio Machine';
      case Equipment.none: return 'None';
    }
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.selected,
    required this.onChanged,
  });

  final ExerciseCategory selected;
  final void Function(ExerciseCategory) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ExerciseCategory.values
          .map((c) => RadioListTile<ExerciseCategory>(
                value: c,
                groupValue: selected,
                onChanged: (v) => v != null ? onChanged(v) : null,
                title: Text(_categoryLabel(c),
                    style: const TextStyle(fontSize: 13)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ))
          .toList(),
    );
  }

  String _categoryLabel(ExerciseCategory c) {
    switch (c) {
      case ExerciseCategory.compound: return 'Compound';
      case ExerciseCategory.isolation: return 'Isolation';
      case ExerciseCategory.cardio: return 'Cardio';
      case ExerciseCategory.stretching: return 'Stretching';
      case ExerciseCategory.plyometric: return 'Plyometric';
    }
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({
    required this.selected,
    required this.onChanged,
  });

  final DifficultyLevel selected;
  final void Function(DifficultyLevel) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: DifficultyLevel.values
          .map((d) => RadioListTile<DifficultyLevel>(
                value: d,
                groupValue: selected,
                onChanged: (v) => v != null ? onChanged(v) : null,
                title: Text(_diffLabel(d),
                    style: const TextStyle(fontSize: 13)),
                dense: true,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ))
          .toList(),
    );
  }

  String _diffLabel(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner: return 'Beginner';
      case DifficultyLevel.intermediate: return 'Intermediate';
      case DifficultyLevel.advanced: return 'Advanced';
      case DifficultyLevel.expert: return 'Expert';
    }
  }
}
