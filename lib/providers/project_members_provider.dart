import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/models/project.dart';
import 'package:plan_pad/providers/project_provider.dart'; // usersMapProvider, myProjectsProvider

class ProjectMember {
  const ProjectMember(this.user, this.role);
  final AppUser user; // name, email, appRole, isActive
  final String role; // project role: manager | dev | test

  String get label => roleLabel(role); // "Manager", "Dev", "Test"
}

const _roleOrder = {'manager': 0, 'dev': 1, 'test': 2};

/// Members of one project, with full user details.
final projectMembersProvider = Provider.autoDispose
    .family<AsyncValue<List<ProjectMember>>, String>((ref, projectId) {
  final projects = ref.watch(myProjectsProvider(true));
  final users = ref.watch(usersMapProvider);

  if (projects.hasError) {
    return AsyncError<List<ProjectMember>>(
        projects.error!, projects.stackTrace ?? StackTrace.empty);
  }
  if (users.hasError) {
    return AsyncError<List<ProjectMember>>(
        users.error!, users.stackTrace ?? StackTrace.empty);
  }
  if (!projects.hasValue || !users.hasValue) {
    return const AsyncLoading<List<ProjectMember>>();
  }

  final project = projects.value!.where((p) => p.id == projectId).firstOrNull;
  if (project == null) return const AsyncData(<ProjectMember>[]);

  final members = <ProjectMember>[
    for (final e in project.members.entries)
      if (users.value![e.key] != null) ProjectMember(users.value![e.key]!, e.value),
  ]..sort((a, b) {
      final r = (_roleOrder[a.role] ?? 9).compareTo(_roleOrder[b.role] ?? 9);
      return r != 0 ? r : a.user.name.toLowerCase().compareTo(b.user.name.toLowerCase());
    });

  return AsyncData(members);
});

/// Active members only. Use this for the "Assign to" list in Add Task.
final assignableMembersProvider = Provider.autoDispose
    .family<AsyncValue<List<ProjectMember>>, String>((ref, projectId) {
  return ref
      .watch(projectMembersProvider(projectId))
      .whenData((list) => list.where((m) => m.user.isActive).toList());
});