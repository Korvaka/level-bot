import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:level_bot/data/datasources/remote/workout_remote_datasource.dart';
import 'package:level_bot/data/repositories/workout_repository_impl.dart';
import 'package:level_bot/domain/entities/personal_record_entity.dart';
import 'package:level_bot/domain/entities/workout_session_entity.dart';
import 'package:level_bot/domain/repositories/workout_repository.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:uuid/uuid.dart';

final workoutRemoteDataSourceProvider =
    Provider<WorkoutRemoteDataSource>((ref) {
  return WorkoutRemoteDataSourceImpl(
    firestore: ref.read(firestoreProvider),
  );
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(
    remoteDataSource: ref.read(workoutRemoteDataSourceProvider),
  );
});

final workoutHistoryProvider =
    FutureProvider.family<List<WorkoutSessionEntity>, String>((ref, userId) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final result = await repo.getWorkoutHistory(userId: userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (sessions) => sessions,
  );
});

final personalRecordsProvider =
    FutureProvider.family<List<PersonalRecordEntity>, String>((ref, userId) async {
  final repo = ref.watch(workoutRepositoryProvider);
  final result = await repo.getPersonalRecords(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (records) => records,
  );
});

// Active workout state
final activeWorkoutProvider =
    StateNotifierProvider<ActiveWorkoutNotifier, ActiveWorkoutState>((ref) {
  final repo = ref.read(workoutRepositoryProvider);
  return ActiveWorkoutNotifier(repo);
});

class ActiveWorkoutState {
  const ActiveWorkoutState({
    this.session,
    this.isActive = false,
    this.elapsedSeconds = 0,
    this.restTimerSeconds = 0,
    this.isRestTimerRunning = false,
    this.isLoading = false,
    this.error,
  });

  final WorkoutSessionEntity? session;
  final bool isActive;
  final int elapsedSeconds;
  final int restTimerSeconds;
  final bool isRestTimerRunning;
  final bool isLoading;
  final String? error;

  ActiveWorkoutState copyWith({
    WorkoutSessionEntity? session,
    bool? isActive,
    int? elapsedSeconds,
    int? restTimerSeconds,
    bool? isRestTimerRunning,
    bool? isLoading,
    String? error,
  }) {
    return ActiveWorkoutState(
      session: session ?? this.session,
      isActive: isActive ?? this.isActive,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      restTimerSeconds: restTimerSeconds ?? this.restTimerSeconds,
      isRestTimerRunning: isRestTimerRunning ?? this.isRestTimerRunning,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ActiveWorkoutNotifier extends StateNotifier<ActiveWorkoutState> {
  ActiveWorkoutNotifier(this._repository) : super(const ActiveWorkoutState());

  final WorkoutRepository _repository;
  Timer? _elapsedTimer;
  Timer? _restTimer;
  final _uuid = const Uuid();

  void startWorkout({
    required String userId,
    WorkoutSessionEntity? templateSession,
  }) {
    final session = templateSession ??
        WorkoutSessionEntity(
          id: _uuid.v4(),
          userId: userId,
          exercises: const [],
          startedAt: DateTime.now(),
          status: WorkoutStatus.inProgress,
        );

    state = state.copyWith(
      session: session,
      isActive: true,
      elapsedSeconds: 0,
    );

    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void startRestTimer(int seconds) {
    _restTimer?.cancel();
    state = state.copyWith(
      restTimerSeconds: seconds,
      isRestTimerRunning: true,
    );
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.restTimerSeconds <= 0) {
        _restTimer?.cancel();
        state = state.copyWith(isRestTimerRunning: false, restTimerSeconds: 0);
      } else {
        state = state.copyWith(restTimerSeconds: state.restTimerSeconds - 1);
      }
    });
  }

  void stopRestTimer() {
    _restTimer?.cancel();
    state = state.copyWith(isRestTimerRunning: false, restTimerSeconds: 0);
  }

  void addExercise(SessionExercise exercise) {
    if (state.session == null) return;
    final updated = state.session!.copyWith(
      exercises: [...state.session!.exercises, exercise],
    );
    state = state.copyWith(session: updated);
  }

  void removeExercise(String exerciseId) {
    if (state.session == null) return;
    final updated = state.session!.copyWith(
      exercises: state.session!.exercises
          .where((e) => e.id != exerciseId)
          .toList(),
    );
    state = state.copyWith(session: updated);
  }

  void updateSet({
    required String exerciseId,
    required String setId,
    double? weight,
    int? reps,
    double? rpe,
    bool? isCompleted,
  }) {
    if (state.session == null) return;

    final exercises = state.session!.exercises.map((ex) {
      if (ex.id != exerciseId) return ex;
      final sets = ex.sets.map((s) {
        if (s.id != setId) return s;
        return s.copyWith(
          weight: weight ?? s.weight,
          reps: reps ?? s.reps,
          rpe: rpe ?? s.rpe,
          isCompleted: isCompleted ?? s.isCompleted,
          completedAt:
              isCompleted == true ? DateTime.now() : s.completedAt,
        );
      }).toList();
      return ex.copyWith(sets: sets);
    }).toList();

    final updated = state.session!.copyWith(exercises: exercises);
    state = state.copyWith(session: updated);
  }

  void addSet({required String exerciseId, required workoutSetEntity}) {
    if (state.session == null) return;

    final exercises = state.session!.exercises.map((ex) {
      if (ex.id != exerciseId) return ex;
      return ex.copyWith(sets: [...ex.sets, workoutSetEntity]);
    }).toList();

    final updated = state.session!.copyWith(exercises: exercises);
    state = state.copyWith(session: updated);
  }

  void removeSet({required String exerciseId, required String setId}) {
    if (state.session == null) return;

    final exercises = state.session!.exercises.map((ex) {
      if (ex.id != exerciseId) return ex;
      final sets = ex.sets.where((s) => s.id != setId).toList();
      return ex.copyWith(sets: sets);
    }).toList();

    final updated = state.session!.copyWith(exercises: exercises);
    state = state.copyWith(session: updated);
  }

  void updateNotes(String notes) {
    if (state.session == null) return;
    final updated = state.session!.copyWith(notes: notes);
    state = state.copyWith(session: updated);
  }

  Future<String?> completeWorkout() async {
    if (state.session == null) return 'No active workout';

    state = state.copyWith(isLoading: true);
    _elapsedTimer?.cancel();
    _restTimer?.cancel();

    final completedSession = state.session!.copyWith(
      status: WorkoutStatus.completed,
      durationSeconds: state.elapsedSeconds,
      completedAt: DateTime.now(),
    );

    final result = await _repository.completeWorkoutSession(completedSession);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return failure.message;
      },
      (_) {
        state = const ActiveWorkoutState();
        return null;
      },
    );
  }

  Future<void> cancelWorkout() async {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();

    if (state.session != null) {
      await _repository.cancelWorkoutSession(state.session!.id);
    }

    state = const ActiveWorkoutState();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}
