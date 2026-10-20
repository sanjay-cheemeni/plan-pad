import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_pad/models/project.dart';

class ProjectRepository {
  ProjectRepository(this._db);
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('projects');

  List<Project> _toList(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map(Project.fromDoc).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  // Manager: only projects they belong to (uses the memberIds + isArchived index)
  Stream<List<Project>> watchForUser(String uid) => _col
      .where('memberIds', arrayContains: uid)
      .where('isArchived', isEqualTo: false)
      .snapshots()
      .map(_toList);

  // Admin: every project
  Stream<List<Project>> watchAll() =>
      _col.where('isArchived', isEqualTo: false).snapshots().map(_toList);

  Future<void> createProject({
    required String name,
    required String description,
    required String creatorId,
    required Map<String,dynamic>  members,
  }) {
    final ref = _col.doc(); // id is made on the phone, so it works offline
    return ref.set({
      'name': name,
      'description': description,
      'createdBy': creatorId,
      'members': {creatorId: 'manager'},
      'members': members,
      'isArchived': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Add a member, or change an existing member's role
  Future<void> setMember(String projectId, String uid, String role) =>
      _col.doc(projectId).update({
        'members.$uid': role,
        'memberIds': FieldValue.arrayUnion([uid]),
      });

  Future<void> removeMember(String projectId, String uid) =>
      _col.doc(projectId).update({
        'members.$uid': FieldValue.delete(),
        'memberIds': FieldValue.arrayRemove([uid]),
      });

  Future<void> archive(String projectId) =>
      _col.doc(projectId).update({'isArchived': true});

  // Open task and bug counts. Counted on the phone, so it also works offline.
  Stream<ProjectStats> watchStats(String projectId) => _db
      .collection('tasks')
      .where('projectId', isEqualTo: projectId)
      .snapshots()
      .map((s) {
        var open = 0, bugs = 0;
        for (final d in s.docs) {
          final m = d.data();
          if (m['isDeleted'] == true) continue;
          final st = m['status'];
          if (st == 'done' || st == 'cancelled') continue;
          open++;
          if (m['type'] == 'bug') bugs++;
        }
        return ProjectStats(open: open, bugs: bugs);
      });
  Stream<Project?> watchProject(String projectId) => _col
      .doc(projectId)
      .snapshots()
      .map((d) => d.exists ? Project.fromDoc(d) : null);
}
