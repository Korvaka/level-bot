import 'package:equatable/equatable.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/entities/workout_set_entity.dart';

class ProgramExercise extends Equatable {
  const ProgramExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.order,
    required this.sets,
    this.notes,
    this.supersetWith,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final int order;
  final List<WorkoutSetEntity> sets;
  final String? notes;
  final String? supersetWith;

  int get totalSets => sets.length;
  double get totalVolume => sets.fold(0, (sum, set) => sum + set.volume);

  @override
  List<Object?> get props => [id, exerciseId, order, sets];

  ProgramExercise copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    int? order,
    List<WorkoutSetEntity>? sets,
    String? notes,
    String? supersetWith,
  }) {
    return ProgramExercise(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      notes: notes ?? this.notes,
      supersetWith: supersetWith ?? this.supersetWith,
    );
  }
}

class WorkoutDay extends Equatable {
  const WorkoutDay({
    required this.id,
    required this.name,
    required this.order,
    required this.exercises,
    this.notes,
    this.targetMuscleGroups = const [],
    this.estimatedMinutes,
  });

  final String id;
  final String name;
  final int order;
  final List<ProgramExercise> exercises;
  final String? notes;
  final List<MuscleGroup> targetMuscleGroups;
  final int? estimatedMinutes;

  int get totalExercises => exercises.length;
  int get totalSets => exercises.fold(0, (sum, e) => sum + e.totalSets);

  @override
  List<Object?> get props => [id, name, order, exercises];

  WorkoutDay copyWith({
    String? id,
    String? name,
    int? order,
    List<ProgramExercise>? exercises,
    String? notes,
    List<MuscleGroup>? targetMuscleGroups,
    int? estimatedMinutes,
  }) {
    return WorkoutDay(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      exercises: exercises ?? this.exercises,
      notes: notes ?? this.notes,
      targetMuscleGroups: targetMuscleGroups ?? this.targetMuscleGroups,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }
}

enum ProgramGoal {
  strength,
  hypertrophy,
  endurance,
  powerlifting,
  weightLoss,
  athletic,
  general,
}

enum ProgramDuration { weeks4, weeks6, weeks8, weeks12, weeks16, ongoing }

class ProgramEntity extends Equatable {
  const ProgramEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.days,
    this.description,
    this.imageUrl,
    this.goal = ProgramGoal.general,
    this.duration = ProgramDuration.weeks8,
    this.daysPerWeek = 3,
    this.difficulty = DifficultyLevel.intermediate,
    this.isPublic = false,
    this.isArchived = false,
    this.likesCount = 0,
    this.savesCount = 0,
    this.usersCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.equipment = const [],
  });

  final String id;
  final String userId;
  final String name;
  final List<WorkoutDay> days;
  final String? description;
  final String? imageUrl;
  final ProgramGoal goal;
  final ProgramDuration duration;
  final int daysPerWeek;
  final DifficultyLevel difficulty;
  final bool isPublic;
  final bool isArchived;
  final int likesCount;
  final int savesCount;
  final int usersCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final List<Equipment> equipment;

  int get totalExercises =>
      days.fold(0, (sum, day) => sum + day.totalExercises);
  int get totalSets => days.fold(0, (sum, day) => sum + day.totalSets);

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        days,
        goal,
        duration,
        isPublic,
        isArchived,
        createdAt,
      ];

  ProgramEntity copyWith({
    String? id,
    String? userId,
    String? name,
    List<WorkoutDay>? days,
    String? description,
    String? imageUrl,
    ProgramGoal? goal,
    ProgramDuration? duration,
    int? daysPerWeek,
    DifficultyLevel? difficulty,
    bool? isPublic,
    bool? isArchived,
    int? likesCount,
    int? savesCount,
    int? usersCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    List<Equipment>? equipment,
  }) {
    return ProgramEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      days: days ?? this.days,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      goal: goal ?? this.goal,
      duration: duration ?? this.duration,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      difficulty: difficulty ?? this.difficulty,
      isPublic: isPublic ?? this.isPublic,
      isArchived: isArchived ?? this.isArchived,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      usersCount: usersCount ?? this.usersCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      equipment: equipment ?? this.equipment,
    );
  }
}
