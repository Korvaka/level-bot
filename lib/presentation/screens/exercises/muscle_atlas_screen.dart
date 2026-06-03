import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';

// ---------------------------------------------------------------------------
// Coordinate helpers (normalized 200 x 400 units)
// ---------------------------------------------------------------------------

Path _ovalPath(double cx, double cy, double rx, double ry, Size size) {
  final sx = size.width / 200;
  final sy = size.height / 400;
  return Path()
    ..addOval(Rect.fromCenter(
      center: Offset(cx * sx, cy * sy),
      width: rx * 2 * sx,
      height: ry * 2 * sy,
    ));
}

Path _rrectPath(double x1, double y1, double x2, double y2, Size size,
    {double r = 8}) {
  final sx = size.width / 200;
  final sy = size.height / 400;
  return Path()
    ..addRRect(RRect.fromRectAndRadius(
      Rect.fromLTRB(x1 * sx, y1 * sy, x2 * sx, y2 * sy),
      Radius.circular(r),
    ));
}

Path _polyPath(List<Offset> pts, Size size) {
  final sx = size.width / 200;
  final sy = size.height / 400;
  final p = Path()..moveTo(pts[0].dx * sx, pts[0].dy * sy);
  for (final pt in pts.skip(1)) {
    p.lineTo(pt.dx * sx, pt.dy * sy);
  }
  return p..close();
}

Path _combine(List<Path> paths) {
  final c = Path();
  for (final p in paths) {
    c.addPath(p, Offset.zero);
  }
  return c;
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

// ---------------------------------------------------------------------------
// Body view enum
// ---------------------------------------------------------------------------

enum _BodyView { front, back }

// ---------------------------------------------------------------------------
// Path builders
// ---------------------------------------------------------------------------

Map<MuscleGroup, Path> _buildFrontPaths(Size size) {
  return {
    MuscleGroup.chest: _polyPath([
      const Offset(68, 92),
      const Offset(100, 88),
      const Offset(132, 92),
      const Offset(128, 135),
      const Offset(100, 138),
      const Offset(72, 135),
    ], size),
    MuscleGroup.shoulders: _combine([
      _ovalPath(52, 103, 20, 22, size),
      _ovalPath(148, 103, 20, 22, size),
    ]),
    MuscleGroup.biceps: _combine([
      _rrectPath(50, 126, 70, 178, size),
      _rrectPath(130, 126, 150, 178, size),
    ]),
    MuscleGroup.forearms: _combine([
      _rrectPath(52, 180, 68, 230, size, r: 6),
      _rrectPath(132, 180, 148, 230, size, r: 6),
    ]),
    MuscleGroup.abs: _polyPath([
      const Offset(80, 140),
      const Offset(120, 140),
      const Offset(122, 235),
      const Offset(78, 235),
    ], size),
    MuscleGroup.quads: _combine([
      _rrectPath(62, 248, 97, 358, size, r: 12),
      _rrectPath(103, 248, 138, 358, size, r: 12),
    ]),
    MuscleGroup.calves: _combine([
      _ovalPath(74, 380, 14, 22, size),
      _ovalPath(126, 380, 14, 22, size),
    ]),
  };
}

Map<MuscleGroup, Path> _buildBackPaths(Size size) {
  return {
    MuscleGroup.back: _combine([
      _polyPath([
        const Offset(50, 92),
        const Offset(80, 88),
        const Offset(82, 195),
        const Offset(62, 220),
        const Offset(46, 180),
      ], size),
      _polyPath([
        const Offset(150, 92),
        const Offset(120, 88),
        const Offset(118, 195),
        const Offset(138, 220),
        const Offset(154, 180),
      ], size),
      _polyPath([
        const Offset(80, 88),
        const Offset(120, 88),
        const Offset(116, 142),
        const Offset(84, 142),
      ], size),
    ]),
    MuscleGroup.shoulders: _combine([
      _ovalPath(52, 103, 20, 22, size),
      _ovalPath(148, 103, 20, 22, size),
    ]),
    MuscleGroup.triceps: _combine([
      _rrectPath(50, 126, 68, 178, size),
      _rrectPath(132, 126, 150, 178, size),
    ]),
    MuscleGroup.forearms: _combine([
      _rrectPath(52, 180, 68, 230, size, r: 6),
      _rrectPath(132, 180, 148, 230, size, r: 6),
    ]),
    MuscleGroup.glutes: _combine([
      _ovalPath(77, 258, 22, 28, size),
      _ovalPath(123, 258, 22, 28, size),
    ]),
    MuscleGroup.hamstrings: _combine([
      _rrectPath(63, 288, 97, 360, size, r: 12),
      _rrectPath(103, 288, 137, 360, size, r: 12),
    ]),
    MuscleGroup.calves: _combine([
      _ovalPath(77, 382, 16, 26, size),
      _ovalPath(123, 382, 16, 26, size),
    ]),
  };
}

/// Silhouette paths (background, non-interactive)
Path _buildSilhouette(Size size) {
  return _combine([
    _ovalPath(100, 32, 26, 28, size), // head
    _rrectPath(90, 58, 110, 75, size, r: 6), // neck
    _rrectPath(28, 80, 54, 238, size, r: 10), // left arm
    _rrectPath(146, 80, 172, 238, size, r: 10), // right arm
    _rrectPath(50, 75, 150, 240, size, r: 12), // torso
    _rrectPath(60, 238, 98, 400, size, r: 10), // left leg
    _rrectPath(102, 238, 140, 400, size, r: 10), // right leg
  ]);
}

// ---------------------------------------------------------------------------
// CustomPainter
// ---------------------------------------------------------------------------

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.musclePaths,
    required this.selectedMuscles,
    required this.isDark,
    required this.size,
  });

  final Map<MuscleGroup, Path> musclePaths;
  final Set<MuscleGroup> selectedMuscles;
  final bool isDark;
  final Size size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // 1. Silhouette fill
    final silhouette = _buildSilhouette(canvasSize);
    canvas.drawPath(
      silhouette,
      Paint()
        ..color =
            isDark ? const Color(0xFF2A2A30) : const Color(0xFFE8E8F0)
        ..style = PaintingStyle.fill,
    );

    // 2. Muscle fills
    for (final entry in musclePaths.entries) {
      final muscle = entry.key;
      final path = entry.value;
      final isSelected = selectedMuscles.contains(muscle);
      final color = _muscleColor(muscle);

      if (isSelected) {
        // Glow layer
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withOpacity(0.35)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        // Solid fill
        canvas.drawPath(
          path,
          Paint()
            ..color = color.withOpacity(0.85)
            ..style = PaintingStyle.fill,
        );
        // Stroke
        canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      } else {
        canvas.drawPath(
          path,
          Paint()
            ..color = isDark
                ? const Color(0xFF3A3A45)
                : const Color(0xFFD0D0E0)
            ..style = PaintingStyle.fill,
        );
        canvas.drawPath(
          path,
          Paint()
            ..color = isDark
                ? const Color(0xFF50505A)
                : const Color(0xFFB8B8CC)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8,
        );
      }
    }

    // 3. Body outline on top
    canvas.drawPath(
      silhouette,
      Paint()
        ..color = isDark
            ? const Color(0xFF55555F)
            : const Color(0xFFB0B0C0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_BodyPainter old) =>
      old.selectedMuscles != selectedMuscles ||
      old.isDark != isDark ||
      old.size != size;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class MuscleAtlasScreen extends ConsumerStatefulWidget {
  const MuscleAtlasScreen({super.key});

  @override
  ConsumerState<MuscleAtlasScreen> createState() => _MuscleAtlasScreenState();
}

class _MuscleAtlasScreenState extends ConsumerState<MuscleAtlasScreen>
    with SingleTickerProviderStateMixin {
  _BodyView _view = _BodyView.front;
  final Set<MuscleGroup> _selectedMuscles = {};
  Map<MuscleGroup, Path>? _paths;
  Size? _lastSize;

  late final AnimationController _toggleController;
  late final Animation<double> _toggleAnimation;

  @override
  void initState() {
    super.initState();
    _toggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _toggleAnimation = CurvedAnimation(
      parent: _toggleController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _toggleController.dispose();
    super.dispose();
  }

  void _rebuildPaths(Size size) {
    _lastSize = size;
    _paths = _view == _BodyView.front
        ? _buildFrontPaths(size)
        : _buildBackPaths(size);
  }

  void _switchView(_BodyView view) {
    if (_view == view) return;
    setState(() {
      _view = view;
      if (_lastSize != null) _rebuildPaths(_lastSize!);
    });
    if (view == _BodyView.back) {
      _toggleController.forward();
    } else {
      _toggleController.reverse();
    }
  }

  void _onTapDown(TapDownDetails details, Size size) {
    if (_paths == null) return;
    final local = details.localPosition;
    MuscleGroup? tapped;
    for (final entry in _paths!.entries) {
      if (entry.value.contains(local)) {
        tapped = entry.key;
        break;
      }
    }
    if (tapped == null) return;

    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedMuscles.contains(tapped)) {
        _selectedMuscles.remove(tapped);
      } else {
        _selectedMuscles.add(tapped!);
      }
    });
  }

  void _clearSelection() {
    HapticFeedback.lightImpact();
    setState(() => _selectedMuscles.clear());
  }

  String _muscleLabel(MuscleGroup g) {
    switch (g) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.abs:
        return 'Abs';
      case MuscleGroup.quads:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.cardio:
        return 'Cardio';
      case MuscleGroup.fullBody:
        return 'Full Body';
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

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(allExercisesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle Atlas'),
        actions: [
          if (_selectedMuscles.isNotEmpty)
            TextButton.icon(
              onPressed: _clearSelection,
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          // View toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _ViewToggle(
              current: _view,
              onChanged: _switchView,
            ),
          ),

          // Body diagram
          Expanded(
            flex: 5,
            child: Center(
              child: AspectRatio(
                aspectRatio: 0.5,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size =
                        Size(constraints.maxWidth, constraints.maxHeight);
                    if (_lastSize != size) {
                      _rebuildPaths(size);
                    }
                    return GestureDetector(
                      onTapDown: (d) => _onTapDown(d, size),
                      child: CustomPaint(
                        size: size,
                        painter: _BodyPainter(
                          musclePaths: _paths ?? {},
                          selectedMuscles: _selectedMuscles,
                          isDark: isDark,
                          size: size,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Selected muscle chips
          if (_selectedMuscles.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                children: _selectedMuscles.map((muscle) {
                  final color = _muscleColor(muscle);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InputChip(
                      label: Text(
                        _muscleLabel(muscle),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onDeleted: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedMuscles.remove(muscle));
                      },
                      deleteIconColor: color,
                      backgroundColor: color.withOpacity(0.12),
                      side: BorderSide(color: color.withOpacity(0.4)),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),

          const Divider(height: 1),

          // Exercise list
          exercisesAsync.when(
            loading: () => const Expanded(
              flex: 4,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Expanded(
              flex: 4,
              child: Center(child: Text('Error: $e')),
            ),
            data: (exercises) {
              final filtered = exercises.where((e) =>
                  _selectedMuscles.isEmpty ||
                  _selectedMuscles.contains(e.primaryMuscle) ||
                  e.secondaryMuscles.any(_selectedMuscles.contains)).toList();

              return Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: Text(
                        '${filtered.length} exercise${filtered.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fitness_center_rounded,
                                    size: 40,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.4),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No exercises found',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _ExerciseTile(
                                  exercise: filtered[index],
                                  muscleColor: _muscleColor(
                                      filtered[index].primaryMuscle),
                                  muscleLabel: _muscleLabel(
                                      filtered[index].primaryMuscle),
                                  onTap: () => context
                                      .push('/exercises/${filtered[index].id}'),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// View toggle widget
// ---------------------------------------------------------------------------

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({
    required this.current,
    required this.onChanged,
  });

  final _BodyView current;
  final ValueChanged<_BodyView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleButton(
          label: 'Front',
          isSelected: current == _BodyView.front,
          isLeft: true,
          onTap: () => onChanged(_BodyView.front),
        ),
        _ToggleButton(
          label: 'Back',
          isSelected: current == _BodyView.back,
          isLeft: false,
          onTap: () => onChanged(_BodyView.back),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.isLeft,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.horizontal(
      left: isLeft ? const Radius.circular(10) : Radius.zero,
      right: isLeft ? Radius.zero : const Radius.circular(10),
    );
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 88,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: borderRadius,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.4),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise tile
// ---------------------------------------------------------------------------

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({
    required this.exercise,
    required this.muscleColor,
    required this.muscleLabel,
    required this.onTap,
  });

  final ExerciseEntity exercise;
  final Color muscleColor;
  final String muscleLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: muscleColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.fitness_center_rounded,
          color: muscleColor,
          size: 20,
        ),
      ),
      title: Text(
        exercise.name,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        muscleLabel,
        style: TextStyle(
          color: muscleColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 18),
      onTap: onTap,
    );
  }
}
