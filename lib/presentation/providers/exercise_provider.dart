import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/data/datasources/remote/exercise_remote_datasource.dart';
import 'package:level_bot/data/repositories/exercise_repository_impl.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/domain/repositories/exercise_repository.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';

final exerciseRemoteDataSourceProvider =
    Provider<ExerciseRemoteDataSource>((ref) {
  return ExerciseRemoteDataSourceImpl(
    firestore: ref.read(firestoreProvider),
  );
});

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepositoryImpl(
    remoteDataSource: ref.read(exerciseRemoteDataSourceProvider),
  );
});

final allExercisesProvider = FutureProvider<List<ExerciseEntity>>((ref) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  final result = await repo.getAllExercises();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (exercises) => exercises,
  );
});

final exercisesByMuscleGroupProvider =
    FutureProvider.family<List<ExerciseEntity>, MuscleGroup>(
        (ref, muscleGroup) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  final result = await repo.getExercisesByMuscleGroup(muscleGroup);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (exercises) => exercises,
  );
});

final exerciseSearchQueryProvider = StateProvider<String>((ref) => '');

final exerciseFilterMuscleProvider =
    StateProvider<MuscleGroup?>((ref) => null);

final exerciseFilterEquipmentProvider =
    StateProvider<Equipment?>((ref) => null);

final filteredExercisesProvider = Provider<AsyncValue<List<ExerciseEntity>>>(
  (ref) {
    final query = ref.watch(exerciseSearchQueryProvider);
    final muscleFilter = ref.watch(exerciseFilterMuscleProvider);
    final equipmentFilter = ref.watch(exerciseFilterEquipmentProvider);
    final allExercises = ref.watch(allExercisesProvider);

    return allExercises.whenData((exercises) {
      var filtered = exercises;

      if (query.isNotEmpty) {
        final lower = query.toLowerCase();
        filtered = filtered
            .where((e) =>
                e.name.toLowerCase().contains(lower) ||
                e.aliases.any((a) => a.toLowerCase().contains(lower)))
            .toList();
      }

      if (muscleFilter != null) {
        filtered = filtered
            .where((e) =>
                e.primaryMuscle == muscleFilter ||
                e.secondaryMuscles.contains(muscleFilter))
            .toList();
      }

      if (equipmentFilter != null) {
        filtered =
            filtered.where((e) => e.equipment == equipmentFilter).toList();
      }

      return filtered;
    });
  },
);

final exerciseByIdProvider =
    FutureProvider.family<ExerciseEntity, String>((ref, exerciseId) async {
  final repo = ref.watch(exerciseRepositoryProvider);
  final result = await repo.getExerciseById(exerciseId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (exercise) => exercise,
  );
});

// Notifier for actions (create, delete custom exercises)
final exerciseNotifierProvider =
    StateNotifierProvider<ExerciseNotifier, AsyncValue<void>>(
  (ref) => ExerciseNotifier(ref.read(exerciseRepositoryProvider), ref),
);

class ExerciseNotifier extends StateNotifier<AsyncValue<void>> {
  ExerciseNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  final ExerciseRepository _repository;
  final Ref _ref;

  Future<String?> createCustomExercise(ExerciseEntity exercise) async {
    state = const AsyncValue.loading();
    final result = await _repository.createCustomExercise(exercise);
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (_) {
        state = const AsyncValue.data(null);
        _ref.invalidate(allExercisesProvider);
        return null;
      },
    );
  }
}
