import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/domain/entities/personal_record_entity.dart';

class PersonalRecordModel extends PersonalRecordEntity {
  const PersonalRecordModel({
    required super.id,
    required super.userId,
    required super.exerciseId,
    required super.exerciseName,
    required super.type,
    required super.value,
    super.reps,
    super.weight,
    required super.achievedAt,
    super.workoutSessionId,
    super.previousValue,
    super.improvementPercent,
  });

  factory PersonalRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PersonalRecordModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      exerciseId: data['exerciseId'] as String? ?? '',
      exerciseName: data['exerciseName'] as String? ?? '',
      type: PRType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => PRType.maxWeight,
      ),
      value: (data['value'] as num?)?.toDouble() ?? 0,
      reps: data['reps'] as int?,
      weight: (data['weight'] as num?)?.toDouble(),
      achievedAt:
          (data['achievedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      workoutSessionId: data['workoutSessionId'] as String?,
      previousValue: (data['previousValue'] as num?)?.toDouble(),
      improvementPercent: (data['improvementPercent'] as num?)?.toDouble(),
    );
  }

  factory PersonalRecordModel.fromEntity(PersonalRecordEntity entity) {
    return PersonalRecordModel(
      id: entity.id,
      userId: entity.userId,
      exerciseId: entity.exerciseId,
      exerciseName: entity.exerciseName,
      type: entity.type,
      value: entity.value,
      reps: entity.reps,
      weight: entity.weight,
      achievedAt: entity.achievedAt,
      workoutSessionId: entity.workoutSessionId,
      previousValue: entity.previousValue,
      improvementPercent: entity.improvementPercent,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'type': type.name,
      'value': value,
      'reps': reps,
      'weight': weight,
      'achievedAt': Timestamp.fromDate(achievedAt),
      'workoutSessionId': workoutSessionId,
      'previousValue': previousValue,
      'improvementPercent': improvementPercent,
    };
  }
}
