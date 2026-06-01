import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.username,
    required super.userDisplayName,
    super.userPhotoUrl,
    required super.content,
    super.mediaUrls,
    super.workoutSessionId,
    super.programId,
    required super.createdAt,
    super.updatedAt,
    super.likesCount,
    super.commentsCount,
    super.sharesCount,
    super.isLikedByCurrentUser,
    super.tags,
    super.workoutSummary,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc,
      {bool isLiked = false}) {
    final data = doc.data() as Map<String, dynamic>;
    WorkoutSummary? workoutSummary;
    if (data['workoutSummary'] != null) {
      final ws = data['workoutSummary'] as Map<String, dynamic>;
      workoutSummary = WorkoutSummary(
        duration: Duration(seconds: ws['durationSeconds'] as int? ?? 0),
        totalVolume: (ws['totalVolume'] as num?)?.toDouble() ?? 0,
        totalSets: ws['totalSets'] as int? ?? 0,
        exerciseNames:
            List<String>.from(ws['exerciseNames'] as List? ?? []),
        personalRecordsCount: ws['personalRecordsCount'] as int? ?? 0,
      );
    }
    return PostModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? '',
      userDisplayName: data['userDisplayName'] as String? ?? '',
      userPhotoUrl: data['userPhotoUrl'] as String?,
      content: data['content'] as String? ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] as List? ?? []),
      workoutSessionId: data['workoutSessionId'] as String?,
      programId: data['programId'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      likesCount: data['likesCount'] as int? ?? 0,
      commentsCount: data['commentsCount'] as int? ?? 0,
      sharesCount: data['sharesCount'] as int? ?? 0,
      isLikedByCurrentUser: isLiked,
      tags: List<String>.from(data['tags'] as List? ?? []),
      workoutSummary: workoutSummary,
    );
  }

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      userId: entity.userId,
      username: entity.username,
      userDisplayName: entity.userDisplayName,
      userPhotoUrl: entity.userPhotoUrl,
      content: entity.content,
      mediaUrls: entity.mediaUrls,
      workoutSessionId: entity.workoutSessionId,
      programId: entity.programId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      likesCount: entity.likesCount,
      commentsCount: entity.commentsCount,
      sharesCount: entity.sharesCount,
      isLikedByCurrentUser: entity.isLikedByCurrentUser,
      tags: entity.tags,
      workoutSummary: entity.workoutSummary,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'userDisplayName': userDisplayName,
      'userPhotoUrl': userPhotoUrl,
      'content': content,
      'mediaUrls': mediaUrls,
      'workoutSessionId': workoutSessionId,
      'programId': programId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'tags': tags,
      'workoutSummary': workoutSummary != null
          ? {
              'durationSeconds': workoutSummary!.duration.inSeconds,
              'totalVolume': workoutSummary!.totalVolume,
              'totalSets': workoutSummary!.totalSets,
              'exerciseNames': workoutSummary!.exerciseNames,
              'personalRecordsCount':
                  workoutSummary!.personalRecordsCount,
            }
          : null,
    };
  }
}
