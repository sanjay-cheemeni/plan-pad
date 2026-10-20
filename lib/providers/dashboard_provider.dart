import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/models/dashboard_stat.dart';
import 'package:plan_pad/models/task.dart';
import 'package:plan_pad/providers/task_provider.dart';


final dashboardStatsProvider =
Provider.autoDispose<AsyncValue<DashboardStats>>((ref) {
return ref.watch(allTasksProvider).whenData((tasks) {
final now = DateTime.now();
final today = DateTime(now.year, now.month, now.day);


// Monday at the beginning of the current week.
final weekStart = today.subtract(
  Duration(days: today.weekday - DateTime.monday),
);

bool hasStatus(TaskItem task, String status) =>
    task.status.toString().toLowerCase() == status.toLowerCase();

int countStatus(String status) =>
    tasks.where((t) => hasStatus(t, status)).length;

int countPriority(String priority) => tasks
    .where((t) =>
        !t.isClosed &&
        t.priority.toLowerCase() == priority.toLowerCase())
    .length;

final overdueTasks = tasks.where((t) {
  final dueDate = t.dueDate;
  return !t.isClosed &&
      dueDate != null &&
      dueDate.isBefore(today);
}).length;

// Requires TaskItem.completedAt to record when a task was completed.
final completedThisWeek = tasks.where((t) {
  final completedAt = t.dueDate;
  return t.isClosed &&
      completedAt != null &&
      !completedAt.isBefore(weekStart) &&
      completedAt.isBefore(weekStart.add(const Duration(days: 7)));
}).length;

return DashboardStats(
  todo: countStatus('todo'),
  inProgress: countStatus('in_progress'),
  inReview: countStatus('in_review'),
  overdue: overdueTasks,
  doneThisWeek: completedThisWeek,
  weeklyTarget: 30,
  urgent: countPriority('urgent'),
  high: countPriority('high'),
  medium: countPriority('medium'),
  low: countPriority('low'),
);


});
});
