import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/data/models/workout_set_model.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/entities/program_entity.dart';

class ProgramExerciseModel extends ProgramExercise {
  const ProgramExerciseModel({
    required super.id,
    required super.exerciseId,
    required super.exerciseName,
    required super.order,
    required super.sets,
    super.notes,
    super.supersetWith,
  });

  factory ProgramExerciseModel.fromMap(Map<String, dynamic> data) {
    return ProgramExerciseModel(
      id: data['id'] as String? ?? '',
      exerciseId: data['exerciseId'] as String? ?? '',
      exerciseName: data['exerciseName'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      sets: (data['sets'] as List? ?? [])
          .map((s) => WorkoutSetModel.fromMap(s as Map<String, dynamic>))
          .toList(),
      notes: data['notes'] as String?,
      supersetWith: data['supersetWith'] as String?,
    );
  }

  factory ProgramExerciseModel.fromEntity(ProgramExercise entity) {
    return ProgramExerciseModel(
      id: entity.id,
      exerciseId: entity.exerciseId,
      exerciseName: entity.exerciseName,
      order: entity.order,
      sets: entity.sets,
      notes: entity.notes,
      supersetWith: entity.supersetWith,
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
      'supersetWith': supersetWith,
    };
  }
}

class WorkoutDayModel extends WorkoutDay {
  const WorkoutDayModel({
    required super.id,
    required super.name,
    required super.order,
    required super.exercises,
    super.notes,
    super.targetMuscleGroups,
    super.estimatedMinutes,
  });

  factory WorkoutDayModel.fromMap(Map<String, dynamic> data) {
    return WorkoutDayModel(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      order: data['order'] as int? ?? 0,
      exercises: (data['exercises'] as List? ?? [])
          .map((e) =>
              ProgramExerciseModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      notes: data['notes'] as String?,
      targetMuscleGroups: (data['targetMuscleGroups'] as List? ?? [])
          .map((m) => MuscleGroup.values.firstWhere(
                (e) => e.name == m,
                orElse: () => MuscleGroup.chest,
              ))
          .toList(),
      estimatedMinutes: data['estimatedMinutes'] as int?,
    );
  }

  factory WorkoutDayModel.fromEntity(WorkoutDay entity) {
    return WorkoutDayModel(
      id: entity.id,
      name: entity.name,
      order: entity.order,
      exercises: entity.exercises,
      notes: entity.notes,
      targetMuscleGroups: entity.targetMuscleGroups,
      estimatedMinutes: entity.estimatedMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'order': order,
      'exercises': exercises
          .map((e) => ProgramExerciseModel.fromEntity(e).toMap())
          .toList(),
      'notes': notes,
      'targetMuscleGroups':
          targetMuscleGroups.map((m) => m.name).toList(),
      'estimatedMinutes': estimatedMinutes,
    };
  }
}

class ProgramModel extends ProgramEntity {
  const ProgramModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.days,
    super.description,
    super.imageUrl,
    super.goal,
    super.duration,
    super.daysPerWeek,
    super.difficulty,
    super.isPublic,
    super.isArchived,
    super.likesCount,
    super.savesCount,
    super.usersCount,
    required super.createdAt,
    super.updatedAt,
    super.tags,
    super.equipment,
  });

  factory ProgramModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgramModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      days: (data['days'] as List? ?? [])
          .map((d) => WorkoutDayModel.fromMap(d as Map<String, dynamic>))
          .toList(),
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      goal: ProgramGoal.values.firstWhere(
        (e) => e.name == (data['goal'] as String?),
        orElse: () => ProgramGoal.general,
      ),
      duration: ProgramDuration.values.firstWhere(
        (e) => e.name == (data['duration'] as String?),
        orElse: () => ProgramDuration.weeks8,
      ),
      daysPerWeek: data['daysPerWeek'] as int? ?? 3,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == (data['difficulty'] as String?),
        orElse: () => DifficultyLevel.intermediate,
      ),
      isPublic: data['isPublic'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
      likesCount: data['likesCount'] as int? ?? 0,
      savesCount: data['savesCount'] as int? ?? 0,
      usersCount: data['usersCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      tags: List<String>.from(data['tags'] as List? ?? []),
      equipment: (data['equipment'] as List? ?? [])
          .map((e) => Equipment.values.firstWhere(
                (eq) => eq.name == e,
                orElse: () => Equipment.barbell,
              ))
          .toList(),
    );
  }

  factory ProgramModel.fromEntity(ProgramEntity entity) {
    return ProgramModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      days: entity.days,
      description: entity.description,
      imageUrl: entity.imageUrl,
      goal: entity.goal,
      duration: entity.duration,
      daysPerWeek: entity.daysPerWeek,
      difficulty: entity.difficulty,
      isPublic: entity.isPublic,
      isArchived: entity.isArchived,
      likesCount: entity.likesCount,
      savesCount: entity.savesCount,
      usersCount: entity.usersCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      tags: entity.tags,
      equipment: entity.equipment,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'days': days.map((d) => WorkoutDayModel.fromEntity(d).toMap()).toList(),
      'description': description,
      'imageUrl': imageUrl,
      'goal': goal.name,
      'duration': duration.name,
      'daysPerWeek': daysPerWeek,
      'difficulty': difficulty.name,
      'isPublic': isPublic,
      'isArchived': isArchived,
      'likesCount': likesCount,
      'savesCount': savesCount,
      'usersCount': usersCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'tags': tags,
      'equipment': equipment.map((e) => e.name).toList(),
    };
  }
}
