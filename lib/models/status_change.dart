import 'package:cloud_firestore/cloud_firestore.dart';

class StatusChange {
  const StatusChange({
    required this.id,
    required this.fromStatus,
    required this.toStatus,
    required this.changedByName,
    required this.at,
  });

  final String id;
  final String? fromStatus; // null = task was just created
  final String toStatus;
  final String changedByName;
  final DateTime at;

  factory StatusChange.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    // deviceTime is always set, even offline. changedAt is empty until the server confirms.
    final ts = (d['changedAt'] ?? d['deviceTime']) as Timestamp?;
    return StatusChange(
      id: doc.id,
      fromStatus: d['fromStatus'],
      toStatus: d['toStatus'] ?? '',
      changedByName: d['changedByName'] ?? '',
      at: ts?.toDate() ?? DateTime.now(),
    );
  }
}