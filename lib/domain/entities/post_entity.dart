import 'package:equatable/equatable.dart';

class PostEntity extends Equatable {
  const PostEntity({
    required this.id,
    required this.userId,
    required this.username,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.content,
    this.mediaUrls = const [],
    this.workoutSessionId,
    this.programId,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLikedByCurrentUser = false,
    this.tags = const [],
    this.workoutSummary,
  });

  final String id;
  final String userId;
  final String username;
  final String userDisplayName;
  final String? userPhotoUrl;
  final String content;
  final List<String> mediaUrls;
  final String? workoutSessionId;
  final String? programId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLikedByCurrentUser;
  final List<String> tags;
  final WorkoutSummary? workoutSummary;

  @override
  List<Object?> get props => [
        id,
        userId,
        content,
        createdAt,
        likesCount,
        commentsCount,
        isLikedByCurrentUser,
      ];

  PostEntity copyWith({
    String? id,
    String? userId,
    String? username,
    String? userDisplayName,
    String? userPhotoUrl,
    String? content,
    List<String>? mediaUrls,
    String? workoutSessionId,
    String? programId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLikedByCurrentUser,
    List<String>? tags,
    WorkoutSummary? workoutSummary,
  }) {
    return PostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      workoutSessionId: workoutSessionId ?? this.workoutSessionId,
      programId: programId ?? this.programId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLikedByCurrentUser: isLikedByCurrentUser ?? this.isLikedByCurrentUser,
      tags: tags ?? this.tags,
      workoutSummary: workoutSummary ?? this.workoutSummary,
    );
  }
}

class WorkoutSummary extends Equatable {
  const WorkoutSummary({
    required this.duration,
    required this.totalVolume,
    required this.totalSets,
    required this.exerciseNames,
    this.personalRecordsCount = 0,
  });

  final Duration duration;
  final double totalVolume;
  final int totalSets;
  final List<String> exerciseNames;
  final int personalRecordsCount;

  @override
  List<Object?> get props => [
        duration,
        totalVolume,
        totalSets,
        exerciseNames,
        personalRecordsCount,
      ];
}
