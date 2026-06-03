import 'package:equatable/equatable.dart';

enum FitnessLevel { beginner, intermediate, advanced, elite }

enum FitnessGoal {
  loseWeight,
  buildMuscle,
  improveEndurance,
  increaseStrength,
  stayActive,
  athletic,
}

extension FitnessLevelExt on FitnessLevel {
  String get displayName {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Beginner';
      case FitnessLevel.intermediate:
        return 'Intermediate';
      case FitnessLevel.advanced:
        return 'Advanced';
      case FitnessLevel.elite:
        return 'Elite';
    }
  }
}

extension FitnessGoalExt on FitnessGoal {
  String get displayName {
    switch (this) {
      case FitnessGoal.loseWeight:
        return 'Lose Weight';
      case FitnessGoal.buildMuscle:
        return 'Build Muscle';
      case FitnessGoal.improveEndurance:
        return 'Endurance';
      case FitnessGoal.increaseStrength:
        return 'Strength';
      case FitnessGoal.stayActive:
        return 'Stay Active';
      case FitnessGoal.athletic:
        return 'Athletic';
    }
  }
}

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.photoUrl,
    this.bio,
    this.height,
    this.weight,
    this.age,
    this.level = FitnessLevel.beginner,
    this.goal = FitnessGoal.buildMuscle,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.workoutsCount = 0,
    this.programsCount = 0,
    this.totalWorkoutMinutes = 0,
    this.favoriteExerciseIds = const [],
    this.xp = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.achievements = const [],
    this.preferredLocale = 'en',
  });

  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? photoUrl;
  final String? bio;
  final double? height;
  final double? weight;
  final int? age;
  final FitnessLevel level;
  final FitnessGoal goal;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final int followersCount;
  final int followingCount;
  final int workoutsCount;
  final int programsCount;
  final int totalWorkoutMinutes;
  final List<String> favoriteExerciseIds;
  final int xp;
  final int currentStreak;
  final int longestStreak;
  final List<String> achievements;
  final String preferredLocale;

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        displayName,
        photoUrl,
        bio,
        height,
        weight,
        age,
        level,
        goal,
        createdAt,
        updatedAt,
        isEmailVerified,
        followersCount,
        followingCount,
        workoutsCount,
        programsCount,
        totalWorkoutMinutes,
        favoriteExerciseIds,
        xp,
        currentStreak,
        longestStreak,
        achievements,
        preferredLocale,
      ];

  UserEntity copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? photoUrl,
    String? bio,
    double? height,
    double? weight,
    int? age,
    FitnessLevel? level,
    FitnessGoal? goal,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    int? followersCount,
    int? followingCount,
    int? workoutsCount,
    int? programsCount,
    int? totalWorkoutMinutes,
    List<String>? favoriteExerciseIds,
    int? xp,
    int? currentStreak,
    int? longestStreak,
    List<String>? achievements,
    String? preferredLocale,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      level: level ?? this.level,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      workoutsCount: workoutsCount ?? this.workoutsCount,
      programsCount: programsCount ?? this.programsCount,
      totalWorkoutMinutes: totalWorkoutMinutes ?? this.totalWorkoutMinutes,
      favoriteExerciseIds: favoriteExerciseIds ?? this.favoriteExerciseIds,
      xp: xp ?? this.xp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      achievements: achievements ?? this.achievements,
      preferredLocale: preferredLocale ?? this.preferredLocale,
    );
  }
}
