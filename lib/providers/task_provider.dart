import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:plan_pad/models/project.dart';
import 'package:plan_pad/models/status_change.dart';
import 'package:plan_pad/models/task.dart';
import 'package:plan_pad/providers/project_provider.dart';
import 'package:plan_pad/providers/user_provider.dart';
import 'package:plan_pad/services/task_service.dart';

final taskRepositoryProvider = Provider(
  (ref) => TaskRepository(FirebaseFirestore.instance),
);

// Every project the user belongs to (admin: all projects). Works for every role.
final visibleProjectsProvider = StreamProvider<List<Project>>((ref) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const <Project>[]);
  final repo = ref.watch(projectRepositoryProvider);
  return user.appRole == 'admin' ? repo.watchAll() : repo.watchForUser(user.id);
});

final projectTasksProvider = StreamProvider.autoDispose
    .family<List<TaskItem>, String>(
      (ref, projectId) =>
          ref.watch(taskRepositoryProvider).watchProjectTasks(projectId),
    );

final allTasksProvider = Provider.autoDispose<AsyncValue<List<TaskItem>>>((
  ref,
) {
  final projects = ref.watch(visibleProjectsProvider);
  return projects.when(
    loading: () => const AsyncLoading<List<TaskItem>>(),
    error: (e, st) => AsyncError<List<TaskItem>>(e, st),
    data: (list) {
      final all = <TaskItem>[];
      for (final p in list) {
        final t = ref.watch(projectTasksProvider(p.id));
        if (t.hasError)
          return AsyncError<List<TaskItem>>(
            t.error!,
            t.stackTrace ?? StackTrace.empty,
          );
        if (!t.hasValue) return const AsyncLoading<List<TaskItem>>();
        all.addAll(t.value!);
      }
      all.sort((a, b) {
        if (a.isClosed != b.isClosed)
          return a.isClosed ? 1 : -1; // open tasks first
        final r = a.priorityRank.compareTo(b.priorityRank);
        if (r != 0) return r;
        final ad = a.dueDate, bd = b.dueDate;
        if (ad == null || bd == null)
          return ad == null ? (bd == null ? 0 : 1) : -1;
        return ad.compareTo(bd);
      });
      return AsyncData(all);
    },
  );
});

enum TaskFilter { all, urgent, bugs, tasks }

enum TaskSort { priority, dueDate, title }

final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);
final taskSearchProvider = StateProvider<String>((ref) => '');
final taskSortProvider = StateProvider<TaskSort>((ref) => TaskSort.priority);

int _compareDue(TaskItem a, TaskItem b) {
  final ad = a.dueDate, bd = b.dueDate;
  if (ad == null && bd == null) return 0;
  if (ad == null) return 1; // no due date goes last
  if (bd == null) return -1;
  return ad.compareTo(bd);
}

int _compareTasks(TaskItem a, TaskItem b, TaskSort sort) {
  if (a.isClosed != b.isClosed)
    return a.isClosed ? 1 : -1; // Done and Cancelled always last
  switch (sort) {
    case TaskSort.priority: // priority, then due date
      final r = a.priorityRank.compareTo(b.priorityRank);
      return r != 0 ? r : _compareDue(a, b);
    case TaskSort.dueDate: // due date, then priority
      final r = _compareDue(a, b);
      return r != 0 ? r : a.priorityRank.compareTo(b.priorityRank);
    case TaskSort.title:
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }
}

class ProjectSummary {
  const ProjectSummary({
    required this.open,
    required this.bugs,
    required this.top,
  });
  final int open; // not Done or Cancelled
  final int bugs; // open tasks of type bug
  final List<TaskItem> top; // the 2 most important open tasks
}

final projectSummaryProvider = Provider.autoDispose
    .family<AsyncValue<ProjectSummary>, String>((ref, projectId) {
      return ref.watch(projectTasksProvider(projectId)).whenData((tasks) {
        // The query already sorts by priority, then due date
        final open = tasks.where((t) => !t.isClosed).toList();
        return ProjectSummary(
          open: open.length,
          bugs: open.where((t) => t.isBug).length,
          top: open.take(2).toList(),
        );
      });
    });

final filteredTasksProvider = Provider.autoDispose<AsyncValue<List<TaskItem>>>((
  ref,
) {
  final filter = ref.watch(taskFilterProvider);
  final sort = ref.watch(taskSortProvider);
  final q = ref.watch(taskSearchProvider).trim().toLowerCase();

  return ref.watch(allTasksProvider).whenData((list) {
    final result = list.where((t) {
      final okFilter = switch (filter) {
        TaskFilter.all => true,
        TaskFilter.urgent => t.priority == 'urgent',
        TaskFilter.bugs => t.isBug,
        TaskFilter.tasks => !t.isBug,
      };
      return okFilter && (q.isEmpty || t.title.toLowerCase().contains(q));
    }).toList();
    result.sort((a, b) => _compareTasks(a, b, sort));
    return result;
  });
});

final taskProvider = StreamProvider.autoDispose.family<TaskItem?, String>(
  (ref, taskId) => ref.watch(taskRepositoryProvider).watchTask(taskId),
);

final statusHistoryProvider = StreamProvider.autoDispose
    .family<List<StatusChange>, String>(
      (ref, taskId) => ref.watch(taskRepositoryProvider).watchHistory(taskId),
    );
