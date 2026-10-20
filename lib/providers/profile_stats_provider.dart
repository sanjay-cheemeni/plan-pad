import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/providers/project_provider.dart'; // myProjectsProvider
import 'package:plan_pad/providers/task_provider.dart'; // allTasksProvider
import 'package:plan_pad/providers/user_provider.dart'; // currentUserProvider

class ProfileStats {
  const ProfileStats({required this.projects, required this.openTasks});
  final int projects; // projects the user belongs to
  final int openTasks; // tasks assigned to the user that are not Done or Cancelled
}

final profileStatsProvider = Provider.autoDispose<AsyncValue<ProfileStats>>((ref) {
  final me = ref.watch(currentUserProvider).value;
  final projects = ref.watch(myProjectsProvider(false)); // false = only my own projects
  final tasks = ref.watch(allTasksProvider);

  if (me == null) return const AsyncLoading<ProfileStats>();
  if (projects.hasError) {
    return AsyncError<ProfileStats>(projects.error!, projects.stackTrace ?? StackTrace.empty);
  }
  if (tasks.hasError) {
    return AsyncError<ProfileStats>(tasks.error!, tasks.stackTrace ?? StackTrace.empty);
  }
  if (!projects.hasValue || !tasks.hasValue) return const AsyncLoading<ProfileStats>();

  return AsyncData(ProfileStats(
    projects: projects.value!.length,
    openTasks: tasks.value!.where((t) => t.assigneeId == me.id && !t.isClosed).length,
  ));
});