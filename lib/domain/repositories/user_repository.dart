import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<Either<Failure, UserEntity>> getUserById(String userId);
  Future<Either<Failure, UserEntity>> updateProfile({
    required String userId,
    String? displayName,
    String? username,
    String? bio,
    double? height,
    double? weight,
    int? age,
    FitnessLevel? level,
    FitnessGoal? goal,
    File? photoFile,
  });
  Future<Either<Failure, void>> followUser({
    required String currentUserId,
    required String targetUserId,
  });
  Future<Either<Failure, void>> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  });
  Future<Either<Failure, bool>> isFollowing({
    required String currentUserId,
    required String targetUserId,
  });
  Future<Either<Failure, List<UserEntity>>> getFollowers(String userId);
  Future<Either<Failure, List<UserEntity>>> getFollowing(String userId);
  Future<Either<Failure, List<UserEntity>>> searchUsers(String query);
  Future<Either<Failure, void>> deleteAccount(String userId);
}
