import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.description,
    required super.primaryMuscle,
    required super.secondaryMuscles,
    required super.equipment,
    required super.category,
    required super.difficulty,
    required super.instructions,
    super.gifUrl,
    super.videoUrl,
    super.thumbnailUrl,
    super.tips,
    super.commonMistakes,
    super.isCustom,
    super.createdBy,
    super.aliases,
    super.videos,
  });

  factory ExerciseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExerciseModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      primaryMuscle: MuscleGroup.values.firstWhere(
        (e) =>
            e.name == (data['primaryMuscle'] as String?) ||
            e.name == (data['muscleGroup'] as String?),
        orElse: () => MuscleGroup.chest,
      ),
      secondaryMuscles: (data['secondaryMuscles'] as List? ?? [])
          .map((e) => MuscleGroup.values.firstWhere(
                (m) => m.name == e,
                orElse: () => MuscleGroup.chest,
              ))
          .toList(),
      equipment: Equipment.values.firstWhere(
        (e) => e.name == (data['equipment'] as String?),
        orElse: () => Equipment.none,
      ),
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == (data['category'] as String?),
        orElse: () => ExerciseCategory.compound,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == (data['difficulty'] as String?),
        orElse: () => DifficultyLevel.intermediate,
      ),
      instructions: List<String>.from(data['instructions'] as List? ?? []),
      gifUrl: data['gifUrl'] as String?,
      videoUrl: data['videoUrl'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      tips: List<String>.from(data['tips'] as List? ?? []),
      commonMistakes: List<String>.from(data['commonMistakes'] as List? ?? []),
      isCustom: data['isCustom'] as bool? ?? false,
      createdBy: data['createdBy'] as String?,
      aliases: List<String>.from(data['aliases'] as List? ?? []),
      videos: (data['videos'] as List? ?? [])
          .map((v) => ExerciseVideo.fromMap(v as Map<String, dynamic>))
          .toList(),
    );
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> data, String id) {
    return ExerciseModel(
      id: id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      primaryMuscle: MuscleGroup.values.firstWhere(
        (e) =>
            e.name == (data['primaryMuscle'] as String?) ||
            e.name == (data['muscleGroup'] as String?),
        orElse: () => MuscleGroup.chest,
      ),
      secondaryMuscles: (data['secondaryMuscles'] as List? ?? [])
          .map((e) => MuscleGroup.values.firstWhere(
                (m) => m.name == e,
                orElse: () => MuscleGroup.chest,
              ))
          .toList(),
      equipment: Equipment.values.firstWhere(
        (e) => e.name == (data['equipment'] as String?),
        orElse: () => Equipment.none,
      ),
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == (data['category'] as String?),
        orElse: () => ExerciseCategory.compound,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == (data['difficulty'] as String?),
        orElse: () => DifficultyLevel.intermediate,
      ),
      instructions: List<String>.from(data['instructions'] as List? ?? []),
      gifUrl: data['gifUrl'] as String?,
      videoUrl: data['videoUrl'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      tips: List<String>.from(data['tips'] as List? ?? []),
      commonMistakes: List<String>.from(data['commonMistakes'] as List? ?? []),
      isCustom: data['isCustom'] as bool? ?? false,
      createdBy: data['createdBy'] as String?,
      aliases: List<String>.from(data['aliases'] as List? ?? []),
      videos: (data['videos'] as List? ?? [])
          .map((v) => ExerciseVideo.fromMap(v as Map<String, dynamic>))
          .toList(),
    );
  }

  factory ExerciseModel.fromEntity(ExerciseEntity entity) {
    return ExerciseModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      primaryMuscle: entity.primaryMuscle,
      secondaryMuscles: entity.secondaryMuscles,
      equipment: entity.equipment,
      category: entity.category,
      difficulty: entity.difficulty,
      instructions: entity.instructions,
      gifUrl: entity.gifUrl,
      videoUrl: entity.videoUrl,
      thumbnailUrl: entity.thumbnailUrl,
      tips: entity.tips,
      commonMistakes: entity.commonMistakes,
      isCustom: entity.isCustom,
      createdBy: entity.createdBy,
      aliases: entity.aliases,
      videos: entity.videos,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'primaryMuscle': primaryMuscle.name,
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
      'equipment': equipment.name,
      'category': category.name,
      'difficulty': difficulty.name,
      'instructions': instructions,
      'gifUrl': gifUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'tips': tips,
      'commonMistakes': commonMistakes,
      'isCustom': isCustom,
      'createdBy': createdBy,
      'aliases': aliases,
      'videos': videos.map((v) => v.toMap()).toList(),
    };
  }
}
