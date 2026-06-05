import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/exceptions.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/data/datasources/remote/feed_remote_datasource.dart';
import 'package:level_bot/data/models/post_model.dart';
import 'package:level_bot/domain/entities/post_entity.dart';
import 'package:level_bot/domain/repositories/feed_repository.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl({required FeedRemoteDataSource remoteDataSource})
      : _remote = remoteDataSource;

  final FeedRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<PostEntity>>> getFeed({
    required String userId,
    int limit = 15,
    String? lastPostId,
  }) async {
    try {
      final posts = await _remote.getFeed(
        userId: userId,
        limit: limit,
        lastPostId: lastPostId,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getUserPosts({
    required String userId,
    int limit = 20,
    String? lastPostId,
  }) async {
    try {
      final posts = await _remote.getUserPosts(
        userId: userId,
        limit: limit,
        lastPostId: lastPostId,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost(PostEntity post) async {
    try {
      final model = PostModel.fromEntity(post);
      final created = await _remote.createPost(model);
      return Right(created);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost(PostEntity post) async {
    try {
      final model = PostModel.fromEntity(post);
      final updated = await _remote.updatePost(model);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(String postId) async {
    try {
      await _remote.deletePost(postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(String postId) async {
    try {
      final post = await _remote.getPostById(postId);
      return Right(post);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> likePost({
    required String userId,
    required String postId,
  }) async {
    try {
      await _remote.likePost(userId: userId, postId: postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unlikePost({
    required String userId,
    required String postId,
  }) async {
    try {
      await _remote.unlikePost(userId: userId, postId: postId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getExploreFeed({
    int limit = 20,
    String? lastPostId,
  }) async {
    try {
      final posts = await _remote.getExploreFeed(
        limit: limit,
        lastPostId: lastPostId,
      );
      return Right(posts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
