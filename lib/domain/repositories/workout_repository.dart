import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/domain/entities/personal_record_entity.dart';
import 'package:level_bot/domain/entities/workout_session_entity.dart';

abstract class WorkoutRepository {
  Future<Either<Failure, WorkoutSessionEntity>> createWorkoutSession(
    WorkoutSessionEntity session,
  );
  Future<Either<Failure, WorkoutSessionEntity>> updateWorkoutSession(
    WorkoutSessionEntity session,
  );
  Future<Either<Failure, void>> completeWorkoutSession(
    WorkoutSessionEntity session,
  );
  Future<Either<Failure, void>> cancelWorkoutSession(String sessionId);
  Future<Either<Failure, List<WorkoutSessionEntity>>> getWorkoutHistory({
    required String userId,
    int limit = 20,
    String? lastSessionId,
  });
  Future<Either<Failure, WorkoutSessionEntity>> getWorkoutSessionById(
    String sessionId,
  );
  Future<Either<Failure, List<PersonalRecordEntity>>> getPersonalRecords(
    String userId,
  );
  Future<Either<Failure, List<PersonalRecordEntity>>> getExercisePRs({
    required String userId,
    required String exerciseId,
  });
  Future<Either<Failure, WorkoutSessionEntity?>> getActiveSession(
    String userId,
  );
}
