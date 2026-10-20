import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/models/project.dart'; // projectRoles, roleLabel
import 'package:plan_pad/providers/project_provider.dart'; // projectProvider, usersMapProvider, projectRepositoryProvider
import 'package:plan_pad/shared/widgets/snackbar.dart';

Future<void> showManageMembersSheet(BuildContext context, String projectId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => ManageMembersSheet(projectId: projectId),
  );
}

class ManageMembersSheet extends ConsumerStatefulWidget {
  const ManageMembersSheet({super.key, required this.projectId});
  final String projectId;

  @override
  ConsumerState<ManageMembersSheet> createState() => _ManageMembersSheetState();
}

class _ManageMembersSheetState extends ConsumerState<ManageMembersSheet> {
  bool _adding = false;

  // Not awaited: offline, the write only completes after sync, but the list updates at once
  void _run(Future<void> f) {
    f.catchError((Object e) {
      if (mounted) AppSnackbar.error(context, 'Could not save: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider(widget.projectId)).value;
    final users =
        ref.watch(usersMapProvider).value ?? const <String, AppUser>{};

    if (project == null) {
      return const SafeArea(
        child: SizedBox(
          height: 140,
          child: Center(
            child: Text(
              'Project not found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ),
      );
    }

    final repo = ref.read(projectRepositoryProvider);
    final candidates =
        users.values
            .where((u) => u.isActive && !project.members.containsKey(u.id))
            .toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Manage team',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${project.members.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                project.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),

              for (final e in project.members.entries)
                _MemberRow(
                  name: users[e.key]?.name ?? 'Unknown',
                  initial: users[e.key]?.initial ?? '?',
                  role: e.value,
                  isCreator: e.key == project.createdBy,
                  onRole: (r) => _run(repo.setMember(project.id, e.key, r)),
                  onRemove: () => _run(repo.removeMember(project.id, e.key)),
                ),

              const SizedBox(height: 4),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _adding = !_adding),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        _adding ? Icons.close : Icons.add,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _adding ? 'Close' : 'Add member',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_adding)
                if (candidates.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Everyone is already in this project.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  for (final u in candidates)
                    _CandidateRow(
                      name: u.name,
                      initial: u.initial,
                      // one tap adds the user as Dev. Change the role from their row.
                      onAdd: () =>
                          _run(repo.setMember(project.id, u.id, 'dev')),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar(this.initial);
  final String initial;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: 16,
    backgroundColor: AppColors.primary,
    child: Text(
      initial,
      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.bg),
    ),
  );
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.name,
    required this.initial,
    required this.role,
    required this.isCreator,
    required this.onRole,
    required this.onRemove,
  });

  final String name;
  final String initial;
  final String role;
  final bool isCreator;
  final ValueChanged<String> onRole;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _Avatar(initial),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          PopupMenuButton<String>(
            tooltip: '', // no tooltip, which also avoids the ticker error
            color: AppColors.surfaceHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (v) => v == 'remove' ? onRemove() : onRole(v),
            itemBuilder: (_) => [
              for (final r in projectRoles)
                PopupMenuItem<String>(
                  value: r,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          roleLabel(r),
                          style: const TextStyle(color: AppColors.textPrimary),
                        ),
                      ),
                      if (r == role)
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                ),
              // the person who created the project stays in it
              if (!isCreator) ...[
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'remove',
                  child: Text(
                    'Remove from project',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            ],
            child: Container(
              padding: const EdgeInsets.only(
                left: 12,
                right: 6,
                top: 6,
                bottom: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    roleLabel(role),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSoft,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.name,
    required this.initial,
    required this.onAdd,
  });
  final String name;
  final String initial;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onAdd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            _Avatar(initial),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const Text(
              'Add',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
