import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:level_bot/data/datasources/remote/feed_remote_datasource.dart';
import 'package:level_bot/data/repositories/feed_repository_impl.dart';
import 'package:level_bot/domain/entities/post_entity.dart';
import 'package:level_bot/domain/repositories/feed_repository.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';

final feedRemoteDataSourceProvider = Provider<FeedRemoteDataSource>((ref) {
  return FeedRemoteDataSourceImpl(
    firestore: ref.read(firestoreProvider),
  );
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(
    remoteDataSource: ref.read(feedRemoteDataSourceProvider),
  );
});

final feedNotifierProvider =
    StateNotifierProvider<FeedNotifier, AsyncValue<List<PostEntity>>>((ref) {
  final repo = ref.read(feedRepositoryProvider);
  final userId = ref.watch(currentUserProvider)?.id ?? '';
  return FeedNotifier(repo, userId);
});

class FeedNotifier extends StateNotifier<AsyncValue<List<PostEntity>>> {
  FeedNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId.isNotEmpty) load();
  }

  final FeedRepository _repository;
  final String _userId;
  String? _lastPostId;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  Future<void> load() async {
    state = const AsyncValue.loading();
    _lastPostId = null;
    _hasMore = true;

    final result = await _repository.getFeed(userId: _userId);
    result.fold(
      (failure) =>
          state = AsyncValue.error(failure.message, StackTrace.current),
      (posts) {
        state = AsyncValue.data(posts);
        if (posts.isNotEmpty) _lastPostId = posts.last.id;
        _hasMore = posts.length >= 15;
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _lastPostId == null) return;
    _isLoadingMore = true;

    final result = await _repository.getFeed(
      userId: _userId,
      lastPostId: _lastPostId,
    );
    result.fold(
      (failure) => null,
      (newPosts) {
        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          state = state.whenData(
              (posts) => [...posts, ...newPosts]);
          _lastPostId = newPosts.last.id;
          _hasMore = newPosts.length >= 15;
        }
      },
    );

    _isLoadingMore = false;
  }

  Future<void> refresh() => load();

  Future<String?> likePost(String postId) async {
    final userId = _userId;
    state = state.whenData((posts) => posts
        .map((p) => p.id == postId
            ? p.copyWith(
                isLikedByCurrentUser: true,
                likesCount: p.likesCount + 1,
              )
            : p)
        .toList());

    final result =
        await _repository.likePost(userId: userId, postId: postId);
    return result.fold(
      (failure) {
        state = state.whenData((posts) => posts
            .map((p) => p.id == postId
                ? p.copyWith(
                    isLikedByCurrentUser: false,
                    likesCount: p.likesCount - 1,
                  )
                : p)
            .toList());
        return failure.message;
      },
      (_) => null,
    );
  }

  Future<String?> unlikePost(String postId) async {
    final userId = _userId;
    state = state.whenData((posts) => posts
        .map((p) => p.id == postId
            ? p.copyWith(
                isLikedByCurrentUser: false,
                likesCount: p.likesCount - 1,
              )
            : p)
        .toList());

    final result =
        await _repository.unlikePost(userId: userId, postId: postId);
    return result.fold(
      (failure) {
        state = state.whenData((posts) => posts
            .map((p) => p.id == postId
                ? p.copyWith(
                    isLikedByCurrentUser: true,
                    likesCount: p.likesCount + 1,
                  )
                : p)
            .toList());
        return failure.message;
      },
      (_) => null,
    );
  }

  Future<String?> createPost(PostEntity post) async {
    final result = await _repository.createPost(post);
    return result.fold(
      (failure) => failure.message,
      (created) {
        state = state.whenData((posts) => [created, ...posts]);
        return null;
      },
    );
  }

  Future<String?> deletePost(String postId) async {
    final result = await _repository.deletePost(postId);
    return result.fold(
      (failure) => failure.message,
      (_) {
        state = state.whenData(
            (posts) => posts.where((p) => p.id != postId).toList());
        return null;
      },
    );
  }
}

final exploreFeedProvider = FutureProvider<List<PostEntity>>((ref) async {
  final repo = ref.watch(feedRepositoryProvider);
  final result = await repo.getExploreFeed();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (posts) => posts,
  );
});

final userPostsProvider =
    FutureProvider.family<List<PostEntity>, String>((ref, userId) async {
  final repo = ref.watch(feedRepositoryProvider);
  final result = await repo.getUserPosts(userId: userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (posts) => posts,
  );
});
