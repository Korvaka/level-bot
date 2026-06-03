import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/entities/muscle_zone_entity.dart';
import 'package:level_bot/presentation/providers/muscle_zone_provider.dart';

// Simple admin check - in production this would check Firestore user roles
final isAdminProvider = Provider<bool>((ref) => false);

class AdminZoneEditorScreen extends ConsumerStatefulWidget {
  const AdminZoneEditorScreen({super.key});

  @override
  ConsumerState<AdminZoneEditorScreen> createState() =>
      _AdminZoneEditorScreenState();
}

class _AdminZoneEditorScreenState
    extends ConsumerState<AdminZoneEditorScreen> {
  String _view = 'front';
  final List<Offset> _currentPolygon = [];
  MuscleGroup _selectedMuscle = MuscleGroup.chest;
  String _displayName = '';
  bool _isSaving = false;
  Size? _canvasSize;

  void _addPoint(TapDownDetails details) {
    if (_canvasSize == null) return;
    HapticFeedback.selectionClick();
    final normalized = Offset(
      details.localPosition.dx / _canvasSize!.width,
      details.localPosition.dy / _canvasSize!.height,
    );
    setState(() => _currentPolygon.add(normalized));
  }

  void _undoLastPoint() {
    if (_currentPolygon.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _currentPolygon.removeLast());
  }

  Future<void> _saveZone() async {
    if (_currentPolygon.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Need at least 3 points to define a zone')));
      return;
    }
    if (_displayName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a zone name')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final id =
          '${_selectedMuscle.name}_${_view}_${DateTime.now().millisecondsSinceEpoch}';
      final zone = MuscleZoneEntity(
        id: id,
        displayName: _displayName.trim(),
        muscleGroup: _selectedMuscle,
        view: _view,
        polygon: List.from(_currentPolygon),
      );
      await FirebaseFirestore.instance
          .collection('muscle_zones')
          .doc(id)
          .set(zone.toFirestore());
      // Invalidate the provider cache
      ref.invalidate(muscleZonesProvider);
      setState(() {
        _currentPolygon.clear();
        _displayName = '';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Zone saved successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteZone(String zoneId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Zone'),
        content: const Text('Are you sure you want to delete this zone?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    await FirebaseFirestore.instance
        .collection('muscle_zones')
        .doc(zoneId)
        .delete();
    ref.invalidate(muscleZonesProvider);
  }

  Color _color(MuscleGroup m) {
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
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(muscleZonesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zone Editor'),
        actions: [
          if (_currentPolygon.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.undo_rounded),
              onPressed: _undoLastPoint,
              tooltip: 'Undo last point',
            ),
        ],
      ),
      body: Column(
        children: [
          // View toggle
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'front', label: Text('Front')),
                      ButtonSegment(value: 'back', label: Text('Back')),
                    ],
                    selected: {_view},
                    onSelectionChanged: (s) => setState(() {
                      _view = s.first;
                      _currentPolygon.clear();
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Muscle group selector
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonFormField<MuscleGroup>(
              value: _selectedMuscle,
              decoration: const InputDecoration(
                labelText: 'Muscle Group',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: MuscleGroup.values
                  .where((m) =>
                      m != MuscleGroup.cardio &&
                      m != MuscleGroup.fullBody)
                  .map((m) =>
                      DropdownMenuItem(value: m, child: Text(m.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedMuscle = v);
              },
            ),
          ),

          // Zone name input
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Zone Display Name (e.g. Pectoraux)',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (v) => _displayName = v,
            ),
          ),

          // Body canvas
          Expanded(
            flex: 4,
            child: Center(
              child: AspectRatio(
                aspectRatio: 200 / 440,
                child: zonesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      const Center(child: Text('Error loading zones')),
                  data: (allZones) {
                    final viewZones =
                        allZones.where((z) => z.view == _view).toList();
                    return LayoutBuilder(builder: (context, constraints) {
                      final size =
                          Size(constraints.maxWidth, constraints.maxHeight);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_canvasSize != size) {
                          setState(() => _canvasSize = size);
                        }
                      });
                      return GestureDetector(
                        onTapDown: _addPoint,
                        child: CustomPaint(
                          size: size,
                          painter: _EditorPainter(
                            existingZones: viewZones,
                            currentPolygon: _currentPolygon,
                            currentColor: _color(_selectedMuscle),
                            isDark: isDark,
                          ),
                        ),
                      );
                    });
                  },
                ),
              ),
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _currentPolygon.clear()),
                    icon: const Icon(Icons.clear_rounded),
                    label: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _saveZone,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2))
                        : const Icon(Icons.save_rounded),
                    label: const Text('Save Zone'),
                  ),
                ),
              ],
            ),
          ),

          // Existing zones list
          zonesAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (allZones) {
              final viewZones =
                  allZones.where((z) => z.view == _view).toList();
              if (viewZones.isEmpty) return const SizedBox();
              return SizedBox(
                height: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 4),
                      child: Text('Saved Zones',
                          style:
                              Theme.of(context).textTheme.titleSmall),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        itemCount: viewZones.length,
                        itemBuilder: (context, i) {
                          final zone = viewZones[i];
                          final color = _color(zone.muscleGroup);
                          return Padding(
                            padding: const EdgeInsets.only(
                                right: 8, bottom: 8),
                            child: InputChip(
                              label: Text(
                                zone.displayName,
                                style: TextStyle(
                                    color: color, fontSize: 12),
                              ),
                              backgroundColor:
                                  color.withOpacity(0.12),
                              side: BorderSide(
                                  color: color.withOpacity(0.4)),
                              onDeleted: () =>
                                  _deleteZone(zone.id),
                              deleteIconColor: color,
                              visualDensity: VisualDensity.compact,
                            ),
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
// Editor painter
// ---------------------------------------------------------------------------

class _EditorPainter extends CustomPainter {
  _EditorPainter({
    required this.existingZones,
    required this.currentPolygon,
    required this.currentColor,
    required this.isDark,
  });

  final List<MuscleZoneEntity> existingZones;
  final List<Offset> currentPolygon;
  final Color currentColor;
  final bool isDark;

  Color _color(MuscleGroup m) {
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
      default:
        return AppColors.primary;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 200;
    final sy = size.height / 440;

    // Silhouette background
    final silhouetteColor =
        isDark ? const Color(0xFF2A2A32) : const Color(0xFFE8E0D8);
    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..color =
            isDark ? const Color(0xFF1A1A1E) : const Color(0xFFF0EDE8),
    );

    // Body outline hint
    canvas.drawRect(
      Rect.fromLTWH(50 * sx, 75 * sy, 100 * sx, 305 * sy),
      Paint()
        ..color = silhouetteColor
        ..style = PaintingStyle.fill,
    );

    // Draw existing zones
    for (final zone in existingZones) {
      if (zone.polygon.isEmpty) continue;
      final color = _color(zone.muscleGroup);
      final path = Path();
      path.moveTo(
          zone.polygon[0].dx * size.width, zone.polygon[0].dy * size.height);
      for (int i = 1; i < zone.polygon.length; i++) {
        path.lineTo(
            zone.polygon[i].dx * size.width,
            zone.polygon[i].dy * size.height);
      }
      path.close();
      canvas.drawPath(
          path,
          Paint()
            ..color = color.withOpacity(0.3)
            ..style = PaintingStyle.fill);
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2);
    }

    // Draw current polygon being drawn
    if (currentPolygon.isNotEmpty) {
      final path = Path();
      path.moveTo(currentPolygon[0].dx * size.width,
          currentPolygon[0].dy * size.height);
      for (int i = 1; i < currentPolygon.length; i++) {
        path.lineTo(currentPolygon[i].dx * size.width,
            currentPolygon[i].dy * size.height);
      }

      canvas.drawPath(
          path,
          Paint()
            ..color = currentColor.withOpacity(0.25)
            ..style = PaintingStyle.fill);
      canvas.drawPath(
          path,
          Paint()
            ..color = currentColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..strokeJoin = StrokeJoin.round);

      // Draw point dots
      for (final pt in currentPolygon) {
        canvas.drawCircle(
          Offset(pt.dx * size.width, pt.dy * size.height),
          4,
          Paint()..color = currentColor,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_EditorPainter old) => true;
}
