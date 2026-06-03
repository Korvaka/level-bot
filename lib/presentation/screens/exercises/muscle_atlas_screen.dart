import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/entities/muscle_zone_entity.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';
import 'package:level_bot/presentation/providers/muscle_zone_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

bool _pointInPolygon(Offset point, List<Offset> polygon, Size canvasSize) {
  final px = point.dx / canvasSize.width;
  final py = point.dy / canvasSize.height;
  bool inside = false;
  int j = polygon.length - 1;
  for (int i = 0; i < polygon.length; i++) {
    final xi = polygon[i].dx, yi = polygon[i].dy;
    final xj = polygon[j].dx, yj = polygon[j].dy;
    if (((yi > py) != (yj > py)) &&
        (px < (xj - xi) * (py - yi) / (yj - yi) + xi)) {
      inside = !inside;
    }
    j = i;
  }
  return inside;
}

Color _zoneColor(MuscleGroup m) {
  switch (m) {
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

String _muscleName(MuscleGroup m) {
  switch (m) {
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

// ---------------------------------------------------------------------------
// Silhouette painter
// ---------------------------------------------------------------------------

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.zones,
    required this.selectedIds,
    required this.isDark,
  });

  final List<MuscleZoneEntity> zones;
  final Set<String> selectedIds;
  final bool isDark;

  // Build a Path from normalized polygon coords scaled to canvas size
  Path _buildPath(List<Offset> polygon, Size size) {
    if (polygon.isEmpty) return Path();
    final path = Path();
    path.moveTo(polygon[0].dx * size.width, polygon[0].dy * size.height);
    for (int i = 1; i < polygon.length; i++) {
      path.lineTo(polygon[i].dx * size.width, polygon[i].dy * size.height);
    }
    return path..close();
  }

  // Build smooth human body silhouette using Bezier curves
  // Canvas coordinate space: 200 x 440
  Path _buildSilhouette(Size s) {
    final sx = s.width / 200;
    final sy = s.height / 440;
    double x(double v) => v * sx;
    double y(double v) => v * sy;

    final path = Path();

    // Head
    path.addOval(Rect.fromCenter(
      center: Offset(x(100), y(30)),
      width: x(46),
      height: y(46),
    ));

    // Neck
    path.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(x(89), y(52), x(22), y(24)),
      Radius.circular(x(5)),
    ));

    // Left arm
    {
      final arm = Path();
      arm.moveTo(x(26), y(82));
      arm.cubicTo(x(18), y(88), x(14), y(100), x(18), y(116));
      arm.cubicTo(x(20), y(160), x(22), y(208), x(26), y(244));
      arm.cubicTo(x(26), y(252), x(34), y(258), x(44), y(256));
      arm.cubicTo(x(48), y(220), x(50), y(172), x(50), y(130));
      arm.cubicTo(x(46), y(100), x(40), y(86), x(26), y(82));
      arm.close();
      path.addPath(arm, Offset.zero);
    }

    // Right arm (mirror)
    {
      final arm = Path();
      arm.moveTo(x(174), y(82));
      arm.cubicTo(x(182), y(88), x(186), y(100), x(182), y(116));
      arm.cubicTo(x(180), y(160), x(178), y(208), x(174), y(244));
      arm.cubicTo(x(174), y(252), x(166), y(258), x(156), y(256));
      arm.cubicTo(x(152), y(220), x(150), y(172), x(150), y(130));
      arm.cubicTo(x(154), y(100), x(160), y(86), x(174), y(82));
      arm.close();
      path.addPath(arm, Offset.zero);
    }

    // Torso body
    {
      final torso = Path();
      torso.moveTo(x(50), y(78));
      // Left side of torso: shoulder -> waist -> hip
      torso.cubicTo(x(44), y(100), x(42), y(155), x(44), y(200));
      torso.cubicTo(x(44), y(228), x(46), y(244), x(50), y(252));
      // Left leg
      torso.cubicTo(x(50), y(262), x(54), y(268), x(60), y(270));
      torso.cubicTo(x(58), y(340), x(56), y(398), x(60), y(438));
      torso.lineTo(x(88), y(440));
      torso.cubicTo(x(88), y(394), x(88), y(336), x(90), y(276));
      // Crotch
      torso.cubicTo(x(94), y(268), x(106), y(268), x(110), y(276));
      // Right inner leg
      torso.cubicTo(x(112), y(336), x(112), y(394), x(112), y(440));
      torso.lineTo(x(140), y(438));
      // Right outer leg up
      torso.cubicTo(x(144), y(398), x(142), y(340), x(140), y(270));
      // Right groin
      torso.cubicTo(x(146), y(268), x(150), y(262), x(150), y(252));
      // Right torso side up
      torso.cubicTo(x(154), y(244), x(156), y(228), x(156), y(200));
      torso.cubicTo(x(158), y(155), x(156), y(100), x(150), y(78));
      // Shoulder top
      torso.lineTo(x(50), y(78));
      torso.close();
      path.addPath(torso, Offset.zero);
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final silhouette = _buildSilhouette(size);
    final skinColor =
        isDark ? const Color(0xFF2A2A32) : const Color(0xFFE8E0D8);
    final outlineColor =
        isDark ? const Color(0xFF484854) : const Color(0xFFC0B8B0);

    // 1. Silhouette fill
    canvas.drawPath(
      silhouette,
      Paint()
        ..color = skinColor
        ..style = PaintingStyle.fill,
    );

    // 2. Muscle zones
    for (final zone in zones) {
      final isSelected = selectedIds.contains(zone.id);
      final color = _zoneColor(zone.muscleGroup);
      final path = _buildPath(zone.polygon, size);

      if (isSelected) {
        canvas.drawPath(
            path,
            Paint()
              ..color = color.withOpacity(0.3)
              ..style = PaintingStyle.fill
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
        canvas.drawPath(
            path,
            Paint()
              ..color = color.withOpacity(0.88)
              ..style = PaintingStyle.fill);
        canvas.drawPath(
            path,
            Paint()
              ..color = color
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5);
      } else {
        canvas.drawPath(
            path,
            Paint()
              ..color = isDark
                  ? const Color(0xFF3C3C48)
                  : const Color(0xFFD0C8C0)
              ..style = PaintingStyle.fill);
        canvas.drawPath(
            path,
            Paint()
              ..color = isDark
                  ? const Color(0xFF545460)
                  : const Color(0xFFB8B0A8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8);
      }
    }

    // 3. Silhouette outline on top
    canvas.drawPath(
        silhouette,
        Paint()
          ..color = outlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(_BodyPainter old) =>
      old.selectedIds != selectedIds ||
      old.isDark != isDark ||
      old.zones != zones;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class MuscleAtlasScreen extends ConsumerStatefulWidget {
  const MuscleAtlasScreen({super.key});

  @override
  ConsumerState<MuscleAtlasScreen> createState() => _MuscleAtlasScreenState();
}

class _MuscleAtlasScreenState extends ConsumerState<MuscleAtlasScreen> {
  String _view = 'front';
  final Set<String> _selectedZoneIds = {};
  Size? _canvasSize;

  void _onTap(TapDownDetails details, List<MuscleZoneEntity> zones) {
    if (_canvasSize == null) return;
    final pos = details.localPosition;
    for (final zone in zones.reversed) {
      if (_pointInPolygon(pos, zone.polygon, _canvasSize!)) {
        HapticFeedback.lightImpact();
        setState(() {
          if (_selectedZoneIds.contains(zone.id)) {
            _selectedZoneIds.remove(zone.id);
          } else {
            _selectedZoneIds.add(zone.id);
          }
        });
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(muscleZonesProvider);
    final exercisesAsync = ref.watch(allExercisesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle Atlas'),
        actions: [
          if (_selectedZoneIds.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedZoneIds.clear());
              },
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: zonesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allZones) {
          final viewZones =
              allZones.where((z) => z.view == _view).toList();
          final selectedZones =
              allZones.where((z) => _selectedZoneIds.contains(z.id)).toList();
          final selectedMuscles =
              selectedZones.map((z) => z.muscleGroup).toSet();

          return Column(
            children: [
              // View toggle
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: _ViewToggle(
                  current: _view,
                  onChanged: (v) => setState(() => _view = v),
                ),
              ),

              // Body diagram
              Expanded(
                flex: 5,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 200 / 440,
                    child: LayoutBuilder(builder: (context, constraints) {
                      final size =
                          Size(constraints.maxWidth, constraints.maxHeight);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_canvasSize != size) {
                          setState(() => _canvasSize = size);
                        }
                      });
                      return GestureDetector(
                        onTapDown: (d) => _onTap(d, viewZones),
                        child: CustomPaint(
                          size: size,
                          painter: _BodyPainter(
                            zones: viewZones,
                            selectedIds: _selectedZoneIds,
                            isDark: isDark,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // Selected chips
              if (_selectedZoneIds.isNotEmpty)
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    children: selectedZones.map((zone) {
                      final color = _zoneColor(zone.muscleGroup);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InputChip(
                          label: Text(
                            zone.displayName,
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onDeleted: () {
                            HapticFeedback.lightImpact();
                            setState(
                                () => _selectedZoneIds.remove(zone.id));
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
                  final filtered = selectedMuscles.isEmpty
                      ? exercises
                      : exercises
                          .where((e) =>
                              selectedMuscles.contains(e.primaryMuscle) ||
                              e.secondaryMuscles
                                  .any(selectedMuscles.contains))
                          .toList();

                  return Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16, 10, 16, 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${filtered.length} exercise${filtered.length == 1 ? '' : 's'}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ),
                              if (selectedMuscles.isNotEmpty)
                                FilledButton.tonal(
                                  onPressed: () => context
                                      .push('/programs/smart-builder'),
                                  child: const Text('Create Program'),
                                ),
                            ],
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final ex = filtered[index];
                                    final color =
                                        _zoneColor(ex.primaryMuscle);
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                      leading: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              color.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.fitness_center_rounded,
                                          color: color,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        ex.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                                fontWeight:
                                                    FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        _muscleName(ex.primaryMuscle),
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      trailing: const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18),
                                      onTap: () => context
                                          .push('/exercises/${ex.id}'),
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
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// View toggle
// ---------------------------------------------------------------------------

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleBtn(
          label: 'Front',
          isSelected: current == 'front',
          isLeft: true,
          onTap: () => onChanged('front'),
        ),
        _ToggleBtn(
          label: 'Back',
          isSelected: current == 'back',
          isLeft: false,
          onTap: () => onChanged('back'),
        ),
      ],
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 88,
        height: 38,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(10) : Radius.zero,
            right: isLeft ? Radius.zero : const Radius.circular(10),
          ),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Theme.of(context)
                    .colorScheme
                    .outline
                    .withOpacity(0.4),
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
