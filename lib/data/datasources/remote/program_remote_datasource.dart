import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:level_bot/core/constants/app_constants.dart';
import 'package:level_bot/core/errors/exceptions.dart';
import 'package:level_bot/data/models/program_model.dart';
import 'package:uuid/uuid.dart';

abstract class ProgramRemoteDataSource {
  Future<List<ProgramModel>> getUserPrograms(String userId);
  Future<ProgramModel> getProgramById(String programId);
  Future<ProgramModel> createProgram(ProgramModel program);
  Future<ProgramModel> updateProgram(ProgramModel program);
  Future<void> deleteProgram(String programId);
  Future<ProgramModel> duplicateProgram(String programId);
  Future<void> archiveProgram(String programId);
  Future<void> unarchiveProgram(String programId);
  Future<List<ProgramModel>> getPublicPrograms({int limit, String? lastProgramId});
  Future<List<ProgramModel>> searchPublicPrograms(String query);
  Future<void> saveProgram({required String userId, required String programId});
  Future<void> likeProgram({required String userId, required String programId});
  Future<void> unlikeProgram({required String userId, required String programId});
}

class ProgramRemoteDataSourceImpl implements ProgramRemoteDataSource {
  ProgramRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  CollectionReference get _collection =>
      _firestore.collection(AppConstants.programsCollection);

  @override
  Future<List<ProgramModel>> getUserPrograms(String userId) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: userId)
          .where('isArchived', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => ProgramModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch programs: $e');
    }
  }

  @override
  Future<ProgramModel> getProgramById(String programId) async {
    try {
      final doc = await _collection.doc(programId).get();
      if (!doc.exists) {
        throw const ServerException(message: 'Program not found', statusCode: 404);
      }
      return ProgramModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch program: $e');
    }
  }

  @override
  Future<ProgramModel> createProgram(ProgramModel program) async {
    try {
      final docRef = _collection.doc();
      final newProgram = ProgramModel(
        id: docRef.id,
        userId: program.userId,
        name: program.name,
        days: program.days,
        description: program.description,
        imageUrl: program.imageUrl,
        goal: program.goal,
        duration: program.duration,
        daysPerWeek: program.daysPerWeek,
        difficulty: program.difficulty,
        isPublic: program.isPublic,
        isArchived: false,
        createdAt: DateTime.now(),
        tags: program.tags,
        equipment: program.equipment,
      );
      await docRef.set(newProgram.toFirestore());
      return newProgram;
    } catch (e) {
      throw ServerException(message: 'Failed to create program: $e');
    }
  }

  @override
  Future<ProgramModel> updateProgram(ProgramModel program) async {
    try {
      final data = program.toFirestore();
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _collection.doc(program.id).update(data);
      final doc = await _collection.doc(program.id).get();
      return ProgramModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(message: 'Failed to update program: $e');
    }
  }

  @override
  Future<void> deleteProgram(String programId) async {
    try {
      await _collection.doc(programId).delete();
    } catch (e) {
      throw ServerException(message: 'Failed to delete program: $e');
    }
  }

  @override
  Future<ProgramModel> duplicateProgram(String programId) async {
    try {
      final original = await getProgramById(programId);
      final docRef = _collection.doc();
      final duplicate = ProgramModel(
        id: docRef.id,
        userId: original.userId,
        name: '${original.name} (Copy)',
        days: original.days,
        description: original.description,
        goal: original.goal,
        duration: original.duration,
        daysPerWeek: original.daysPerWeek,
        difficulty: original.difficulty,
        isPublic: false,
        isArchived: false,
        createdAt: DateTime.now(),
        tags: original.tags,
        equipment: original.equipment,
      );
      await docRef.set(duplicate.toFirestore());
      return duplicate;
    } catch (e) {
      throw ServerException(message: 'Failed to duplicate program: $e');
    }
  }

  @override
  Future<void> archiveProgram(String programId) async {
    try {
      await _collection.doc(programId).update({
        'isArchived': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to archive program: $e');
    }
  }

  @override
  Future<void> unarchiveProgram(String programId) async {
    try {
      await _collection.doc(programId).update({
        'isArchived': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ServerException(message: 'Failed to unarchive program: $e');
    }
  }

  @override
  Future<List<ProgramModel>> getPublicPrograms({
    int limit = 20,
    String? lastProgramId,
  }) async {
    try {
      Query query = _collection
          .where('isPublic', isEqualTo: true)
          .where('isArchived', isEqualTo: false)
          .orderBy('likesCount', descending: true)
          .limit(limit);

      if (lastProgramId != null) {
        final lastDoc = await _collection.doc(lastProgramId).get();
        query = query.startAfterDocument(lastDoc);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => ProgramModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch public programs: $e');
    }
  }

  @override
  Future<List<ProgramModel>> searchPublicPrograms(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final snapshot = await _collection
          .where('isPublic', isEqualTo: true)
          .where('name', isGreaterThanOrEqualTo: lowerQuery)
          .where('name', isLessThanOrEqualTo: '$lowerQuery')
          .limit(30)
          .get();
      return snapshot.docs
          .map((doc) => ProgramModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search programs: $e');
    }
  }

  @override
  Future<void> saveProgram({
    required String userId,
    required String programId,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.set(
        _firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .collection('savedPrograms')
            .doc(programId),
        {
          'savedAt': Timestamp.fromDate(DateTime.now()),
          'programId': programId,
        },
      );
      batch.update(
        _collection.doc(programId),
        {'savesCount': FieldValue.increment(1)},
      );
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to save program: $e');
    }
  }

  @override
  Future<void> likeProgram({
    required String userId,
    required String programId,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.set(
        _collection.doc(programId).collection('likes').doc(userId),
        {'likedAt': Timestamp.fromDate(DateTime.now())},
      );
      batch.update(
        _collection.doc(programId),
        {'likesCount': FieldValue.increment(1)},
      );
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to like program: $e');
    }
  }

  @override
  Future<void> unlikeProgram({
    required String userId,
    required String programId,
  }) async {
    try {
      final batch = _firestore.batch();
      batch.delete(
        _collection.doc(programId).collection('likes').doc(userId),
      );
      batch.update(
        _collection.doc(programId),
        {'likesCount': FieldValue.increment(-1)},
      );
      await batch.commit();
    } catch (e) {
      throw ServerException(message: 'Failed to unlike program: $e');
    }
  }
}
