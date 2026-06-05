import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/core/constants/app_constants.dart';
import 'package:level_bot/core/errors/exceptions.dart';
import 'package:level_bot/data/models/post_model.dart';

abstract class FeedRemoteDataSource {
  Future<List<PostModel>> getFeed({
    required String userId,
    int limit,
    String? lastPostId,
  });
  Future<List<PostModel>> getUserPosts({
    required String userId,
    int limit,
    String? lastPostId,
  });
  Future<PostModel> createPost(PostModel post);
  Future<PostModel> updatePost(PostModel post);
  Future<void> deletePost(String postId);
  Future<PostModel> getPostById(String postId);
  Future<void> likePost({required String userId, required String postId});
  Future<void> unlikePost({required String userId, required String postId});
  Future<List<PostModel>> getExploreFeed({int limit, String? lastPostId});
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  FeedRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection =>
      _firestore.collection(AppConstants.postsCollection);

  @override
  Future<List<PostModel>> getFeed({
    required String userId,
    int limit = 15,
    String? lastPostId,
  }) async {
    try {
      final followingSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .collection('following')
          .get();

      final followingIds =
          followingSnapshot.docs.map((doc) => doc.id).toList();
      followingIds.add(userId);

      Query query = _collection
          .where('userId', whereIn: followingIds.take(10).toList())
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastPostId != null) {
        final lastDoc = await _collection.doc(lastPostId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      final likedPostIds = await _getLikedPostIds(userId, snapshot.docs.map((d) => d.id).toList());

      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(
                doc,
                isLiked: likedPostIds.contains(doc.id),
              ))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch feed: $e');
    }
  }

  @override
  Future<List<PostModel>> getUserPosts({
    required String userId,
    int limit = 20,
    String? lastPostId,
  }) async {
    try {
      Query query = _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastPostId != null) {
        final lastDoc = await _collection.doc(lastPostId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch user posts: $e');
    }
  }

  @override
  Future<PostModel> createPost(PostModel post) async {
    try {
      final docRef = _collection.doc();
      final data = post.toFirestore();
      data['id'] = docRef.id;
      await docRef.set(data);
      final doc = await docRef.get();
      return PostModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to create post: $e');
    }
  }

  @override
  Future<PostModel> updatePost(PostModel post) async {
    try {
      final data = post.toFirestore();
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _collection.doc(post.id).update(data);
      final doc = await _collection.doc(post.id).get();
      return PostModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _collection.doc(postId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete post: $e');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    try {
      final doc = await _collection.doc(postId).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Post not found', statusCode: 404);
      }
      return PostModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch post: $e');
    }
  }

  @override
  Future<void> likePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.set(
        _collection.doc(postId).collection('likes').doc(userId),
        {'likedAt': Timestamp.fromDate(DateTime.now())},
      );
      batch.update(
        _collection.doc(postId),
        {'likesCount': FieldValue.increment(1)},
      );
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to like post: $e');
    }
  }

  @override
  Future<void> unlikePost({
    required String userId,
    required String postId,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.delete(_collection.doc(postId).collection('likes').doc(userId));
      batch.update(
        _collection.doc(postId),
        {'likesCount': FieldValue.increment(-1)},
      );
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to unlike post: $e');
    }
  }

  @override
  Future<List<PostModel>> getExploreFeed({
    int limit = 20,
    String? lastPostId,
  }) async {
    try {
      Query query = _collection
          .orderBy('likesCount', descending: true)
          .limit(limit);

      if (lastPostId != null) {
        final lastDoc = await _collection.doc(lastPostId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch explore feed: $e');
    }
  }

  Future<List<String>> _getLikedPostIds(
    String userId,
    List<String> postIds,
  ) async {
    if (postIds.isEmpty) return [];
    final likedIds = <String>[];
    for (final postId in postIds) {
      final doc = await _collection
          .doc(postId)
          .collection('likes')
          .doc(userId)
          .get();
      if (doc.exists) likedIds.add(postId);
    }
    return likedIds;
  }
}
