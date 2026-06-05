import 'package:fpdart/fpdart.dart';
import 'package:level_bot/core/errors/failures.dart';
import 'package:level_bot/domain/entities/post_entity.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<PostEntity>>> getFeed({
    required String userId,
    int limit = 15,
    String? lastPostId,
  });
  Future<Either<Failure, List<PostEntity>>> getUserPosts({
    required String userId,
    int limit = 20,
    String? lastPostId,
  });
  Future<Either<Failure, PostEntity>> createPost(PostEntity post);
  Future<Either<Failure, PostEntity>> updatePost(PostEntity post);
  Future<Either<Failure, void>> deletePost(String postId);
  Future<Either<Failure, PostEntity>> getPostById(String postId);
  Future<Either<Failure, void>> likePost({
    required String userId,
    required String postId,
  });
  Future<Either<Failure, void>> unlikePost({
    required String userId,
    required String postId,
  });
  Future<Either<Failure, List<PostEntity>>> getExploreFeed({
    int limit = 20,
    String? lastPostId,
  });
}
