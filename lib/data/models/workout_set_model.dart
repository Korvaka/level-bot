import 'package:level_bot/domain/entities/workout_set_entity.dart';

class WorkoutSetModel extends WorkoutSetEntity {
  const WorkoutSetModel({
    required super.id,
    required super.setNumber,
    super.weight,
    super.reps,
    super.durationSeconds,
    super.distanceMeters,
    super.rpe,
    super.restSeconds,
    super.tempo,
    super.notes,
    super.isCompleted,
    super.completedAt,
    super.type,
    super.isPersonalRecord,
  });

  factory WorkoutSetModel.fromMap(Map<String, dynamic> data) {
    return WorkoutSetModel(
      id: data['id'] as String? ?? '',
      setNumber: data['setNumber'] as int? ?? 1,
      weight: (data['weight'] as num?)?.toDouble(),
      reps: data['reps'] as int?,
      durationSeconds: data['durationSeconds'] as int?,
      distanceMeters: (data['distanceMeters'] as num?)?.toDouble(),
      rpe: (data['rpe'] as num?)?.toDouble(),
      restSeconds: data['restSeconds'] as int?,
      tempo: data['tempo'] as String?,
      notes: data['notes'] as String?,
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedAt: data['completedAt'] != null
          ? DateTime.parse(data['completedAt'] as String)
          : null,
      type: SetType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => SetType.normal,
      ),
      isPersonalRecord: data['isPersonalRecord'] as bool? ?? false,
    );
  }

  factory WorkoutSetModel.fromEntity(WorkoutSetEntity entity) {
    return WorkoutSetModel(
      id: entity.id,
      setNumber: entity.setNumber,
      weight: entity.weight,
      reps: entity.reps,
      durationSeconds: entity.durationSeconds,
      distanceMeters: entity.distanceMeters,
      rpe: entity.rpe,
      restSeconds: entity.restSeconds,
      tempo: entity.tempo,
      notes: entity.notes,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      type: entity.type,
      isPersonalRecord: entity.isPersonalRecord,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'distanceMeters': distanceMeters,
      'rpe': rpe,
      'restSeconds': restSeconds,
      'tempo': tempo,
      'notes': notes,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'type': type.name,
      'isPersonalRecord': isPersonalRecord,
    };
  }
}
