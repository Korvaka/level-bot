import 'package:equatable/equatable.dart';

enum SetType { normal, warmup, dropSet, failureSet, restPause }

class WorkoutSetEntity extends Equatable {
  const WorkoutSetEntity({
    required this.id,
    required this.setNumber,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
    this.rpe,
    this.restSeconds,
    this.tempo,
    this.notes,
    this.isCompleted = false,
    this.completedAt,
    this.type = SetType.normal,
    this.isPersonalRecord = false,
  });

  final String id;
  final int setNumber;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;
  final double? rpe;
  final int? restSeconds;
  final String? tempo;
  final String? notes;
  final bool isCompleted;
  final DateTime? completedAt;
  final SetType type;
  final bool isPersonalRecord;

  double get volume => (weight ?? 0) * (reps ?? 0);

  @override
  List<Object?> get props => [
        id,
        setNumber,
        weight,
        reps,
        durationSeconds,
        distanceMeters,
        rpe,
        restSeconds,
        tempo,
        notes,
        isCompleted,
        completedAt,
        type,
        isPersonalRecord,
      ];

  WorkoutSetEntity copyWith({
    String? id,
    int? setNumber,
    double? weight,
    int? reps,
    int? durationSeconds,
    double? distanceMeters,
    double? rpe,
    int? restSeconds,
    String? tempo,
    String? notes,
    bool? isCompleted,
    DateTime? completedAt,
    SetType? type,
    bool? isPersonalRecord,
  }) {
    return WorkoutSetEntity(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      rpe: rpe ?? this.rpe,
      restSeconds: restSeconds ?? this.restSeconds,
      tempo: tempo ?? this.tempo,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      type: type ?? this.type,
      isPersonalRecord: isPersonalRecord ?? this.isPersonalRecord,
    );
  }
}
