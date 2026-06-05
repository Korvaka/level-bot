import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/entities/muscle_zone_entity.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';
import 'package:level_bot/presentation/providers/muscle_zone_provider.dart';

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
    case MuscleGroup.chest:      return AppColors.chest;
    case MuscleGroup.back:       return AppColors.back;
    case MuscleGroup.shoulders:  return AppColors.shoulders;
    case MuscleGroup.biceps:     return AppColors.biceps;
    case MuscleGroup.triceps:    return AppColors.triceps;
    case MuscleGroup.forearms:   return AppColors.forearms;
    case MuscleGroup.abs:        return AppColors.abs;
    case MuscleGroup.quads:      return AppColors.quads;
    case MuscleGroup.hamstrings: return AppColors.hamstrings;
    case MuscleGroup.glutes:     return AppColors.glutes;
    case MuscleGroup.calves:     return AppColors.calves;
    case MuscleGroup.cardio:     return AppColors.cardio;
    case MuscleGroup.fullBody:   return AppColors.primary;
  }
}

String _muscleName(MuscleGroup m, AppLocalizations l10n) {
  switch (m) {
    case MuscleGroup.chest:      return l10n.chest;
    case MuscleGroup.back:       return l10n.back;
    case MuscleGroup.shoulders:  return l10n.shoulders;
    case MuscleGroup.biceps:     return l10n.biceps;
    case MuscleGroup.triceps:    return l10n.triceps;
    case MuscleGroup.forearms:   return l10n.forearms;
    case MuscleGroup.abs:        return l10n.abs;
    case MuscleGroup.quads:      return l10n.quads;
    case MuscleGroup.hamstrings: return l10n.hamstrings;
    case MuscleGroup.glutes:     return l10n.glutes;
    case MuscleGroup.calves:     return l10n.calves;
    case MuscleGroup.cardio:     return l10n.cardio;
    case MuscleGroup.fullBody:   return l10n.fullBody;
  }
}

class _BodyPainter extends CustomPainter {
  _BodyPainter({
    required this.zones,
    required this.selectedIds,
    required this.isDark,
    required this.glowIntensity,
  });

  final List<MuscleZoneEntity> zones;
  final Set<String> selectedIds;
  final bool isDark;
  final double glowIntensity;

  Path _buildZonePath(List<Offset> polygon, Size size) {
    if (polygon.isEmpty) return Path();
    final path = Path()
      ..moveTo(polygon[0].dx * size.width, polygon[0].dy * size.height);
    for (int i = 1; i < polygon.length; i++) {
      path.lineTo(polygon[i].dx * size.width, polygon[i].dy * size.height);
    }
    return path..close();
  }

  Path _buildSilhouette(Size s) {
    final sx = s.width / 200;
    final sy = s.height / 440;
    double x(double v) => v * sx;
    double y(double v) => v * sy;
    final path = Path();

    // Head
    path.addOval(Rect.fromCenter(
      center: Offset(x(100), y(29)),
      width: x(44),
      height: y(48),
    ));

    // Neck
    {
      final n = Path();
      n.moveTo(x(90), y(53));
      n.cubicTo(x(88), y(62), x(84), y(70), x(82), y(78));
      n.lineTo(x(118), y(78));
      n.cubicTo(x(116), y(70), x(112), y(62), x(110), y(53));
      n.close();
      path.addPath(n, Offset.zero);
    }

    // Left arm (tapered athletic shape)
    {
      final a = Path();
      a.moveTo(x(30), y(80));
      a.cubicTo(x(20), y(90), x(14), y(106), x(16), y(124));
      a.cubicTo(x(18), y(168), x(20), y(215), x(24), y(248));
      a.cubicTo(x(24), y(256), x(30), y(262), x(43), y(260));
      a.cubicTo(x(47), y(222), x(48), y(173), x(48), y(136));
      a.cubicTo(x(44), y(104), x(40), y(90), x(30), y(80));
      a.close();
      path.addPath(a, Offset.zero);
    }

    // Right arm (mirror)
    {
      final a = Path();
      a.moveTo(x(170), y(80));
      a.cubicTo(x(180), y(90), x(186), y(106), x(184), y(124));
      a.cubicTo(x(182), y(168), x(180), y(215), x(176), y(248));
      a.cubicTo(x(176), y(256), x(170), y(262), x(157), y(260));
      a.cubicTo(x(153), y(222), x(152), y(173), x(152), y(136));
      a.cubicTo(x(156), y(104), x(160), y(90), x(170), y(80));
      a.close();
      path.addPath(a, Offset.zero);
    }

    // Torso + legs (V-taper: broad shoulders, narrow waist, hip flare, legs)
    {
      final b = Path();
      b.moveTo(x(48), y(76));
      b.cubicTo(x(42), y(108), x(40), y(162), x(42), y(208));
      b.cubicTo(x(42), y(234), x(44), y(248), x(48), y(258));
      b.cubicTo(x(48), y(270), x(53), y(278), x(62), y(280));
      b.cubicTo(x(60), y(348), x(58), y(404), x(62), y(436));
      b.lineTo(x(90), y(440));
      b.cubicTo(x(90), y(402), x(90), y(344), x(92), y(284));
      b.cubicTo(x(95), y(274), x(105), y(274), x(108), y(284));
      b.cubicTo(x(110), y(344), x(110), y(402), x(110), y(440));
      b.lineTo(x(138), y(436));
      b.cubicTo(x(142), y(404), x(140), y(348), x(138), y(280));
      b.cubicTo(x(147), y(278), x(152), y(270), x(152), y(258));
      b.cubicTo(x(156), y(248), x(158), y(234), x(158), y(208));
      b.cubicTo(x(160), y(162), x(158), y(108), x(152), y(76));
      b.lineTo(x(48), y(76));
      b.close();
      path.addPath(b, Offset.zero);
    }

    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final silhouette = _buildSilhouette(size);
    final skinBase = isDark ? const Color(0xFF252530) : const Color(0xFFE4DDD5);
    final outline = isDark ? const Color(0xFF40404E) : const Color(0xFFB8B0A8);

    canvas.drawPath(silhouette, Paint()
      ..color = skinBase
      ..style = PaintingStyle.fill);

    for (final zone in zones) {
      final isSelected = selectedIds.contains(zone.id);
      final color = _zoneColor(zone.muscleGroup);
      final path = _buildZonePath(zone.polygon, size);
      final bounds = path.getBounds();

      if (isSelected) {
        canvas.drawPath(path, Paint()
          ..color = color.withOpacity(0.22 + glowIntensity * 0.18)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 + glowIntensity * 4));
        canvas.drawPath(path, Paint()
          ..shader = RadialGradient(
            center: Alignment.center,
            radius: 0.85,
            colors: [Colors.white.withOpacity(0.25), color],
          ).createShader(bounds)
          ..style = PaintingStyle.fill);
        canvas.drawPath(path, Paint()
          ..color = color.withOpacity(0.85 + glowIntensity * 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round);
      } else {
        canvas.drawPath(path, Paint()
          ..shader = RadialGradient(
            center: Alignment.center,
            radius: 0.7,
            colors: isDark
                ? [const Color(0xFF484858), const Color(0xFF2C2C3A)]
                : [const Color(0xFFD5CCC5), const Color(0xFFBEB6AE)],
          ).createShader(bounds)
          ..style = PaintingStyle.fill);
        canvas.drawPath(path, Paint()
          ..color = isDark ? const Color(0xFF565668) : const Color(0xFFAEA6A0)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.6
          ..strokeJoin = StrokeJoin.round);
      }
    }

    canvas.drawPath(silhouette, Paint()
      ..color = outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9);
  }

  @override
  bool shouldRepaint(_BodyPainter old) =>
      old.selectedIds != selectedIds ||
      old.isDark != isDark ||
      old.zones != zones ||
      old.glowIntensity != glowIntensity;
}

class MuscleAtlasScreen extends ConsumerStatefulWidget {
  const MuscleAtlasScreen({super.key});

  @override
  ConsumerState<MuscleAtlasScreen> createState() => _MuscleAtlasScreenState();
}

class _MuscleAtlasScreenState extends ConsumerState<MuscleAtlasScreen>
    with TickerProviderStateMixin {
  final Set<String> _selectedZoneIds = {};
  Size? _frontSize;
  Size? _backSize;

  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  void _onTap(TapDownDetails details, List<MuscleZoneEntity> zones, Size? sz) {
    if (sz == null) return;
    for (final zone in zones.reversed) {
      if (_pointInPolygon(details.localPosition, zone.polygon, sz)) {
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
    final l10n = AppLocalizations.of(context)!;
    final zonesAsync = ref.watch(muscleZonesProvider);
    final exercisesAsync = ref.watch(allExercisesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final bgColor = isDark ? const Color(0xFF0E0E12) : const Color(0xFFF5F2EF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(l10n.muscleAtlas,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        actions: [
          if (_selectedZoneIds.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedZoneIds.clear());
              },
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: Text(l10n.clearSelection),
            ),
        ],
      ),
      body: zonesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allZones) {
          final frontZones = allZones.where((z) => z.view == 'front').toList();
          final backZones = allZones.where((z) => z.view == 'back').toList();
          final selectedZones =
              allZones.where((z) => _selectedZoneIds.contains(z.id)).toList();
          final selectedMuscles =
              selectedZones.map((z) => z.muscleGroup).toSet();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _selectedZoneIds.isEmpty
                      ? Text(
                          l10n.tapMuscleExplore,
                          key: const ValueKey('empty'),
                          style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant),
                        )
                      : Text(
                          '${_selectedZoneIds.length} ${l10n.musclesLabel}',
                          key: const ValueKey('selected'),
                          style: tt.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              // Dual body view
              Expanded(
                flex: 5,
                child: AnimatedBuilder(
                  animation: _glowAnim,
                  builder: (context, _) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // FRONT
                        Expanded(
                          child: Column(
                            children: [
                              Text(l10n.viewFront.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: cs.onSurfaceVariant.withOpacity(0.6),
                                  )),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 200 / 440,
                                    child: LayoutBuilder(builder: (ctx, c) {
                                      final sz =
                                          Size(c.maxWidth, c.maxHeight);
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (_frontSize != sz && mounted) {
                                          setState(() => _frontSize = sz);
                                        }
                                      });
                                      return GestureDetector(
                                        onTapDown: (d) =>
                                            _onTap(d, frontZones, _frontSize),
                                        child: CustomPaint(
                                          size: sz,
                                          painter: _BodyPainter(
                                            zones: frontZones,
                                            selectedIds: _selectedZoneIds,
                                            isDark: isDark,
                                            glowIntensity: _glowAnim.value,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Center divider / badge
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_selectedZoneIds.isNotEmpty)
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${_selectedZoneIds.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: 1,
                                  height: 100,
                                  color: isDark
                                      ? const Color(0xFF303040)
                                      : const Color(0xFFD0C8C0),
                                ),
                            ],
                          ),
                        ),

                        // BACK
                        Expanded(
                          child: Column(
                            children: [
                              Text(l10n.viewBack.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: cs.onSurfaceVariant.withOpacity(0.6),
                                  )),
                              const SizedBox(height: 4),
                              Expanded(
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: 200 / 440,
                                    child: LayoutBuilder(builder: (ctx, c) {
                                      final sz =
                                          Size(c.maxWidth, c.maxHeight);
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (_backSize != sz && mounted) {
                                          setState(() => _backSize = sz);
                                        }
                                      });
                                      return GestureDetector(
                                        onTapDown: (d) =>
                                            _onTap(d, backZones, _backSize),
                                        child: CustomPaint(
                                          size: sz,
                                          painter: _BodyPainter(
                                            zones: backZones,
                                            selectedIds: _selectedZoneIds,
                                            isDark: isDark,
                                            glowIntensity: _glowAnim.value,
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Selected chips
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: _selectedZoneIds.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
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
                                label: Text(zone.displayName,
                                    style: TextStyle(
                                        color: color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
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
              ),

              Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF28283A)
                    : const Color(0xFFE0D8D0),
              ),

              // Exercise list
              exercisesAsync.when(
                loading: () => const Expanded(
                    flex: 4, child: Center(child: CircularProgressIndicator())),
                error: (e, _) =>
                    Expanded(flex: 4, child: Center(child: Text('Error: $e'))),
                data: (exercises) {
                  final filtered = selectedMuscles.isEmpty
                      ? exercises
                      : exercises
                          .where((e) =>
                              selectedMuscles.contains(e.primaryMuscle) ||
                              e.secondaryMuscles.any(selectedMuscles.contains))
                          .toList();

                  return Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${filtered.length} ${l10n.exercises}',
                                  style: tt.titleSmall
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ),
                              if (selectedMuscles.isNotEmpty)
                                FilledButton.tonal(
                                  onPressed: () =>
                                      context.push('/programs/smart-builder'),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                    minimumSize: const Size(0, 32),
                                  ),
                                  child: Text(l10n.createProgramFromMuscles,
                                      style: const TextStyle(fontSize: 12)),
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
                                      Icon(Icons.fitness_center_rounded,
                                          size: 38,
                                          color: cs.onSurfaceVariant
                                              .withOpacity(0.35)),
                                      const SizedBox(height: 8),
                                      Text(l10n.noExercisesFound,
                                          style: tt.bodyMedium?.copyWith(
                                              color: cs.onSurfaceVariant)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, i) {
                                    final ex = filtered[i];
                                    final color = _zoneColor(ex.primaryMuscle);
                                    return ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 2),
                                      leading: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.14),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                            Icons.fitness_center_rounded,
                                            color: color,
                                            size: 18),
                                      ),
                                      title: Text(ex.name,
                                          style: tt.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      subtitle: Text(
                                          _muscleName(ex.primaryMuscle, l10n),
                                          style: TextStyle(
                                              color: color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                      trailing: const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 16),
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
