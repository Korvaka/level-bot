import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/router/app_router.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/utils/formatters.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/entities/program_entity.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/program_provider.dart';
import 'package:level_bot/presentation/providers/workout_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_error.dart';
import 'package:level_bot/presentation/widgets/common/app_loading.dart';

class ProgramDetailScreen extends ConsumerWidget {
  const ProgramDetailScreen({super.key, required this.programId});
  final String programId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(programByIdProvider(programId));

    return programAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppError(message: e.toString()),
      ),
      data: (program) => _ProgramDetailContent(program: program),
    );
  }
}

class _ProgramDetailContent extends ConsumerWidget {
  const _ProgramDetailContent({required this.program});
  final ProgramEntity program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isOwner = currentUser?.id == program.userId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, ref, isOwner),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStats(context),
                  const SizedBox(height: 24),
                  _buildDescription(context),
                  const SizedBox(height: 24),
                  _buildWorkoutDays(context, ref),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, ref, isOwner),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, bool isOwner) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => context.pop(),
      ),
      actions: [
        if (isOwner) ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return [
                PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: const Icon(Icons.copy_outlined),
                    title: Text(l10n.edit),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'archive',
                  child: ListTile(
                    leading: const Icon(Icons.archive_outlined),
                    title: Text(l10n.archive),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ];
            },
            onSelected: (value) async {
              switch (value) {
                case 'duplicate':
                  await _handleDuplicate(context, ref);
                case 'archive':
                  await _handleArchive(context, ref);
                case 'delete':
                  await _handleDelete(context, ref);
              }
            },
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          program.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark,
                AppColors.darkBackground,
              ],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.fitness_center_rounded,
              size: 80,
              color: Colors.white24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        _StatCard(
          label: l10n.daysLabel,
          value: '${program.daysPerWeek}x/week',
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: l10n.durationLabel,
          value: _formatDuration(program.duration),
          icon: Icons.schedule_outlined,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: l10n.levelLabel,
          value: _formatDifficulty(program.difficulty),
          icon: Icons.bar_chart_rounded,
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    if (program.description == null || program.description!.isEmpty) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.aboutLabel, style: context.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          program.description!,
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutDays(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Schedule',
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ...program.days.map((day) => _WorkoutDayTile(day: day)),
      ],
    );
  }

  Widget _buildBottomBar(
      BuildContext context, WidgetRef ref, bool isOwner) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          if (!isOwner) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.save, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => _startWorkout(context, ref),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.startWorkout, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startWorkout(BuildContext context, WidgetRef ref) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    ref.read(activeWorkoutProvider.notifier).startWorkout(
          userId: currentUser.id,
        );
    context.push('${AppRoutes.workout}/active');
  }

  Future<void> _handleDuplicate(BuildContext context, WidgetRef ref) async {
    final error = await ref
        .read(programsNotifierProvider.notifier)
        .duplicateProgram(program.id);
    if (!context.mounted) return;
    if (error != null) {
      context.showErrorSnackBar(error);
    } else {
      context.showSnackBar(AppLocalizations.of(context)!.programDuplicatedSuccess);
    }
  }

  Future<void> _handleArchive(BuildContext context, WidgetRef ref) async {
    final error = await ref
        .read(programsNotifierProvider.notifier)
        .archiveProgram(program.id);
    if (!context.mounted) return;
    if (error != null) {
      context.showErrorSnackBar(error);
    } else {
      context.pop();
      context.showSnackBar(AppLocalizations.of(context)!.programArchived);
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(l10n.deleteProgram),
          content: Text(
              'Are you sure you want to delete "${program.name}"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.delete,
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true || !context.mounted) return;

    final error = await ref
        .read(programsNotifierProvider.notifier)
        .deleteProgram(program.id);
    if (!context.mounted) return;
    if (error != null) {
      context.showErrorSnackBar(error);
    } else {
      context.pop();
      context.showSnackBar(l10n.programDeleted);
    }
  }

  String _formatDuration(ProgramDuration d) {
    switch (d) {
      case ProgramDuration.weeks4:
        return '4 weeks';
      case ProgramDuration.weeks6:
        return '6 weeks';
      case ProgramDuration.weeks8:
        return '8 weeks';
      case ProgramDuration.weeks12:
        return '12 weeks';
      case ProgramDuration.weeks16:
        return '16 weeks';
      case ProgramDuration.ongoing:
        return 'Ongoing';
    }
  }

  String _formatDifficulty(DifficultyLevel d) {
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
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: context.colorScheme.primary),
            const SizedBox(height: 6),
            Text(value, style: context.textTheme.titleSmall),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutDayTile extends StatefulWidget {
  const _WorkoutDayTile({required this.day});
  final WorkoutDay day;

  @override
  State<_WorkoutDayTile> createState() => _WorkoutDayTileState();
}

class _WorkoutDayTileState extends State<_WorkoutDayTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'D${widget.day.order + 1}',
                        style: context.textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.day.name,
                          style: context.textTheme.titleSmall,
                        ),
                        Text(
                          '${widget.day.totalExercises} exercises · ${widget.day.totalSets} sets',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            ...widget.day.exercises.map((ex) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      const SizedBox(width: 52),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              ex.exerciseName,
                              style: context.textTheme.bodyMedium,
                            ),
                            const Spacer(),
                            Text(
                              '${ex.totalSets} × sets',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
