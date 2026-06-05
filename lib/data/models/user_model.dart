import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.username,
    required super.displayName,
    super.photoUrl,
    super.bio,
    super.height,
    super.weight,
    super.age,
    super.level,
    super.goal,
    required super.createdAt,
    super.updatedAt,
    super.isEmailVerified,
    super.followersCount,
    super.followingCount,
    super.workoutsCount,
    super.programsCount,
    super.totalWorkoutMinutes,
    super.favoriteExerciseIds,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      bio: data['bio'] as String?,
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      age: data['age'] as int?,
      level: FitnessLevel.values.firstWhere(
        (e) => e.name == (data['level'] as String?),
        orElse: () => FitnessLevel.beginner,
      ),
      goal: FitnessGoal.values.firstWhere(
        (e) => e.name == (data['goal'] as String?),
        orElse: () => FitnessGoal.buildMuscle,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      followersCount: data['followersCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      workoutsCount: data['workoutsCount'] as int? ?? 0,
      programsCount: data['programsCount'] as int? ?? 0,
      totalWorkoutMinutes: data['totalWorkoutMinutes'] as int? ?? 0,
      favoriteExerciseIds: List<String>.from(
        data['favoriteExerciseIds'] as List? ?? [],
      ),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      username: entity.username,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      bio: entity.bio,
      height: entity.height,
      weight: entity.weight,
      age: entity.age,
      level: entity.level,
      goal: entity.goal,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isEmailVerified: entity.isEmailVerified,
      followersCount: entity.followersCount,
      followingCount: entity.followingCount,
      workoutsCount: entity.workoutsCount,
      programsCount: entity.programsCount,
      totalWorkoutMinutes: entity.totalWorkoutMinutes,
      favoriteExerciseIds: entity.favoriteExerciseIds,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'height': height,
      'weight': weight,
      'age': age,
      'level': level.name,
      'goal': goal.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEmailVerified': isEmailVerified,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'workoutsCount': workoutsCount,
      'programsCount': programsCount,
      'totalWorkoutMinutes': totalWorkoutMinutes,
      'favoriteExerciseIds': favoriteExerciseIds,
    };
  }

  UserModel copyWithModel({
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
  }) {
    return UserModel(
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
    );
  }
}
