import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/exceptions.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/data/datasources/remote/exercise_remote_datasource.dart';
import 'package:level_bot/data/models/exercise_model.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/repositories/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  ExerciseRepositoryImpl({required ExerciseRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final ExerciseRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ExerciseEntity>>> getAllExercises() async {
    try {
      final exercises = await _remote.getAllExercises();
      return Right(exercises);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExerciseEntity>>> getExercisesByMuscleGroup(
      MuscleGroup muscleGroup) async {
    try {
      final exercises = await _remote.getExercisesByMuscleGroup(muscleGroup);
      return Right(exercises);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExerciseEntity>>> getExercisesByEquipment(
      Equipment equipment) async {
    try {
      final exercises = await _remote.getExercisesByEquipment(equipment);
      return Right(exercises);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExerciseEntity>>> searchExercises(
      String query) async {
    try {
      final exercises = await _remote.searchExercises(query);
      return Right(exercises);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExerciseEntity>> getExerciseById(
      String exerciseId) async {
    try {
      final exercise = await _remote.getExerciseById(exerciseId);
      return Right(exercise);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExerciseEntity>> createCustomExercise(
      ExerciseEntity exercise) async {
    try {
      final model = ExerciseModel.fromEntity(exercise);
      final created = await _remote.createCustomExercise(model);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExerciseEntity>> updateExercise(
      ExerciseEntity exercise) async {
    try {
      final model = ExerciseModel.fromEntity(exercise);
      final updated = await _remote.updateExercise(model);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExercise(String exerciseId) async {
    try {
      await _remote.deleteExercise(exerciseId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExerciseEntity>>> getFavoriteExercises(
      String userId) async {
    // TODO: implement local favorites tracking
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> toggleFavorite({
    required String userId,
    required String exerciseId,
  }) async {
    // TODO: implement local favorites toggle
    return const Right(null);
  }
}
