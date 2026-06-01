import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/core/constants/app_constants.dart';
import 'package:level_bot/core/errors/exceptions.dart';
import 'package:level_bot/data/models/exercise_model.dart';
import 'package:level_bot/domain/entities/exercise_entity.dart';

abstract class ExerciseRemoteDataSource {
  Future<List<ExerciseModel>> getAllExercises();
  Future<List<ExerciseModel>> getExercisesByMuscleGroup(MuscleGroup group);
  Future<List<ExerciseModel>> getExercisesByEquipment(Equipment equipment);
  Future<List<ExerciseModel>> searchExercises(String query);
  Future<ExerciseModel> getExerciseById(String exerciseId);
  Future<ExerciseModel> createCustomExercise(ExerciseModel exercise);
  Future<ExerciseModel> updateExercise(ExerciseModel exercise);
  Future<void> deleteExercise(String exerciseId);
}

class ExerciseRemoteDataSourceImpl implements ExerciseRemoteDataSource {
  ExerciseRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _collection =>
      _firestore.collection(AppConstants.exercisesCollection);

  @override
  Future<List<ExerciseModel>> getAllExercises() async {
    try {
      final snapshot = await _collection
          .orderBy('name')
          .get();
      return snapshot.docs
          .map((doc) => ExerciseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch exercises: $e');
    }
  }

  @override
  Future<List<ExerciseModel>> getExercisesByMuscleGroup(
      MuscleGroup group) async {
    try {
      final snapshot = await _collection
          .where('primaryMuscle', isEqualTo: group.name)
          .orderBy('name')
          .get();
      return snapshot.docs
          .map((doc) => ExerciseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch exercises: $e');
    }
  }

  @override
  Future<List<ExerciseModel>> getExercisesByEquipment(
      Equipment equipment) async {
    try {
      final snapshot = await _collection
          .where('equipment', isEqualTo: equipment.name)
          .orderBy('name')
          .get();
      return snapshot.docs
          .map((doc) => ExerciseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch exercises: $e');
    }
  }

  @override
  Future<List<ExerciseModel>> searchExercises(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final snapshot = await _collection
          .where('name', isGreaterThanOrEqualTo: lowerQuery)
          .where('name', isLessThanOrEqualTo: '$lowerQuery')
          .limit(50)
          .get();
      return snapshot.docs
          .map((doc) => ExerciseModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search exercises: $e');
    }
  }

  @override
  Future<ExerciseModel> getExerciseById(String exerciseId) async {
    try {
      final doc = await _collection.doc(exerciseId).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Exercise not found', statusCode: 404);
      }
      return ExerciseModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch exercise: $e');
    }
  }

  @override
  Future<ExerciseModel> createCustomExercise(ExerciseModel exercise) async {
    try {
      final docRef = await _collection.add(exercise.toFirestore());
      final doc = await docRef.get();
      return ExerciseModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to create exercise: $e');
    }
  }

  @override
  Future<ExerciseModel> updateExercise(ExerciseModel exercise) async {
    try {
      await _collection.doc(exercise.id).update(exercise.toFirestore());
      final doc = await _collection.doc(exercise.id).get();
      return ExerciseModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update exercise: $e');
    }
  }

  @override
  Future<void> deleteExercise(String exerciseId) async {
    try {
      await _collection.doc(exerciseId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete exercise: $e');
    }
  }
}
