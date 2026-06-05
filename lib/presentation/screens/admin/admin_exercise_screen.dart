import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:level_bot/core/extensions/context_extensions.dart';
import 'package:level_bot/core/theme/app_colors.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';
import 'package:level_bot/presentation/providers/exercise_provider.dart';
import 'package:level_bot/presentation/widgets/common/app_error.dart';
import 'package:level_bot/presentation/widgets/common/app_loading.dart';
import 'package:level_bot/presentation/widgets/exercise/video_player_widget.dart';
import 'package:uuid/uuid.dart';

class AdminExerciseScreen extends ConsumerStatefulWidget {
  const AdminExerciseScreen({super.key});

  @override
  ConsumerState<AdminExerciseScreen> createState() =>
      _AdminExerciseScreenState();
}

class _AdminExerciseScreenState extends ConsumerState<AdminExerciseScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ExerciseEntity? _selected;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercisesAsync = ref.watch(allExercisesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminPanel),
        centerTitle: false,
      ),
      body: Row(
        children: [
          // Left panel - exercise list
          SizedBox(
            width: MediaQuery.of(context).size.width > 600 ? 300 : double.infinity,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: l10n.searchExercisesHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                Expanded(
                  child: exercisesAsync.when(
                    loading: () => const AppLoading(),
                    error: (e, _) => AppError(message: e.toString()),
                    data: (exercises) {
                      final filtered = _query.isEmpty
                          ? exercises
                          : exercises
                              .where((e) => e.name
                                  .toLowerCase()
                                  .contains(_query.toLowerCase()))
                              .toList();

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final ex = filtered[i];
                          final isSelected = _selected?.id == ex.id;
                          return ListTile(
                            selected: isSelected,
                            selectedTileColor:
                                AppColors.primary.withOpacity(0.1),
                            title: Text(
                              ex.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  ex.primaryMuscle.name,
                                  style: TextStyle(
                                    color: _muscleColor(ex.primaryMuscle),
                                    fontSize: 12,
                                  ),
                                ),
                                if (ex.videos.isNotEmpty) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.videocam_rounded,
                                      size: 14, color: AppColors.secondary),
                                  Text(
                                    ' ${ex.videos.length}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondary),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () => setState(() => _selected = ex),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Right panel - video management (only on wider screens)
          if (MediaQuery.of(context).size.width > 600 && _selected != null)
            Expanded(
              child: _VideoManagementPanel(
                exercise: _selected!,
                onUpdated: (updated) => setState(() => _selected = updated),
              ),
            ),
        ],
      ),
      // Bottom sheet for narrow screens
      floatingActionButton: _selected != null &&
              MediaQuery.of(context).size.width <= 600
          ? FloatingActionButton.extended(
              onPressed: () => _showVideoPanel(context),
              icon: const Icon(Icons.videocam_rounded),
              label: Text(l10n.videosLabel),
            )
          : null,
    );
  }

  void _showVideoPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => _VideoManagementPanel(
          exercise: _selected!,
          onUpdated: (updated) => setState(() => _selected = updated),
          scrollController: ctrl,
        ),
      ),
    );
  }

  Color _muscleColor(MuscleGroup m) {
    switch (m) {
      case MuscleGroup.chest: return AppColors.chest;
      case MuscleGroup.back: return AppColors.back;
      case MuscleGroup.shoulders: return AppColors.shoulders;
      case MuscleGroup.biceps: return AppColors.biceps;
      case MuscleGroup.triceps: return AppColors.triceps;
      case MuscleGroup.forearms: return AppColors.forearms;
      case MuscleGroup.abs: return AppColors.abs;
      case MuscleGroup.quads: return AppColors.quads;
      case MuscleGroup.hamstrings: return AppColors.hamstrings;
      case MuscleGroup.glutes: return AppColors.glutes;
      case MuscleGroup.calves: return AppColors.calves;
      case MuscleGroup.cardio: return AppColors.cardio;
      case MuscleGroup.fullBody: return AppColors.primary;
    }
  }
}

// ─── Video Management Panel ───────────────────────────────────────────────────

class _VideoManagementPanel extends ConsumerStatefulWidget {
  const _VideoManagementPanel({
    required this.exercise,
    required this.onUpdated,
    this.scrollController,
  });

  final ExerciseEntity exercise;
  final void Function(ExerciseEntity) onUpdated;
  final ScrollController? scrollController;

  @override
  ConsumerState<_VideoManagementPanel> createState() =>
      _VideoManagementPanelState();
}

class _VideoManagementPanelState
    extends ConsumerState<_VideoManagementPanel> {
  final _uuid = const Uuid();
  bool _isUploading = false;
  double _uploadProgress = 0;
  ExerciseVideo? _previewVideo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final exercise = widget.exercise;

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Exercise header
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: context.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${exercise.videos.length} ${l10n.videosLabel}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : () => _uploadVideo(context),
              icon: _isUploading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_rounded),
              label: Text(_isUploading
                  ? '${(_uploadProgress * 100).toStringAsFixed(0)}%'
                  : l10n.uploadVideo),
            ),
          ],
        ),

        if (_isUploading) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: AppColors.darkCard,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        // Preview player
        if (_previewVideo != null) ...[
          Text(l10n.videosLabel, style: context.textTheme.titleSmall),
          const SizedBox(height: 8),
          ExerciseVideoPlayer(url: _previewVideo!.url, showControls: true),
          const SizedBox(height: 20),
        ],

        // Video list
        if (exercise.videos.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.videocam_off_rounded,
                      size: 64, color: AppColors.textTertiaryDark),
                  const SizedBox(height: 16),
                  Text(l10n.noVideosAvailable,
                      style: context.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _uploadVideo(context),
                    icon: const Icon(Icons.upload_rounded),
                    label: Text(l10n.addVideo),
                  ),
                ],
              ),
            ),
          )
        else
          ...exercise.videos.asMap().entries.map((entry) =>
              _VideoTile(
                video: entry.value,
                index: entry.key,
                onPreview: () =>
                    setState(() => _previewVideo = entry.value),
                onSetPrimary: () => _setPrimary(entry.value.id),
                onDelete: () => _deleteVideo(context, entry.value),
                l10n: l10n,
              )),
      ],
    );
  }

  Future<void> _uploadVideo(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final picker = ImagePicker();

    // Pick video file
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return;
    if (!context.mounted) return;

    final file = File(picked.path);
    final videoId = _uuid.v4();
    final storagePath =
        'exercises/${widget.exercise.id}/videos/$videoId.mp4';

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final ref = FirebaseStorage.instance.ref(storagePath);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'video/mp4'),
      );

      uploadTask.snapshotEvents.listen((snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      await uploadTask;
      final url = await ref.getDownloadURL();

      final newVideo = ExerciseVideo(
        id: videoId,
        url: url,
        isPrimary: widget.exercise.videos.isEmpty,
        uploadedAt: DateTime.now(),
      );

      await _updateExerciseVideos(
        [...widget.exercise.videos, newVideo],
      );

      if (context.mounted) {
        context.showSnackBar('Video uploaded successfully');
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar(l10n.uploadVideo);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _setPrimary(String videoId) async {
    final updated = widget.exercise.videos
        .map((v) => v.copyWith(isPrimary: v.id == videoId))
        .toList();
    await _updateExerciseVideos(updated);
  }

  Future<void> _deleteVideo(BuildContext context, ExerciseVideo video) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.videoDeleteTitle),
        content: Text(l10n.videoDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Delete from Firebase Storage
      await FirebaseStorage.instance.refFromURL(video.url).delete();
    } catch (_) {
      // Storage file might not exist, continue anyway
    }

    if (mounted && _previewVideo?.id == video.id) {
      setState(() => _previewVideo = null);
    }

    final updatedVideos =
        widget.exercise.videos.where((v) => v.id != video.id).toList();

    // If we removed the primary, set first remaining as primary
    if (video.isPrimary && updatedVideos.isNotEmpty) {
      updatedVideos[0] = updatedVideos[0].copyWith(isPrimary: true);
    }

    await _updateExerciseVideos(updatedVideos);
  }

  Future<void> _updateExerciseVideos(List<ExerciseVideo> videos) async {
    final error = await ref
        .read(exerciseNotifierProvider.notifier)
        .updateExerciseVideos(widget.exercise.id, videos);

    if (error != null && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }

    // Optimistic local update for immediate feedback
    final updatedExercise = _exerciseWithVideos(widget.exercise, videos);
    widget.onUpdated(updatedExercise);
  }

  ExerciseEntity _exerciseWithVideos(
      ExerciseEntity original, List<ExerciseVideo> videos) {
    // Create a new entity with updated videos
    // We use a simple data carrier approach here
    return _ExerciseWithVideos(original: original, newVideos: videos);
  }
}

// Lightweight proxy to carry updated video list without requiring a full copy
class _ExerciseWithVideos extends ExerciseEntity {
  _ExerciseWithVideos({
    required ExerciseEntity original,
    required List<ExerciseVideo> newVideos,
  }) : super(
          id: original.id,
          name: original.name,
          description: original.description,
          primaryMuscle: original.primaryMuscle,
          secondaryMuscles: original.secondaryMuscles,
          equipment: original.equipment,
          category: original.category,
          difficulty: original.difficulty,
          instructions: original.instructions,
          gifUrl: original.gifUrl,
          videoUrl: original.videoUrl,
          thumbnailUrl: original.thumbnailUrl,
          tips: original.tips,
          commonMistakes: original.commonMistakes,
          isCustom: original.isCustom,
          createdBy: original.createdBy,
          aliases: original.aliases,
          videos: newVideos,
        );
}

// ─── Video Tile ───────────────────────────────────────────────────────────────

class _VideoTile extends StatelessWidget {
  const _VideoTile({
    required this.video,
    required this.index,
    required this.onPreview,
    required this.onSetPrimary,
    required this.onDelete,
    required this.l10n,
  });

  final ExerciseVideo video;
  final int index;
  final VoidCallback onPreview;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: video.isPrimary ? AppColors.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: GestureDetector(
          onTap: onPreview,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 56,
              height: 56,
              color: AppColors.darkCard,
              child: video.thumbnailUrl != null
                  ? CachedNetworkImage(
                      imageUrl: video.thumbnailUrl!,
                      fit: BoxFit.cover,
                    )
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.videocam_rounded,
                            color: AppColors.primary, size: 24),
                        if (video.isPrimary)
                          Positioned(
                            top: 2,
                            right: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.star_rounded,
                                  size: 8, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
        title: Row(
          children: [
            Text('Video ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            if (video.isPrimary) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.primaryVideo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          video.angle ?? 'Standard angle',
          style: TextStyle(
            fontSize: 12,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!video.isPrimary)
              IconButton(
                icon: const Icon(Icons.star_border_rounded,
                    color: AppColors.primary),
                tooltip: l10n.setAsPrimary,
                onPressed: onSetPrimary,
              ),
            IconButton(
              icon: const Icon(Icons.play_circle_outline_rounded,
                  color: AppColors.secondary),
              tooltip: 'Preview',
              onPressed: onPreview,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error),
              tooltip: l10n.deleteVideo,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
