import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/domain/entities/program_entity.dart';

abstract class ProgramRepository {
  Future<Either<Failure, List<ProgramEntity>>> getUserPrograms(String userId);
  Future<Either<Failure, ProgramEntity>> getProgramById(String programId);
  Future<Either<Failure, ProgramEntity>> createProgram(ProgramEntity program);
  Future<Either<Failure, ProgramEntity>> updateProgram(ProgramEntity program);
  Future<Either<Failure, void>> deleteProgram(String programId);
  Future<Either<Failure, ProgramEntity>> duplicateProgram(String programId);
  Future<Either<Failure, void>> archiveProgram(String programId);
  Future<Either<Failure, void>> unarchiveProgram(String programId);
  Future<Either<Failure, List<ProgramEntity>>> getPublicPrograms({
    int limit = 20,
    String? lastProgramId,
  });
  Future<Either<Failure, List<ProgramEntity>>> searchPublicPrograms(
    String query,
  );
  Future<Either<Failure, void>> saveProgram({
    required String userId,
    required String programId,
  });
  Future<Either<Failure, void>> likeProgram({
    required String userId,
    required String programId,
  });
  Future<Either<Failure, void>> unlikeProgram({
    required String userId,
    required String programId,
  });
}
