import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/models/status_change.dart';
import 'package:plan_pad/models/task.dart';

class TaskRepository {
  TaskRepository(this._db);
  final FirebaseFirestore _db;

  // All tasks in one project. Uses the projectId + priorityRank + dueDate index.
  Stream<List<TaskItem>> watchProjectTasks(String projectId) => _db
      .collection('tasks')
      .where('projectId', isEqualTo: projectId)
      .orderBy('priorityRank')
      .orderBy('dueDate')
      .snapshots(
        includeMetadataChanges: true,
      ) // needed for the "Pending sync" mark
      .map(
        (s) => s.docs.map(TaskItem.fromDoc).where((t) => !t.isDeleted).toList(),
      );

  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required String type,
    required String priority,
    required String assigneeId,
    required String assigneeName,
    required DateTime dueDate,
    required AppUser creator,
  }) {
    final taskRef = _db
        .collection('tasks')
        .doc(); // id made on the phone, so it works offline
    final batch = _db.batch();

    batch.set(taskRef, {
      'projectId': projectId,
      'title': title,
      'description': description,
      'type': type,
      'priority': priority,
      'priorityRank': priorityRanks[priority],
      'status': 'todo',
      'assigneeId': assigneeId,
      'assigneeName': assigneeName,
      'createdBy': creator.id,
      'dueDate': Timestamp.fromDate(
        DateTime(dueDate.year, dueDate.month, dueDate.day),
      ),
      'tags': <String>[],
      'isDeleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': creator.id,
      'completedAt': null,
    });

    batch.set(taskRef.collection('statusHistory').doc(), {
      'fromStatus': null,
      'toStatus': 'todo',
      'changedBy': creator.id,
      'changedByName': creator.name,
      'changedAt': FieldValue.serverTimestamp(),
      'deviceTime': Timestamp.now(),
    });

    return batch.commit();
  }

  Future<void> changeStatus({
    required TaskItem task,
    required String newStatus,
    required AppUser by,
  }) {
    final ref = _db.doc('tasks/${task.id}');
    final batch = _db.batch();

    batch.update(ref, {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': by.id,
      'completedAt': newStatus == 'done' ? FieldValue.serverTimestamp() : null,
    });

    batch.set(ref.collection('statusHistory').doc(), {
      'fromStatus': task.status,
      'toStatus': newStatus,
      'changedBy': by.id,
      'changedByName': by.name,
      'changedAt': FieldValue.serverTimestamp(),
      'deviceTime': Timestamp.now(),
    });

    return batch
        .commit(); // the status and its history entry succeed or fail together
  }
  // One task, live. includeMetadataChanges gives the "Pending sync" flag.
Stream<TaskItem?> watchTask(String taskId) => _db
    .doc('tasks/$taskId')
    .snapshots(includeMetadataChanges: true)
    .map((d) => d.exists ? TaskItem.fromDoc(d) : null);

// Status history, newest first. A single-field sort, so no new index is needed.
Stream<List<StatusChange>> watchHistory(String taskId) => _db
    .collection('tasks/$taskId/statusHistory')
    .orderBy('deviceTime', descending: true)
    .snapshots()
    .map((s) => s.docs.map(StatusChange.fromDoc).toList());
}
