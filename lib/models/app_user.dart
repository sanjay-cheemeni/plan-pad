
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.appRole,
    required this.isActive,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String appRole; 
  final bool isActive;
  final DateTime? createdAt;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AppUser(
      id: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      appRole: d['appRole'] ?? 'member',
      isActive: d['isActive'] ?? true,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  bool get isManager => appRole == 'manager' || appRole == 'admin';
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();
  String get roleLabel => appRole[0].toUpperCase() + appRole.substring(1);


String  toString() => '${name}\n$email\n$roleLabel'; 
}