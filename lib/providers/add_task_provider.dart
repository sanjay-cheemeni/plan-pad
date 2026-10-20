import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/core/validator.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/models/project.dart';
import 'package:plan_pad/models/task.dart';
import 'package:plan_pad/providers/project_members_provider.dart';
import 'package:plan_pad/providers/project_provider.dart'; // myProjectsProvider
import 'package:plan_pad/providers/task_provider.dart';
import 'package:plan_pad/providers/user_provider.dart';

/// Step 1: projects shown in the Add Task "Project" dropdown.
/// Manager: the projects they belong to. Admin: all projects.
/// Anyone else gets an empty list. Archived projects are already left out.
final taskProjectsProvider = Provider.autoDispose<AsyncValue<List<Project>>>((
  ref,
) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return const AsyncData(<Project>[]);
  return ref.watch(myProjectsProvider(true)); // already sorted by name
});

/// The project id chosen in the form (null until chosen).
class NewTaskProjectId extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? id) => state = id;
}

final newTaskProjectIdProvider =
    NotifierProvider.autoDispose<NewTaskProjectId, String?>(
      NewTaskProjectId.new,
    );

/// The chosen Project. If the manager has only one project, it is picked automatically.
final selectedTaskProjectProvider = Provider.autoDispose<Project?>((ref) {
  final id = ref.watch(newTaskProjectIdProvider);
  final list = ref.watch(taskProjectsProvider).value ?? const <Project>[];
  if (list.isEmpty) return null;
  return list.where((p) => p.id == id).firstOrNull ??
      (list.length == 1 ? list.first : null);
});

class AddTaskController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns true when the task is accepted.
  /// Offline, it is saved on the phone and syncs later.
  Future<bool> add({
    required String projectId,
    required String title,
    String description = '',
    required String type, // 'task' | 'bug'
    required String priority, // 'urgent' | 'high' | 'medium' | 'low'
    required String assigneeId,
    required DateTime? dueDate,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw 'Please log in again';
      // if (!user.isManager) throw 'Only managers can create tasks';

      Validators.checkTask(
        projectId: projectId,
        title: title,
        description: description,
        type: type,
        priority: priority,
        assigneeId: assigneeId,
        dueDate: dueDate,
      );

      // The project must be one of the manager's projects
      final projects = ref.read(taskProjectsProvider).value ?? const [];
      if (!projects.any((p) => p.id == projectId))
        throw 'Select a valid project';

      // The assignee must be an active member of that project
      final members =
          ref.read(assignableMembersProvider(projectId)).value ?? const [];
      final assignee = members
          .where((m) => m.user.id == assigneeId)
          .firstOrNull;
      if (assignee == null)
        throw 'Assignee must be an active member of this project';

      // Not awaited: offline, this only completes after sync, but the task shows at once
      ref
          .read(taskRepositoryProvider)
          .createTask(
            projectId: projectId,
            title: title.trim(),
            description: description.trim(),
            type: type,
            priority: priority,
            assigneeId: assignee.user.id,
            assigneeName: assignee.user.name,
            dueDate: dueDate!,
            creator: user,
          )
          .catchError((Object e, StackTrace st) {
            state = AsyncError(
              e,
              st,
            ); // for example, permission denied by the rules
          });
    });

    return !state.hasError;
  }
}

final addTaskControllerProvider =
    AsyncNotifierProvider<AddTaskController, void>(AddTaskController.new);

class TaskStatusController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns true when the change is accepted.
  /// Offline, it is saved on the phone and syncs later.
  Future<bool> changeStatus(TaskItem task, String newStatus) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider).value;
      if (user == null) throw 'Please log in again';

      // Must belong to the task's project (admins can see all)
      final projects = ref.read(visibleProjectsProvider).value ?? const [];
      if (user.appRole != 'admin' &&
          !projects.any((p) => p.id == task.projectId)) {
        throw 'You are not a member of this project';
      }

      // Managers can change any task. Others only tasks assigned to them.
      if (!user.isManager && task.assigneeId != user.id) {
        throw 'Only the assignee or a manager can change this status';
      }

      Validators.checkStatusChange(
        from: task.status,
        to: newStatus,
        canReopen: user.isManager,
      );

      // Not awaited: offline, this only completes after sync, but the list updates at once
      ref
          .read(taskRepositoryProvider)
          .changeStatus(task: task, newStatus: newStatus, by: user)
          .catchError((Object e, StackTrace st) {
            state = AsyncError(
              e,
              st,
            ); // for example, permission denied by the rules
          });
    });

    return !state.hasError;
  }
}

final taskStatusControllerProvider =
    AsyncNotifierProvider<TaskStatusController, void>(TaskStatusController.new);

/// Statuses the user may move this task to (use for the status options).
List<String> availableStatuses(TaskItem task, AppUser user) {
  final closed = task.isClosed;
  if (closed && !user.isManager) return const [];
  if (!user.isManager && task.assigneeId != user.id) return const [];
  return statusLabels.keys.where((s) => s != task.status).toList();
}

class UserWorkload {
  const UserWorkload({this.open = 0, this.highPriority = 0});
  final int open; // tasks not Done or Cancelled
  final int highPriority; // of those, Urgent and High

  String get label =>
      highPriority > 0 ? '$open open · $highPriority high' : '$open open';
}

/// uid -> workload, counted from the tasks of one project.
final userWorkloadProvider = Provider.autoDispose
    .family<Map<String, UserWorkload>, String>((ref, projectId) {
      final tasks =
          ref.watch(projectTasksProvider(projectId)).value ??
          const <TaskItem>[];
      final result = <String, UserWorkload>{};
      for (final t in tasks) {
        if (t.isClosed) continue;
        final prev = result[t.assigneeId] ?? const UserWorkload();
        result[t.assigneeId] = UserWorkload(
          open: prev.open + 1,
          highPriority: prev.highPriority + (t.priorityRank <= 2 ? 1 : 0),
        );
      }
      return result;
    });
