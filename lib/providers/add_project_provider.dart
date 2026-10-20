import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/core/validator.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/providers/project_provider.dart'; // myProjectsProvider, usersMapProvider, projectRepositoryProvider
import 'package:plan_pad/providers/user_provider.dart'; // currentUserProvider

/// Users picked on the Add Project page: uid -> project role (manager | dev | test)
class NewProjectMembers extends Notifier<Map<String, String>> {
  @override
  Map<String, String> build() => {};

  void set(String uid, String role) => state = {...state, uid: role};
  void remove(String uid) => state = {...state}..remove(uid);
}

final newProjectMembersProvider =
    NotifierProvider.autoDispose<NewProjectMembers, Map<String, String>>(
      NewProjectMembers.new,
    );

/// Active users other than the logged-in user, sorted by name.
final memberCandidatesProvider = Provider.autoDispose<List<AppUser>>((ref) {
  final me = ref.watch(currentUserProvider).value;
  final users = ref.watch(usersMapProvider).value ?? const <String, AppUser>{};
  return users.values.where((u) => u.isActive && u.id != me?.id).toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
});

class AddProjectController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns true when the project is accepted.
  Future<bool> add({
    required String name,
    String description = '',
    Map<String, String> members = const {}, // uid -> project role
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final user = ref.read(currentUserProvider).value;
      final existing = ref.read(myProjectsProvider(true)).value ?? const [];

      // Your validator: checks the user and the name (throws a String)
      Validators.checkProject(
        user,
        name,
        description,
        existingNames: existing.map((p) => p.name),
      );
      Validators.checkProjectMembers(members);

      // Every chosen user must exist and be active
      final users =
          ref.read(usersMapProvider).value ?? const <String, AppUser>{};
      for (final uid in members.keys) {
        if (users[uid]?.isActive != true)
          throw 'A selected user is not available';
      }

      // Not awaited: while offline this future only completes after sync.
      // The project still shows up in the list straight away.
      ref
          .read(projectRepositoryProvider)
          .createProject(
            name: name.trim(),
            description: description.trim(),
            creatorId: user!.id,
            members: members,
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

final addProjectControllerProvider =
    AsyncNotifierProvider<AddProjectController, void>(AddProjectController.new);
