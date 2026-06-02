import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/entities/program_entity.dart';
import 'package:level_bot/domain/entities/workout_set_entity.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';
import 'package:level_bot/presentation/providers/program_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_button.dart';
import 'package:level_bot/presentation/widgets/common/app_text_field.dart';
import 'package:uuid/uuid.dart';

class CreateProgramScreen extends ConsumerStatefulWidget {
  const CreateProgramScreen({super.key});

  @override
  ConsumerState<CreateProgramScreen> createState() =>
      _CreateProgramScreenState();
}

class _CreateProgramScreenState extends ConsumerState<CreateProgramScreen> {
  final _uuid = const Uuid();
  int _currentStep = 0;

  // Step 1 - Basic info
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ProgramGoal _selectedGoal = ProgramGoal.general;
  ProgramDuration _selectedDuration = ProgramDuration.weeks8;
  DifficultyLevel _selectedDifficulty = DifficultyLevel.intermediate;
  int _daysPerWeek = 3;
  bool _isPublic = false;

  // Step 2 - Workout days
  final List<WorkoutDay> _days = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addDay() {
    setState(() {
      _days.add(WorkoutDay(
        id: _uuid.v4(),
        name: 'Day ${_days.length + 1}',
        order: _days.length,
        exercises: const [],
      ));
    });
  }

  Future<void> _createProgram() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;
    if (_nameController.text.trim().isEmpty) {
      context.showErrorSnackBar('Program name is required');
      return;
    }

    setState(() => _isLoading = true);

    final program = ProgramEntity(
      id: '',
      userId: currentUser.id,
      name: _nameController.text.trim(),
      days: _days,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      goal: _selectedGoal,
      duration: _selectedDuration,
      daysPerWeek: _daysPerWeek,
      difficulty: _selectedDifficulty,
      isPublic: _isPublic,
      createdAt: DateTime.now(),
    );

    final error = await ref
        .read(programsNotifierProvider.notifier)
        .createProgram(program);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      context.showErrorSnackBar(error);
    } else {
      context.showSnackBar('Program created successfully!');
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Program'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 1) {
            setState(() => _currentStep++);
          } else {
            _createProgram();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: _currentStep == 1 ? 'Create Program' : 'Next',
                    onPressed: details.onStepContinue ?? () {},
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: _currentStep == 0 ? 'Cancel' : 'Back',
                    onPressed: details.onStepCancel ?? () {},
                    variant: AppButtonVariant.outlined,
                  ),
                ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Program Info'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: _buildStep1(),
          ),
          Step(
            title: const Text('Workout Days'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: _buildStep2(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _nameController,
          label: 'Program Name',
          hint: 'e.g. Push Pull Legs',
          prefixIcon: Icons.view_list_rounded,
        ),
        const SizedBox(height: 16),
        AppTextField(
          controller: _descriptionController,
          label: 'Description (optional)',
          hint: 'Describe your program...',
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        Text('Goal', style: context.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ProgramGoal.values.map((goal) {
            return ChoiceChip(
              label: Text(_formatGoal(goal)),
              selected: _selectedGoal == goal,
              onSelected: (_) => setState(() => _selectedGoal = goal),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Difficulty', style: context.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<DifficultyLevel>(
                    value: _selectedDifficulty,
                    decoration: const InputDecoration(
                      isDense: true,
                    ),
                    items: DifficultyLevel.values
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(_formatDifficulty(d)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedDifficulty = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Duration', style: context.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ProgramDuration>(
                    value: _selectedDuration,
                    decoration: const InputDecoration(isDense: true),
                    items: ProgramDuration.values
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(_formatDuration(d)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedDuration = v!),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Days per week', style: context.textTheme.titleSmall),
        Slider(
          value: _daysPerWeek.toDouble(),
          min: 1,
          max: 7,
          divisions: 6,
          label: '$_daysPerWeek days',
          onChanged: (v) => setState(() => _daysPerWeek = v.toInt()),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Make Public'),
          subtitle: const Text('Others can find and use your program'),
          value: _isPublic,
          onChanged: (v) => setState(() => _isPublic = v),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_days.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No workout days yet',
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        else
          ..._days.asMap().entries.map((entry) =>
              _DayCard(
                day: entry.value,
                index: entry.key,
                onRemove: () => setState(() => _days.removeAt(entry.key)),
              )),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _addDay,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Workout Day'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  String _formatGoal(ProgramGoal g) {
    switch (g) {
      case ProgramGoal.strength: return 'Strength';
      case ProgramGoal.hypertrophy: return 'Hypertrophy';
      case ProgramGoal.endurance: return 'Endurance';
      case ProgramGoal.powerlifting: return 'Powerlifting';
      case ProgramGoal.weightLoss: return 'Weight Loss';
      case ProgramGoal.athletic: return 'Athletic';
      case ProgramGoal.general: return 'General';
    }
  }

  String _formatDifficulty(DifficultyLevel d) {
    switch (d) {
      case DifficultyLevel.beginner: return 'Beginner';
      case DifficultyLevel.intermediate: return 'Intermediate';
      case DifficultyLevel.advanced: return 'Advanced';
      case DifficultyLevel.expert: return 'Expert';
    }
  }

  String _formatDuration(ProgramDuration d) {
    switch (d) {
      case ProgramDuration.weeks4: return '4 weeks';
      case ProgramDuration.weeks6: return '6 weeks';
      case ProgramDuration.weeks8: return '8 weeks';
      case ProgramDuration.weeks12: return '12 weeks';
      case ProgramDuration.weeks16: return '16 weeks';
      case ProgramDuration.ongoing: return 'Ongoing';
    }
  }
}

class _DayCard extends StatelessWidget {
  const _DayCard({
    required this.day,
    required this.index,
    required this.onRemove,
  });

  final WorkoutDay day;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'D${index + 1}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.name, style: context.textTheme.titleSmall),
                Text(
                  '${day.exercises.length} exercises',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
            onPressed: onRemove,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}
