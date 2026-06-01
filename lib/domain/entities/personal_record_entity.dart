import 'package:equatable/equatable.dart';

enum PRType { maxWeight, maxReps, maxVolume, maxDuration, maxDistance }

class PersonalRecordEntity extends Equatable {
  const PersonalRecordEntity({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.exerciseName,
    required this.type,
    required this.value,
    this.reps,
    this.weight,
    required this.achievedAt,
    this.workoutSessionId,
    this.previousValue,
    this.improvementPercent,
  });

  final String id;
  final String userId;
  final String exerciseId;
  final String exerciseName;
  final PRType type;
  final double value;
  final int? reps;
  final double? weight;
  final DateTime achievedAt;
  final String? workoutSessionId;
  final double? previousValue;
  final double? improvementPercent;

  @override
  List<Object?> get props => [
        id,
        userId,
        exerciseId,
        type,
        value,
        achievedAt,
      ];
}
