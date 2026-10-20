import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/models/project.dart';
import 'package:plan_pad/providers/auth_provider.dart';
import 'package:plan_pad/providers/user_provider.dart';
import 'package:plan_pad/services/project_service.dart';

final projectRepositoryProvider = Provider(
  (ref) => ProjectRepository(FirebaseFirestore.instance),
);

final myProjectsProvider = StreamProvider.family<List<Project>, bool>((
  ref,
  getAll,
) {
  final user = ref.watch(currentUserProvider).value;
  if (user == null) return Stream.value(const <Project>[]);
  final repo = ref.watch(projectRepositoryProvider);
  if (getAll) repo.watchAll();
  return user.appRole == 'admin' ? repo.watchAll() : repo.watchForUser(user.id);
});

final projectStatsProvider = StreamProvider.autoDispose
    .family<ProjectStats, String>(
      (ref, projectId) =>
          ref.watch(projectRepositoryProvider).watchStats(projectId),
    );

// uid -> user, used to show names on the project cards and in the add-member list
final usersMapProvider = StreamProvider<Map<String, AppUser>>((ref) {
  final uid = ref.watch(authStateProvider.select((a) => a.value?.uid));
  if (uid == null) return Stream.value(const <String, AppUser>{});
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((s) => {for (final d in s.docs) d.id: AppUser.fromDoc(d)});
});

final projectProvider = StreamProvider.autoDispose.family<Project?, String>(
  (ref, projectId) => ref.watch(projectRepositoryProvider).watchProject(projectId),
);