import 'package:cloud_firestore/cloud_firestore.dart';

const projectRoles = ['manager', 'dev', 'test'];

// String roleLabel(String r) =>
//     r.isEmpty ? r : r[0].toUpperCase() + r.substring(1);

String roleLabel(String r) {
  if (r.isEmpty) return r;
  switch (r) {
    case 'manager':
      return 'Manager';
    case 'test':
      return 'Tester';
    case 'dev':
      return 'Developer';
    default:
      return 'Member';
  }
}

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.members,
    required this.isArchived,
  });

  final String id;
  final String name;
  final String description;
  final String createdBy;
  final Map<String, String> members;
  final bool isArchived;

  factory Project.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Project(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      createdBy: d['createdBy'] ?? '',
      members: Map<String, String>.from(d['members'] ?? {}),
      isArchived: d['isArchived'] ?? false,
    );
  }

  String toString() => '$id: $name [$members]';
}

class ProjectStats {
  const ProjectStats({this.open = 0, this.bugs = 0});
  final int open;
  final int bugs;
}
