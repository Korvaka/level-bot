import 'package:flutter/material.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';

class MuscleZoneEntity {
  const MuscleZoneEntity({
    required this.id,
    required this.displayName,
    required this.muscleGroup,
    required this.view,
    required this.polygon,
    this.popularity = 5,
    this.difficulty = 5,
    this.imageUrl,
  });

  final String id;           // e.g. 'chest', 'traps', 'lats', 'obliques'
  final String displayName;  // e.g. 'Pectoraux', 'Trapèzes'
  final MuscleGroup muscleGroup;
  final String view;         // 'front' or 'back'
  final List<Offset> polygon; // normalized 0-1 coordinates
  final int popularity;
  final int difficulty;
  final String? imageUrl;

  MuscleZoneEntity copyWith({
    String? id,
    String? displayName,
    MuscleGroup? muscleGroup,
    String? view,
    List<Offset>? polygon,
    int? popularity,
    int? difficulty,
    String? imageUrl,
  }) =>
      MuscleZoneEntity(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        muscleGroup: muscleGroup ?? this.muscleGroup,
        view: view ?? this.view,
        polygon: polygon ?? this.polygon,
        popularity: popularity ?? this.popularity,
        difficulty: difficulty ?? this.difficulty,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  factory MuscleZoneEntity.fromFirestore(Map<String, dynamic> data) {
    final polygonData = (data['polygon'] as List<dynamic>?) ?? [];
    return MuscleZoneEntity(
      id: data['id'] as String,
      displayName: data['displayName'] as String,
      muscleGroup: MuscleGroup.values.firstWhere(
        (m) => m.name == data['muscleGroup'],
        orElse: () => MuscleGroup.fullBody,
      ),
      view: data['view'] as String? ?? 'front',
      polygon: polygonData.map((p) {
        final point = p as Map<String, dynamic>;
        return Offset(
          (point['x'] as num).toDouble(),
          (point['y'] as num).toDouble(),
        );
      }).toList(),
      popularity: (data['popularity'] as int?) ?? 5,
      difficulty: (data['difficulty'] as int?) ?? 5,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'displayName': displayName,
        'muscleGroup': muscleGroup.name,
        'view': view,
        'polygon': polygon.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
        'popularity': popularity,
        'difficulty': difficulty,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
}
