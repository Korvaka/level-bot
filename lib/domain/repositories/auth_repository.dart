import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  });
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInWithApple();
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, void>> deleteAccount();
  Future<Either<Failure, void>> sendEmailVerification();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
