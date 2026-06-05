import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:level_bot/data/datasources/remote/auth_remote_datasource.dart';
import 'package:level_bot/data/repositories/auth_repository_impl.dart';
import 'package:level_bot/domain/entities/user_entity.dart';
import 'package:level_bot/domain/repositories/auth_repository.dart';

// Infrastructure providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn(scopes: ['email', 'profile']);
});

// DataSource providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
    googleSignIn: ref.read(googleSignInProvider),
  );
});

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
  );
});

// Auth state stream
final authStateChangesProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateChangesProvider).value;
});

// Auth notifier
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  AuthNotifier(this._repository) : super(const AsyncValue.loading()) {
    _init();
  }

  final AuthRepository _repository;

  Future<void> _init() async {
    final result = await _repository.getCurrentUser();
    result.fold(
      (failure) => state = const AsyncValue.data(null),
      (user) => state = AsyncValue.data(user),
    );
  }

  Future<String?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }

  Future<String?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.signUpWithEmail(
      email: email,
      password: password,
      username: username,
      displayName: displayName,
    );
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }

  Future<String?> signInWithGoogle() async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithGoogle();
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }

  Future<String?> signInWithApple() async {
    state = const AsyncValue.loading();
    final result = await _repository.signInWithApple();
    return result.fold(
      (failure) {
        state = const AsyncValue.data(null);
        return failure.message;
      },
      (user) {
        state = AsyncValue.data(user);
        return null;
      },
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }

  Future<String?> resetPassword(String email) async {
    final result = await _repository.resetPassword(email);
    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
  }

  Future<String?> deleteAccount() async {
    final result = await _repository.deleteAccount();
    return result.fold(
      (failure) => failure.message,
      (_) {
        state = const AsyncValue.data(null);
        return null;
      },
    );
  }

  Future<String?> sendEmailVerification() async {
    final result = await _repository.sendEmailVerification();
    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
  }
}
