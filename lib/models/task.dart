import 'package:cloud_firestore/cloud_firestore.dart';

const priorityLabels = {
  'urgent': 'Urgent',
  'high': 'High',
  'medium': 'Medium',
  'low': 'Low',
};
const priorityRanks = {'urgent': 1, 'high': 2, 'medium': 3, 'low': 4};
const statusLabels = {
  'todo': 'To Do',
  'in_progress': 'In Progress',
  'in_review': 'In Review',
  'blocked': 'Blocked',
  'done': 'Done',
  'cancelled': 'Cancelled',
};
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

class TaskItem {
  const TaskItem({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.priorityRank,
    required this.status,
    required this.assigneeId,
    required this.assigneeName,
    required this.createdBy,
    required this.dueDate,
    required this.isDeleted,
    required this.hasPendingWrites,
  });

  final String id, projectId, title, description, type, priority, status;
  final String assigneeId, assigneeName, createdBy;
  final int priorityRank;
  final DateTime? dueDate;
  final bool isDeleted;
  final bool hasPendingWrites; // true = saved on the phone, not yet synced

  factory TaskItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return TaskItem(
      id: doc.id,
      projectId: d['projectId'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      type: d['type'] ?? 'task',
      priority: d['priority'] ?? 'medium',
      priorityRank: (d['priorityRank'] as num?)?.toInt() ?? 3,
      status: d['status'] ?? 'todo',
      assigneeId: d['assigneeId'] ?? '',
      assigneeName: d['assigneeName'] ?? '',
      createdBy: d['createdBy'] ?? '',
      dueDate: (d['dueDate'] as Timestamp?)?.toDate(),
      isDeleted: d['isDeleted'] ?? false,
      hasPendingWrites: doc.metadata.hasPendingWrites,
    );
  }

  bool get isBug => type == 'bug';
  bool get isClosed => status == 'done' || status == 'cancelled';
  String get statusLabel => statusLabels[status] ?? status;
  String get priorityLabel => priorityLabels[priority] ?? priority;

  String get dueText {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final diff = d.difference(today).inDays;
    final date = '${d.day} ${_months[d.month - 1]}';
    if (isClosed) return date;
    if (diff == 0) return 'Due today';
    if (diff < 0) return 'Overdue ${-diff}d';
    return 'Due $date';
  }

  String toString() => '${id}.${title}';
}
