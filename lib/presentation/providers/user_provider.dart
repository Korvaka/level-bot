import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:level_bot/core/constants/app_constants.dart';
import 'package:level_bot/core/errors/exceptions.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/data/models/user_model.dart';
import 'package:level_bot/domain/entities/user_entity.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:fpdart/fpdart.dart';

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

/// Checks if [currentUserId] follows [targetUserId].
final isFollowingProvider = FutureProvider.family<bool, ({String currentUserId, String targetUserId})>(
  (ref, args) async {
    final firestore = ref.watch(firestoreProvider);
    final doc = await firestore
        .collection(AppConstants.usersCollection)
        .doc(args.currentUserId)
        .collection('following')
        .doc(args.targetUserId)
        .get();
    return doc.exists;
  },
);

final userByIdProvider =
    FutureProvider.family<UserEntity?, String>((ref, userId) async {
  final firestore = ref.watch(firestoreProvider);
  final doc = await firestore
      .collection(AppConstants.usersCollection)
      .doc(userId)
      .get();
  if (!doc.exists) return null;
  return UserModel.fromFirestore(doc);
});

final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserEntity?>>((ref) {
  final firestore = ref.read(firestoreProvider);
  final storage = ref.read(storageProvider);
  final currentUser = ref.watch(currentUserProvider);
  return UserProfileNotifier(
    firestore: firestore,
    storage: storage,
    initialUser: currentUser,
  );
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  UserProfileNotifier({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    UserEntity? initialUser,
  })  : _firestore = firestore,
        _storage = storage,
        super(AsyncValue.data(initialUser));

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

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
  }) async {
    try {
      state = const AsyncValue.loading();

      String? photoUrl;
      if (photoFile != null) {
        final ref = _storage
            .ref()
            .child('${AppConstants.profilePhotosPath}/$userId.jpg');
        await ref.putFile(photoFile);
        photoUrl = await ref.getDownloadURL();
      }

      final currentDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!currentDoc.exists) {
        state = const AsyncValue.data(null);
        return Left(NotFoundFailure(message: 'User not found'));
      }

      final current = UserModel.fromFirestore(currentDoc);

      final updates = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (username != null) updates['username'] = username.toLowerCase();
      if (bio != null) updates['bio'] = bio;
      if (height != null) updates['height'] = height;
      if (weight != null) updates['weight'] = weight;
      if (age != null) updates['age'] = age;
      if (level != null) updates['level'] = level.name;
      if (goal != null) updates['goal'] = goal.name;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updates);

      final updatedUser = current.copyWithModel(
        displayName: displayName,
        username: username?.toLowerCase(),
        bio: bio,
        height: height,
        weight: weight,
        age: age,
        level: level,
        goal: goal,
        photoUrl: photoUrl ?? current.photoUrl,
        updatedAt: DateTime.now(),
      );

      state = AsyncValue.data(updatedUser);
      return Right(updatedUser);
    } on ServerException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<void> followUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.set(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId),
        {'followedAt': Timestamp.fromDate(DateTime.now())},
      );
      batch.set(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId),
        {'followedAt': Timestamp.fromDate(DateTime.now())},
      );
      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId),
        {'followingCount': FieldValue.increment(1)},
      );
      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(targetUserId),
        {'followersCount': FieldValue.increment(1)},
      );
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to follow user: $e');
    }
  }

  Future<void> unfollowUser({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.delete(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId)
            .collection('following')
            .doc(targetUserId),
      );
      batch.delete(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(targetUserId)
            .collection('followers')
            .doc(currentUserId),
      );
      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(currentUserId),
        {'followingCount': FieldValue.increment(-1)},
      );
      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(targetUserId),
        {'followersCount': FieldValue.increment(-1)},
      );
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to unfollow user: $e');
    }
  }

  Future<bool> isFollowing({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection('following')
          .doc(targetUserId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }
}
