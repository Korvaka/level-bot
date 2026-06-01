import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/exceptions.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/data/datasources/remote/program_remote_datasource.dart';
import 'package:level_bot/data/models/program_model.dart';
import 'package:level_bot/domain/entities/program_entity.dart';
import 'package:level_bot/domain/repositories/program_repository.dart';

class ProgramRepositoryImpl implements ProgramRepository {
  ProgramRepositoryImpl({required ProgramRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final ProgramRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<ProgramEntity>>> getUserPrograms(
      String userId) async {
    try {
      final programs = await _remote.getUserPrograms(userId);
      return Right(programs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgramEntity>> getProgramById(
      String programId) async {
    try {
      final program = await _remote.getProgramById(programId);
      return Right(program);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgramEntity>> createProgram(
      ProgramEntity program) async {
    try {
      final model = ProgramModel.fromEntity(program);
      final created = await _remote.createProgram(model);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgramEntity>> updateProgram(
      ProgramEntity program) async {
    try {
      final model = ProgramModel.fromEntity(program);
      final updated = await _remote.updateProgram(model);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProgram(String programId) async {
    try {
      await _remote.deleteProgram(programId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProgramEntity>> duplicateProgram(
      String programId) async {
    try {
      final program = await _remote.duplicateProgram(programId);
      return Right(program);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> archiveProgram(String programId) async {
    try {
      await _remote.archiveProgram(programId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unarchiveProgram(String programId) async {
    try {
      await _remote.unarchiveProgram(programId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProgramEntity>>> getPublicPrograms({
    int limit = 20,
    String? lastProgramId,
  }) async {
    try {
      final programs = await _remote.getPublicPrograms(
        limit: limit,
        lastProgramId: lastProgramId,
      );
      return Right(programs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProgramEntity>>> searchPublicPrograms(
      String query) async {
    try {
      final programs = await _remote.searchPublicPrograms(query);
      return Right(programs);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveProgram({
    required String userId,
    required String programId,
  }) async {
    try {
      await _remote.saveProgram(userId: userId, programId: programId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likeProgram({
    required String userId,
    required String programId,
  }) async {
    try {
      await _remote.likeProgram(userId: userId, programId: programId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikeProgram({
    required String userId,
    required String programId,
  }) async {
    try {
      await _remote.unlikeProgram(userId: userId, programId: programId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
