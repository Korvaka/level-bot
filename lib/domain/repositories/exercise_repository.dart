import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';

abstract class ExerciseRepository {
  Future<Either<Failure, List<ExerciseEntity>>> getAllExercises();
  Future<Either<Failure, List<ExerciseEntity>>> getExercisesByMuscleGroup(
    MuscleGroup muscleGroup,
  );
  Future<Either<Failure, List<ExerciseEntity>>> getExercisesByEquipment(
    Equipment equipment,
  );
  Future<Either<Failure, List<ExerciseEntity>>> searchExercises(String query);
  Future<Either<Failure, ExerciseEntity>> getExerciseById(String exerciseId);
  Future<Either<Failure, ExerciseEntity>> createCustomExercise(
    ExerciseEntity exercise,
  );
  Future<Either<Failure, ExerciseEntity>> updateExercise(
    ExerciseEntity exercise,
  );
  Future<Either<Failure, void>> deleteExercise(String exerciseId);
  Future<Either<Failure, List<ExerciseEntity>>> getFavoriteExercises(
    String userId,
  );
  Future<Either<Failure, void>> toggleFavorite({
    required String userId,
    required String exerciseId,
  });
}
