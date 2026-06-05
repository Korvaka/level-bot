import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:level_bot/data/datasources/remote/program_remote_datasource.dart';
import 'package:level_bot/data/repositories/program_repository_impl.dart';
import 'package:level_bot/domain/entities/program_entity.dart';
import 'package:level_bot/domain/repositories/program_repository.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';

final programRemoteDataSourceProvider =
    Provider<ProgramRemoteDataSource>((ref) {
  return ProgramRemoteDataSourceImpl(
    firestore: ref.read(firestoreProvider),
  );
});

final programRepositoryProvider = Provider<ProgramRepository>((ref) {
  return ProgramRepositoryImpl(
    remoteDataSource: ref.read(programRemoteDataSourceProvider),
  );
});

final userProgramsProvider =
    FutureProvider.family<List<ProgramEntity>, String>((ref, userId) async {
  final repo = ref.watch(programRepositoryProvider);
  final result = await repo.getUserPrograms(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (programs) => programs,
  );
});

final publicProgramsProvider =
    FutureProvider<List<ProgramEntity>>((ref) async {
  final repo = ref.watch(programRepositoryProvider);
  final result = await repo.getPublicPrograms();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (programs) => programs,
  );
});

final programByIdProvider =
    FutureProvider.family<ProgramEntity, String>((ref, programId) async {
  final repo = ref.watch(programRepositoryProvider);
  final result = await repo.getProgramById(programId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (program) => program,
  );
});

final selectedProgramProvider = StateProvider<ProgramEntity?>((ref) => null);

final programsNotifierProvider =
    StateNotifierProvider<ProgramsNotifier, AsyncValue<List<ProgramEntity>>>(
        (ref) {
  final repo = ref.read(programRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id ?? '';
  return ProgramsNotifier(repo, userId);
});

class ProgramsNotifier
    extends StateNotifier<AsyncValue<List<ProgramEntity>>> {
  ProgramsNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId.isNotEmpty) load();
  }

  final ProgramRepository _repository;
  final String _userId;

  Future<void> load() async {
    state = const AsyncValue.loading();
    final result = await _repository.getUserPrograms(_userId);
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (programs) => state = AsyncValue.data(programs),
    );
  }

  Future<String?> createProgram(ProgramEntity program) async {
    final result = await _repository.createProgram(program);
    return result.fold(
      (failure) => failure.message,
      (created) {
        state = state.whenData((programs) => [created, ...programs]);
        return null;
      },
    );
  }

  Future<String?> updateProgram(ProgramEntity program) async {
    final result = await _repository.updateProgram(program);
    return result.fold(
      (failure) => failure.message,
      (updated) {
        state = state.whenData((programs) => programs
            .map((p) => p.id == updated.id ? updated : p)
            .toList());
        return null;
      },
    );
  }

  Future<String?> deleteProgram(String programId) async {
    final result = await _repository.deleteProgram(programId);
    return result.fold(
      (failure) => failure.message,
      (_) {
        state = state.whenData(
            (programs) => programs.where((p) => p.id != programId).toList());
        return null;
      },
    );
  }

  Future<String?> duplicateProgram(String programId) async {
    final result = await _repository.duplicateProgram(programId);
    return result.fold(
      (failure) => failure.message,
      (duplicate) {
        state = state.whenData((programs) => [duplicate, ...programs]);
        return null;
      },
    );
  }

  Future<String?> archiveProgram(String programId) async {
    final result = await _repository.archiveProgram(programId);
    return result.fold(
      (failure) => failure.message,
      (_) {
        state = state.whenData(
            (programs) => programs.where((p) => p.id != programId).toList());
        return null;
      },
    );
  }
}
