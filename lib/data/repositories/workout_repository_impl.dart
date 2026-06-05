import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/exceptions.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/data/datasources/remote/workout_remote_datasource.dart';
import 'package:level_bot/data/models/workout_session_model.dart';
import 'package:level_bot/domain/entities/personal_record_entity.dart';
import 'package:level_bot/domain/entities/workout_session_entity.dart';
import 'package:level_bot/domain/repositories/workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl({required WorkoutRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final WorkoutRemoteDataSource _remote;

  @override
  Future<Either<Failure, WorkoutSessionEntity>> createWorkoutSession(
      WorkoutSessionEntity session) async {
    try {
      final model = WorkoutSessionModel.fromEntity(session);
      final created = await _remote.createWorkoutSession(model);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSessionEntity>> updateWorkoutSession(
      WorkoutSessionEntity session) async {
    try {
      final model = WorkoutSessionModel.fromEntity(session);
      final updated = await _remote.updateWorkoutSession(model);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> completeWorkoutSession(
      WorkoutSessionEntity session) async {
    try {
      final model = WorkoutSessionModel.fromEntity(session);
      await _remote.completeWorkoutSession(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelWorkoutSession(
      String sessionId) async {
    try {
      await _remote.cancelWorkoutSession(sessionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WorkoutSessionEntity>>> getWorkoutHistory({
    required String userId,
    int limit = 20,
    String? lastSessionId,
  }) async {
    try {
      final sessions = await _remote.getWorkoutHistory(
        userId: userId,
        limit: limit,
        lastSessionId: lastSessionId,
      );
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSessionEntity>> getWorkoutSessionById(
      String sessionId) async {
    try {
      final session = await _remote.getWorkoutSessionById(sessionId);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PersonalRecordEntity>>> getPersonalRecords(
      String userId) async {
    try {
      final records = await _remote.getPersonalRecords(userId);
      return Right(records);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PersonalRecordEntity>>> getExercisePRs({
    required String userId,
    required String exerciseId,
  }) async {
    try {
      final records = await _remote.getExercisePRs(
        userId: userId,
        exerciseId: exerciseId,
      );
      return Right(records);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, WorkoutSessionEntity?>> getActiveSession(
      String userId) async {
    try {
      final session = await _remote.getActiveSession(userId);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
