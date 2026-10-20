
class DashboardStats {
final int todo;
final int inProgress;
final int inReview;
final int overdue;
final int doneThisWeek;
final int weeklyTarget;
final int urgent;
final int high;
final int medium;
final int low;

const DashboardStats({
required this.todo,
required this.inProgress,
required this.inReview,
required this.overdue,
required this.doneThisWeek,
required this.weeklyTarget,
required this.urgent,
required this.high,
required this.medium,
required this.low,
});

double get weeklyProgress =>
weeklyTarget == 0 ? 0 : (doneThisWeek / weeklyTarget).clamp(0.0, 1.0);
}