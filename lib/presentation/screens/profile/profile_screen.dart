import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:level_bot/core/router/app_router.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/core/theme/app_text_styles.dart';
import 'package:level_bot/domain/entities/personal_record_entity.dart';
import 'package:level_bot/domain/entities/user_entity.dart';
import 'package:level_bot/presentation/providers/auth_provider.dart';
import 'package:level_bot/presentation/providers/feed_provider.dart';
import 'package:level_bot/presentation/providers/program_provider.dart';
import 'package:level_bot/presentation/providers/user_provider.dart';
import 'package:level_bot/presentation/providers/workout_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_error.dart';
import 'package:level_bot/presentation/widgets/common/app_loading.dart';
import 'package:level_bot/presentation/widgets/feed/post_card.dart';
import 'package:level_bot/presentation/widgets/program/program_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool get _isOwnProfile => widget.userId == null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null && _isOwnProfile) {
      return const Scaffold(body: AppLoading());
    }

    final targetUserId =
        _isOwnProfile ? (currentUser?.id ?? '') : widget.userId!;

    if (targetUserId.isEmpty) {
      return const Scaffold(body: AppError(message: 'User not found'));
    }

    final profileAsync = ref.watch(userByIdProvider(targetUserId));

    return profileAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppError(message: e.toString()),
      ),
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const AppError(message: 'User not found'),
          );
        }
        return _ProfileScaffold(
          user: user,
          currentUserId: currentUser?.id ?? '',
          isOwnProfile: _isOwnProfile,
          tabController: _tabController,
        );
      },
    );
  }
}

class _ProfileScaffold extends ConsumerWidget {
  const _ProfileScaffold({
    required this.user,
    required this.currentUserId,
    required this.isOwnProfile,
    required this.tabController,
  });

  final UserEntity user;
  final String currentUserId;
  final bool isOwnProfile;
  final TabController tabController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isFollowingAsync = isOwnProfile
        ? null
        : ref.watch(isFollowingProvider((
            currentUserId: currentUserId,
            targetUserId: user.id,
          )));
    final isFollowing = isFollowingAsync?.valueOrNull ?? false;
    final isFollowLoading = isFollowingAsync?.isLoading ?? false;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            leading: isOwnProfile
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => context.pop(),
                  ),
            actions: isOwnProfile
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit Profile',
                      onPressed: () => context.push(AppRoutes.editProfile),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: l10n.settings,
                      onPressed: () => _showSettingsSheet(context, ref),
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: user.photoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppColors.darkCard),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.darkCard),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withAlpha(180),
                            AppColors.secondary.withAlpha(180),
                          ],
                        ),
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(200),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildAvatar(),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.displayName,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: Colors.white,
                                  shadows: [
                                    const Shadow(
                                      blurRadius: 4,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '@${user.username}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _ProfileInfo(
              user: user,
              currentUserId: currentUserId,
              isOwnProfile: isOwnProfile,
              isFollowing: isFollowing,
              isFollowLoading: isFollowLoading,
              onFollowToggle: () => _toggleFollow(ref, isFollowing),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: tabController,
                tabs: [
                  Tab(text: l10n.postsTab),
                  Tab(text: l10n.programs),
                  Tab(text: l10n.recordsTab),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: tabController,
          children: [
            _PostsTab(userId: user.id),
            _ProgramsTab(userId: user.id),
            _RecordsTab(userId: user.id),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 40,
      backgroundColor: AppColors.primary.withAlpha(60),
      backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
          ? CachedNetworkImageProvider(user.photoUrl!) as ImageProvider
          : null,
      child: (user.photoUrl == null || user.photoUrl!.isEmpty)
          ? Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : 'U',
              style: AppTextStyles.headlineLarge.copyWith(
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Future<void> _toggleFollow(WidgetRef ref, bool isFollowing) async {
    final notifier = ref.read(userProfileNotifierProvider.notifier);
    if (isFollowing) {
      await notifier.unfollowUser(
        currentUserId: currentUserId,
        targetUserId: user.id,
      );
    } else {
      await notifier.followUser(
        currentUserId: currentUserId,
        targetUserId: user.id,
      );
    }
    // Invalidate follow state to refresh
    ref.invalidate(isFollowingProvider((
      currentUserId: currentUserId,
      targetUserId: user.id,
    )));
    ref.invalidate(userByIdProvider(user.id));
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _SettingsSheet(
        onSignOut: () async {
          Navigator.pop(ctx);
          await ref.read(authNotifierProvider.notifier).signOut();
          if (context.mounted) context.go(AppRoutes.login);
        },
        onDeleteAccount: () {
          Navigator.pop(ctx);
          _confirmDeleteAccount(context, ref);
        },
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await ref.read(authNotifierProvider.notifier).deleteAccount();
              if (context.mounted) context.go(AppRoutes.login);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({
    required this.user,
    required this.currentUserId,
    required this.isOwnProfile,
    required this.isFollowing,
    required this.isFollowLoading,
    required this.onFollowToggle,
  });

  final UserEntity user;
  final String currentUserId;
  final bool isOwnProfile;
  final bool isFollowing;
  final bool isFollowLoading;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: l10n.workouts,
                value: user.workoutsCount.toString(),
              ),
              _VerticalDivider(),
              _StatItem(
                label: l10n.followers,
                value: _formatCount(user.followersCount),
              ),
              _VerticalDivider(),
              _StatItem(
                label: l10n.following,
                value: _formatCount(user.followingCount),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            Text(
              user.bio!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Chip(
                label: user.goal.displayName,
                color: AppColors.accent,
              ),
              _Chip(
                label: user.level.displayName,
                color: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isOwnProfile)
            OutlinedButton(
              onPressed: () => context.push(AppRoutes.editProfile),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
              child: const Text('Edit Profile'),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: isFollowLoading
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : isFollowing
                      ? OutlinedButton(
                          onPressed: onFollowToggle,
                          child: Text(l10n.following),
                        )
                      : ElevatedButton(
                          onPressed: onFollowToggle,
                          child: const Text('Follow'),
                        ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      color: AppColors.darkDivider,
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}

class _PostsTab extends ConsumerWidget {
  const _PostsTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final postsAsync = ref.watch(userPostsProvider(userId));

    return postsAsync.when(
      loading: () => const Center(child: AppLoading()),
      error: (e, _) => Center(child: AppError(message: e.toString())),
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: _EmptyState(
              icon: Icons.photo_library_outlined,
              title: l10n.noPostsYet,
              subtitle: l10n.noPostsSubtitle,
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
    );
  }
}

class _ProgramsTab extends ConsumerWidget {
  const _ProgramsTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final programsAsync = ref.watch(userProgramsProvider(userId));

    return programsAsync.when(
      loading: () => const Center(child: AppLoading()),
      error: (e, _) => Center(child: AppError(message: e.toString())),
      data: (programs) {
        if (programs.isEmpty) {
          return Center(
            child: _EmptyState(
              icon: Icons.fitness_center_rounded,
              title: l10n.noProgramsYet,
              subtitle: l10n.noProgramsSubtitle,
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: programs.length,
          itemBuilder: (context, index) =>
              ProgramCard(program: programs[index]),
        );
      },
    );
  }
}

class _RecordsTab extends ConsumerWidget {
  const _RecordsTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final recordsAsync = ref.watch(personalRecordsProvider(userId));

    return recordsAsync.when(
      loading: () => const Center(child: AppLoading()),
      error: (e, _) => Center(child: AppError(message: e.toString())),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: _EmptyState(
              icon: Icons.emoji_events_outlined,
              title: l10n.noRecordsYet,
              subtitle: l10n.noRecordsSubtitle,
            ),
          );
        }
        final sorted = List.of(records)
          ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sorted.length,
          itemBuilder: (context, index) =>
              _RecordTile(record: sorted[index]),
        );
      },
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final PersonalRecordEntity record;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accent.withAlpha(30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.emoji_events_rounded,
            color: AppColors.accent,
          ),
        ),
        title: Text(record.exerciseName, style: AppTextStyles.titleSmall),
        subtitle: Text(
          record.weight != null
              ? '${record.weight!.toStringAsFixed(1)} kg'
                  '${record.reps != null ? ' × ${record.reps} reps' : ''}'
              : '${record.value.toStringAsFixed(1)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),
        trailing: Text(
          _formatDate(record.achievedAt, context),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textTertiaryDark,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 0) return l10n.today;
    if (diff == 1) return l10n.yesterday;
    if (diff < 30) return '${diff}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textTertiaryDark),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondaryDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet({
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.darkDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.editProfile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.settings),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                context.push(AppRoutes.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events_outlined),
              title: Text(l10n.achievements),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(context);
                context.push('/profile/achievements');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: Text(l10n.signOut),
              onTap: onSignOut,
            ),
            ListTile(
              leading: Icon(
                Icons.delete_forever_rounded,
                color: AppColors.error,
              ),
              title: Text(
                l10n.deleteAccount,
                style: TextStyle(color: AppColors.error),
              ),
              onTap: onDeleteAccount,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
