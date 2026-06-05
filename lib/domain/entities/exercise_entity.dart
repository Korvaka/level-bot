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

class ExerciseVideo extends Equatable {
  const ExerciseVideo({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.description,
    this.angle,
    this.isPrimary = false,
    required this.uploadedAt,
  });

  final String id;
  final String url;
  final String? thumbnailUrl;
  final String? description;
  final String? angle;
  final bool isPrimary;
  final DateTime uploadedAt;

  @override
  List<Object?> get props => [id, url, isPrimary];

  ExerciseVideo copyWith({
    String? id,
    String? url,
    String? thumbnailUrl,
    String? description,
    String? angle,
    bool? isPrimary,
    DateTime? uploadedAt,
  }) {
    return ExerciseVideo(
      id: id ?? this.id,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      angle: angle ?? this.angle,
      isPrimary: isPrimary ?? this.isPrimary,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'url': url,
    'thumbnailUrl': thumbnailUrl,
    'description': description,
    'angle': angle,
    'isPrimary': isPrimary,
    'uploadedAt': uploadedAt.toIso8601String(),
  };

  factory ExerciseVideo.fromMap(Map<String, dynamic> map) => ExerciseVideo(
    id: map['id'] as String? ?? '',
    url: map['url'] as String? ?? '',
    thumbnailUrl: map['thumbnailUrl'] as String?,
    description: map['description'] as String?,
    angle: map['angle'] as String?,
    isPrimary: map['isPrimary'] as bool? ?? false,
    uploadedAt: map['uploadedAt'] != null
        ? DateTime.tryParse(map['uploadedAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );
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
    this.commonMistakes = const [],
    this.isCustom = false,
    this.createdBy,
    this.aliases = const [],
    this.videos = const [],
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
  final List<String> commonMistakes;
  final bool isCustom;
  final String? createdBy;
  final List<String> aliases;
  final List<ExerciseVideo> videos;

  ExerciseVideo? get primaryVideo =>
      videos.where((v) => v.isPrimary).firstOrNull ?? videos.firstOrNull;

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
