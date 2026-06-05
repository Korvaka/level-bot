import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseFavoritesNotifier extends StateNotifier<Set<String>> {
  ExerciseFavoritesNotifier() : super({}) {
    _load();
  }

  static const _key = 'exercise_favorites';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = Set.from(prefs.getStringList(_key) ?? []);
  }

  Future<void> toggle(String exerciseId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(exerciseId)) {
      updated.remove(exerciseId);
    } else {
      updated.add(exerciseId);
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated.toList());
  }

  bool isFavorite(String exerciseId) => state.contains(exerciseId);
}

final exerciseFavoritesProvider =
    StateNotifierProvider<ExerciseFavoritesNotifier, Set<String>>(
  (ref) => ExerciseFavoritesNotifier(),
);

class RecentExercisesNotifier extends StateNotifier<List<String>> {
  RecentExercisesNotifier() : super([]) {
    _load();
  }

  static const _key = 'exercise_recent';
  static const _maxRecent = 10;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_key) ?? [];
  }

  Future<void> addRecent(String exerciseId) async {
    final updated = [exerciseId, ...state.where((e) => e != exerciseId)]
        .take(_maxRecent)
        .toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }

  Future<void> clear() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

final recentExercisesProvider =
    StateNotifierProvider<RecentExercisesNotifier, List<String>>(
  (ref) => RecentExercisesNotifier(),
);
