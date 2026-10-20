import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/models/project.dart'; // projectRoles, roleLabel
import 'package:plan_pad/providers/add_project_provider.dart';
import 'package:plan_pad/screens/dashboard/task/add_task_page.dart'; // TypeItem
import 'package:plan_pad/screens/success/project_success_page.dart';
import 'package:plan_pad/shared/widgets/snackbar.dart';

class AddProjectPage extends ConsumerStatefulWidget {
  const AddProjectPage({super.key});

  @override
  ConsumerState<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends ConsumerState<AddProjectPage> {
  final _name = TextEditingController();
  final _desc = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ok = await ref
        .read(addProjectControllerProvider.notifier)
        .add(
          name: _name.text,
          description: _desc.text,
          members: ref.read(newProjectMembersProvider),
        );
    if (ok && mounted)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => ProjectSuccessPage()),
      );
  }

  InputDecoration _decoration(String hint) {
    final noLine = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    return InputDecoration(
      hintText: hint,
      filled: true,
      border: noLine,
      enabledBorder: noLine,
      focusedBorder: noLine,
      disabledBorder: noLine,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(addProjectControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        AppSnackbar.error(context, next.error.toString());
      }
    });

    final state = ref.watch(addProjectControllerProvider);
    final selected = ref.watch(
      newProjectMembersProvider,
    ); // uid -> project role
    final candidates = ref.watch(
      memberCandidatesProvider,
    ); // active users, not me
    final team = ref.read(newProjectMembersProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: const Text(
          'Add Project',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w100,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _Label('Project name'),
            TextField(
              enabled: !state.isLoading,
              controller: _name,
              textCapitalization: TextCapitalization.words,
              inputFormatters: [LengthLimitingTextInputFormatter(50)],
              decoration: _decoration('Project name'),
            ),
            const SizedBox(height: 15),

            const _Label('Description (optional)'),
            TextField(
              enabled: !state.isLoading,
              controller: _desc,
              minLines: 2,
              maxLines: 5,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              decoration: _decoration('What is this project about?'),
            ),
            const SizedBox(height: 16),

            _Label(
              'Team members${selected.isEmpty ? '' : ' · ${selected.length} selected'}',
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'You will be added as the project manager. Pick anyone else to add now, or add them later.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),

            if (candidates.isEmpty)
              const Text(
                'No other users yet.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              )
            else
              for (final u in candidates)
                _MemberTile(
                  user: u,
                  role: selected[u.id],
                  onToggle: () {
                    if (state.isLoading) return;
                    selected.containsKey(u.id)
                        ? team.remove(u.id)
                        : team.set(u.id, 'dev');
                  },
                  onRole: (r) => team.set(u.id, r),
                ),

            const SizedBox(height: 16),
            FilledButton(
              onPressed: state.isLoading ? null : _save,
              child: const Text('Save Project'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      height: 2,
      fontWeight: FontWeight.w900,
      color: AppColors.textSecondary,
    ),
  );
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.user,
    required this.role, // null = not selected
    required this.onToggle,
    required this.onRole,
  });

  final AppUser user;
  final String? role;
  final VoidCallback onToggle;
  final ValueChanged<String> onRole;

  @override
  Widget build(BuildContext context) {
    final isSelected = role != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: isSelected
            ? Border.all(color: AppColors.primary, width: 1.2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isSelected
                        ? AppColors.primary
                        : AppColors.surfaceHigh,
                    child: Text(
                      user.initial,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.background
                            : AppColors.textSoft,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, bottom: 12),
              child: Wrap(
                children: [
                  for (final r in projectRoles)
                    TypeItem(
                      title: roleLabel(r),
                      isSelected: role == r,
                      onSelect: () => onRole(r),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
