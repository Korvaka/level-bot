import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:level_bot/data/constants/default_muscle_zones.dart';
import 'package:level_bot/domain/entities/muscle_zone_entity.dart';

final muscleZonesProvider = FutureProvider<List<MuscleZoneEntity>>((ref) async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('muscle_zones').get();
    if (snapshot.docs.isEmpty) return defaultMuscleZones;
    return snapshot.docs
        .map((d) => MuscleZoneEntity.fromFirestore(d.data()))
        .toList();
  } catch (_) {
    return defaultMuscleZones;
  }
});
