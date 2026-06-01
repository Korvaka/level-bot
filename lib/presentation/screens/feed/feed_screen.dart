import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/feed_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_error.dart';
import 'package:level_bot/presentation/widgets/common/app_loading.dart';
import 'package:level_bot/presentation/widgets/feed/post_card.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FollowingFeed(),
          _ExploreFeed(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: ShaderMask(
        shaderCallback: (bounds) =>
            AppColors.primaryGradient.createShader(bounds),
        child: const Text(
          'LEVELBOT',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Following'),
          Tab(text: 'Explore'),
        ],
      ),
    );
  }
}

class _FollowingFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedNotifierProvider);

    return feedState.when(
      loading: () => const AppLoading(),
      error: (error, _) => AppError(
        message: error.toString(),
        onRetry: () => ref.read(feedNotifierProvider.notifier).load(),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return _EmptyFeed();
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(feedNotifierProvider.notifier).refresh(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          ),
        );
      },
    );
  }
}

class _ExploreFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(exploreFeedProvider);

    return feedState.when(
      loading: () => const AppLoading(),
      error: (error, _) => AppError(message: error.toString()),
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('Nothing to explore yet'));
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(exploreFeedProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts[index]);
            },
          ),
        );
      },
    );
  }
}

class _EmptyFeed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 72,
              color: context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'Your feed is empty',
              style: context.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Follow athletes to see their workouts\nand programs here',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
