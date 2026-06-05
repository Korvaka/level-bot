import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/presentation/providers/feed_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_loading.dart';
import 'package:level_bot/presentation/widgets/feed/post_card.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedRepo = ref.watch(feedRepositoryProvider);
    final postFuture = useMemoized(() => feedRepo.getPostById(postId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(AppLocalizations.of(context)!.post),
      ),
      body: FutureBuilder(
        future: feedRepo.getPostById(postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Post not found',
                style: context.textTheme.bodyLarge,
              ),
            );
          }
          return snapshot.data!.fold(
            (failure) => Center(child: Text(failure.message)),
            (post) => SingleChildScrollView(
              child: PostCard(post: post, isDetailView: true),
            ),
          );
        },
      ),
    );
  }
}

T useMemoized<T>(T Function() fn) => fn();
