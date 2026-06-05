import 'package:equatable/equatable.dart';
import 'package:level_bot/domain/entities/workout_set_entity.dart';

class SessionExercise extends Equatable {
  const SessionExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.order,
    required this.sets,
    this.notes,
    this.thumbnailUrl,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final int order;
  final List<WorkoutSetEntity> sets;
  final String? notes;
  final String? thumbnailUrl;

  List<WorkoutSetEntity> get completedSets =>
      sets.where((s) => s.isCompleted).toList();
  double get totalVolume =>
      completedSets.fold(0, (sum, set) => sum + set.volume);
  int get totalReps =>
      completedSets.fold(0, (sum, set) => sum + (set.reps ?? 0));

  @override
  List<Object?> get props => [id, exerciseId, order, sets];

  SessionExercise copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    int? order,
    List<WorkoutSetEntity>? sets,
    String? notes,
    String? thumbnailUrl,
  }) {
    return SessionExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}

enum WorkoutStatus { notStarted, inProgress, completed, cancelled }

class WorkoutSessionEntity extends Equatable {
  const WorkoutSessionEntity({
    required this.id,
    required this.userId,
    required this.exercises,
    this.programId,
    this.programName,
    this.workoutDayId,
    this.workoutDayName,
    this.name,
    this.notes,
    required this.startedAt,
    this.completedAt,
    this.status = WorkoutStatus.inProgress,
    this.durationSeconds = 0,
    this.bodyWeight,
    this.isShared = false,
    this.postId,
    this.personalRecords = const [],
  });

  final String id;
  final String userId;
  final List<SessionExercise> exercises;
  final String? programId;
  final String? programName;
  final String? workoutDayId;
  final String? workoutDayName;
  final String? name;
  final String? notes;
  final DateTime startedAt;
  final DateTime? completedAt;
  final WorkoutStatus status;
  final int durationSeconds;
  final double? bodyWeight;
  final bool isShared;
  final String? postId;
  final List<String> personalRecords;

  double get totalVolume =>
      exercises.fold(0, (sum, ex) => sum + ex.totalVolume);
  int get totalSets =>
      exercises.fold(0, (sum, ex) => sum + ex.completedSets.length);
  int get totalReps => exercises.fold(0, (sum, ex) => sum + ex.totalReps);
  int get totalExercises => exercises.length;
  Duration get duration => Duration(seconds: durationSeconds);

  @override
  List<Object?> get props => [
        id,
        userId,
        exercises,
        programId,
        startedAt,
        completedAt,
        status,
        durationSeconds,
      ];

  WorkoutSessionEntity copyWith({
    String? id,
    String? userId,
    List<SessionExercise>? exercises,
    String? programId,
    String? programName,
    String? workoutDayId,
    String? workoutDayName,
    String? name,
    String? notes,
    DateTime? startedAt,
    DateTime? completedAt,
    WorkoutStatus? status,
    int? durationSeconds,
    double? bodyWeight,
    bool? isShared,
    String? postId,
    List<String>? personalRecords,
  }) {
    return WorkoutSessionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      exercises: exercises ?? this.exercises,
      programId: programId ?? this.programId,
      programName: programName ?? this.programName,
      workoutDayId: workoutDayId ?? this.workoutDayId,
      workoutDayName: workoutDayName ?? this.workoutDayName,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      bodyWeight: bodyWeight ?? this.bodyWeight,
      isShared: isShared ?? this.isShared,
      postId: postId ?? this.postId,
      personalRecords: personalRecords ?? this.personalRecords,
    );
  }
}
