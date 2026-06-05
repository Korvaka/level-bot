import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/data/models/workout_set_model.dart';
import 'package:level_bot/domain/entities/workout_session_entity.dart';

class SessionExerciseModel extends SessionExercise {
  const SessionExerciseModel({
    required super.id,
    required super.exerciseId,
    required super.exerciseName,
    required super.order,
    required super.sets,
    super.notes,
    super.thumbnailUrl,
  });

  factory SessionExerciseModel.fromMap(Map<String, dynamic> data) {
    return SessionExerciseModel(
      id: data['id'] as String? ?? '',
      exerciseId: data['exerciseId'] as String? ?? '',
      exerciseName: data['exerciseName'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      sets: (data['sets'] as List? ?? [])
          .map((s) => WorkoutSetModel.fromMap(s as Map<String, dynamic>))
          .toList(),
      notes: data['notes'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
    );
  }

  factory SessionExerciseModel.fromEntity(SessionExercise entity) {
    return SessionExerciseModel(
      id: entity.id,
      exerciseId: entity.exerciseId,
      exerciseName: entity.exerciseName,
      order: entity.order,
      sets: entity.sets,
      notes: entity.notes,
      thumbnailUrl: entity.thumbnailUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'order': order,
      'sets': sets.map((s) => WorkoutSetModel.fromEntity(s).toMap()).toList(),
      'notes': notes,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}

class WorkoutSessionModel extends WorkoutSessionEntity {
  const WorkoutSessionModel({
    required super.id,
    required super.userId,
    required super.exercises,
    super.programId,
    super.programName,
    super.workoutDayId,
    super.workoutDayName,
    super.name,
    super.notes,
    required super.startedAt,
    super.completedAt,
    super.status,
    super.durationSeconds,
    super.bodyWeight,
    super.isShared,
    super.postId,
    super.personalRecords,
  });

  factory WorkoutSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutSessionModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      exercises: (data['exercises'] as List? ?? [])
          .map((e) =>
              SessionExerciseModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      programId: data['programId'] as String?,
      programName: data['programName'] as String?,
      workoutDayId: data['workoutDayId'] as String?,
      workoutDayName: data['workoutDayName'] as String?,
      name: data['name'] as String?,
      notes: data['notes'] as String?,
      startedAt:
          (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      status: WorkoutStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String?),
        orElse: () => WorkoutStatus.inProgress,
      ),
      durationSeconds: data['durationSeconds'] as int? ?? 0,
      bodyWeight: (data['bodyWeight'] as num?)?.toDouble(),
      isShared: data['isShared'] as bool? ?? false,
      postId: data['postId'] as String?,
      personalRecords:
          List<String>.from(data['personalRecords'] as List? ?? []),
    );
  }

  factory WorkoutSessionModel.fromEntity(WorkoutSessionEntity entity) {
    return WorkoutSessionModel(
      id: entity.id,
      userId: entity.userId,
      exercises: entity.exercises,
      programId: entity.programId,
      programName: entity.programName,
      workoutDayId: entity.workoutDayId,
      workoutDayName: entity.workoutDayName,
      name: entity.name,
      notes: entity.notes,
      startedAt: entity.startedAt,
      completedAt: entity.completedAt,
      status: entity.status,
      durationSeconds: entity.durationSeconds,
      bodyWeight: entity.bodyWeight,
      isShared: entity.isShared,
      postId: entity.postId,
      personalRecords: entity.personalRecords,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'exercises': exercises
          .map((e) => SessionExerciseModel.fromEntity(e).toMap())
          .toList(),
      'programId': programId,
      'programName': programName,
      'workoutDayId': workoutDayId,
      'workoutDayName': workoutDayName,
      'name': name,
      'notes': notes,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'status': status.name,
      'durationSeconds': durationSeconds,
      'bodyWeight': bodyWeight,
      'isShared': isShared,
      'postId': postId,
      'personalRecords': personalRecords,
    };
  }
}
