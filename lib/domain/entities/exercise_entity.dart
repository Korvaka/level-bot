import 'package:equatable/equatable.dart';

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  abs,
  quads,
  hamstrings,
  glutes,
  calves,
  cardio,
  fullBody,
}

enum Equipment {
  barbell,
  dumbbell,
  machine,
  cable,
  bodyweight,
  resistanceBand,
  kettlebell,
  ezBar,
  trapBar,
  smithMachine,
  cardioMachine,
  none,
}

enum ExerciseCategory {
  compound,
  isolation,
  cardio,
  stretching,
  plyometric,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

class ExerciseEntity extends Equatable {
  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.category,
    required this.difficulty,
    required this.instructions,
    this.gifUrl,
    this.videoUrl,
    this.thumbnailUrl,
    this.tips = const [],
    this.isCustom = false,
    this.createdBy,
    this.aliases = const [],
  });

  final String id;
  final String name;
  final String description;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final Equipment equipment;
  final ExerciseCategory category;
  final DifficultyLevel difficulty;
  final List<String> instructions;
  final String? gifUrl;
  final String? videoUrl;
  final String? thumbnailUrl;
  final List<String> tips;
  final bool isCustom;
  final String? createdBy;
  final List<String> aliases;

  @override
  List<Object?> get props => [
        id,
        name,
        primaryMuscle,
        equipment,
        category,
        difficulty,
        isCustom,
        createdBy,
      ];
}
