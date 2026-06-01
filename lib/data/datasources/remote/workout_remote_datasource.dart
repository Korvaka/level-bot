import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/core/constants/app_constants.dart';
import 'package:level_bot/core/errors/exceptions.dart';
import 'package:level_bot/data/models/personal_record_model.dart';
import 'package:level_bot/data/models/workout_session_model.dart';

abstract class WorkoutRemoteDataSource {
  Future<WorkoutSessionModel> createWorkoutSession(WorkoutSessionModel session);
  Future<WorkoutSessionModel> updateWorkoutSession(WorkoutSessionModel session);
  Future<void> completeWorkoutSession(WorkoutSessionModel session);
  Future<void> cancelWorkoutSession(String sessionId);
  Future<List<WorkoutSessionModel>> getWorkoutHistory({
    required String userId,
    int limit,
    String? lastSessionId,
  });
  Future<WorkoutSessionModel> getWorkoutSessionById(String sessionId);
  Future<List<PersonalRecordModel>> getPersonalRecords(String userId);
  Future<List<PersonalRecordModel>> getExercisePRs({
    required String userId,
    required String exerciseId,
  });
  Future<WorkoutSessionModel?> getActiveSession(String userId);
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  WorkoutRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;

  CollectionReference get _sessionsCollection =>
      _firestore.collection(AppConstants.workoutSessionsCollection);

  CollectionReference get _prCollection =>
      _firestore.collection(AppConstants.personalRecordsCollection);

  @override
  Future<WorkoutSessionModel> createWorkoutSession(
      WorkoutSessionModel session) async {
    try {
      final docRef = _sessionsCollection.doc();
      final data = session.toFirestore();
      data['id'] = docRef.id;
      await docRef.set(data);
      final doc = await docRef.get();
      return WorkoutSessionModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to create workout session: $e');
    }
  }

  @override
  Future<WorkoutSessionModel> updateWorkoutSession(
      WorkoutSessionModel session) async {
    try {
      await _sessionsCollection
          .doc(session.id)
          .update(session.toFirestore());
      final doc = await _sessionsCollection.doc(session.id).get();
      return WorkoutSessionModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update workout session: $e');
    }
  }

  @override
  Future<void> completeWorkoutSession(WorkoutSessionModel session) async {
    try {
      final batch = _firestore.batch();

      final data = session.toFirestore();
      data['completedAt'] = Timestamp.fromDate(DateTime.now());
      data['status'] = 'completed';

      batch.update(_sessionsCollection.doc(session.id), data);

      batch.update(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(session.userId),
        {
          'workoutsCount': FieldValue.increment(1),
          'totalWorkoutMinutes':
              FieldValue.increment(session.durationSeconds ~/ 60),
        },
      );

      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to complete workout session: $e');
    }
  }

  @override
  Future<void> cancelWorkoutSession(String sessionId) async {
    try {
      await _sessionsCollection.doc(sessionId).update({
        'status': 'cancelled',
        'completedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to cancel workout session: $e');
    }
  }

  @override
  Future<List<WorkoutSessionModel>> getWorkoutHistory({
    required String userId,
    int limit = 20,
    String? lastSessionId,
  }) async {
    try {
      Query query = _sessionsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .limit(limit);

      if (lastSessionId != null) {
        final lastDoc = await _sessionsCollection.doc(lastSessionId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => WorkoutSessionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch workout history: $e');
    }
  }

  @override
  Future<WorkoutSessionModel> getWorkoutSessionById(
      String sessionId) async {
    try {
      final doc = await _sessionsCollection.doc(sessionId).get();
      if (!doc.exists) {
        throw const ServerException(
            message: 'Workout session not found', statusCode: 404);
      }
      return WorkoutSessionModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch workout session: $e');
    }
  }

  @override
  Future<List<PersonalRecordModel>> getPersonalRecords(
      String userId) async {
    try {
      final snapshot = await _prCollection
          .where('userId', isEqualTo: userId)
          .orderBy('achievedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PersonalRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch personal records: $e');
    }
  }

  @override
  Future<List<PersonalRecordModel>> getExercisePRs({
    required String userId,
    required String exerciseId,
  }) async {
    try {
      final snapshot = await _prCollection
          .where('userId', isEqualTo: userId)
          .where('exerciseId', isEqualTo: exerciseId)
          .orderBy('achievedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => PersonalRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch exercise PRs: $e');
    }
  }

  @override
  Future<WorkoutSessionModel?> getActiveSession(String userId) async {
    try {
      final snapshot = await _sessionsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'inProgress')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return WorkoutSessionModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch active session: $e');
    }
  }
}
