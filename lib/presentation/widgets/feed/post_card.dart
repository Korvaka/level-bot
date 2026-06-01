import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/utils/formatters.dart';
import 'package:level_bot/domain/entities/post_entity.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/feed_provider.dart';

class PostCard extends ConsumerWidget {
  const PostCard({
    super.key,
    required this.post,
    this.isDetailView = false,
  });

  final PostEntity post;
  final bool isDetailView;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(post: post),
          if (post.workoutSummary != null)
            _WorkoutSummaryCard(summary: post.workoutSummary!),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                post.content,
                style: context.textTheme.bodyMedium,
                maxLines: isDetailView ? null : 3,
                overflow: isDetailView ? null : TextOverflow.ellipsis,
              ),
            ),
          if (post.mediaUrls.isNotEmpty)
            _MediaGrid(mediaUrls: post.mediaUrls),
          _PostActions(post: post),
        ],
      ),
    );
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.post});
  final PostEntity post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            backgroundImage: post.userPhotoUrl != null
                ? CachedNetworkImageProvider(post.userPhotoUrl!)
                : null,
            child: post.userPhotoUrl == null
                ? Text(
                    post.userDisplayName.isNotEmpty
                        ? post.userDisplayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.userDisplayName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '@${post.username} · ${Formatters.formatDate(post.createdAt)}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz_rounded),
            onPressed: () {},
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

class _WorkoutSummaryCard extends StatelessWidget {
  const _WorkoutSummaryCard({required this.summary});
  final WorkoutSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fitness_center_rounded,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Workout Summary',
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                icon: Icons.timer_outlined,
                label: Formatters.formatDuration(summary.duration),
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.layers_outlined,
                label: '${summary.totalSets} sets',
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.monitor_weight_outlined,
                label: Formatters.formatVolume(summary.totalVolume),
              ),
            ],
          ),
          if (summary.exerciseNames.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              summary.exerciseNames.take(3).join(' · '),
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (summary.personalRecordsCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.emoji_events_rounded,
                    size: 14, color: AppColors.accentYellow),
                const SizedBox(width: 4),
                Text(
                  '${summary.personalRecordsCount} PR${summary.personalRecordsCount > 1 ? 's' : ''} achieved!',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: AppColors.accentYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: context.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({required this.mediaUrls});
  final List<String> mediaUrls;

  @override
  Widget build(BuildContext context) {
    if (mediaUrls.length == 1) {
      return ClipRRect(
        child: CachedNetworkImage(
          imageUrl: mediaUrls[0],
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: mediaUrls.length.clamp(0, 4),
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: mediaUrls[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}

class _PostActions extends ConsumerWidget {
  const _PostActions({required this.post});
  final PostEntity post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          _ActionButton(
            icon: post.isLikedByCurrentUser
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: post.likesCount.toString(),
            isActive: post.isLikedByCurrentUser,
            activeColor: Colors.red,
            onTap: () {
              if (currentUser == null) return;
              if (post.isLikedByCurrentUser) {
                ref.read(feedNotifierProvider.notifier).unlikePost(post.id);
              } else {
                ref.read(feedNotifierProvider.notifier).likePost(post.id);
              }
            },
          ),
          _ActionButton(
            icon: Icons.chat_bubble_outline_rounded,
            label: post.commentsCount.toString(),
            onTap: () {},
          ),
          _ActionButton(
            icon: Icons.share_outlined,
            label: post.sharesCount.toString(),
            onTap: () {},
          ),
          const Spacer(),
          _ActionButton(
            icon: Icons.bookmark_border_rounded,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.label,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  final IconData icon;
  final String? label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? context.colorScheme.primary)
        : context.colorScheme.onSurfaceVariant;

    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      icon: Icon(icon, size: 20, color: color),
      label: label != null
          ? Text(
              label!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
