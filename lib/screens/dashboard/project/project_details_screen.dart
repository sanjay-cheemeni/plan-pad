import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/task.dart';
import 'package:plan_pad/providers/project_members_provider.dart';
import 'package:plan_pad/providers/project_provider.dart'; // projectProvider, usersMapProvider
import 'package:plan_pad/providers/task_provider.dart'; // projectTasksProvider
import 'package:plan_pad/providers/user_provider.dart';
import 'package:plan_pad/screens/dashboard/task/task_details_screen.dart';
import 'package:plan_pad/screens/dashboard/task/task_page.dart'; // PriorityBox, TaskOrBugBox
import 'package:plan_pad/shared/widgets/manage_mambers_sheet.dart';

class ProjectDetailsScreen extends ConsumerWidget {
  const ProjectDetailsScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider(projectId));
    final members = ref.watch(projectMembersProvider(projectId));
    final tasks = ref.watch(projectTasksProvider(projectId));
    final users = ref.watch(usersMapProvider).value ?? const {};
    final me = ref.watch(currentUserProvider).value;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 200,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: const Row(
            children: [
              Icon(Icons.chevron_left, color: AppColors.primary),
              Text(
                'back to Projects',
                style: TextStyle(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Managers can add members, change roles and remove members
          if (me != null && me.isManager)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () {
                  try {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                      ),
                      builder: (_) => ManageMembersSheet(projectId: projectId),
                    );
                  } catch (er) {
                    print('Error on popup: $er');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 16,
                        color: AppColors.textSoft,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Manage team',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: project.when(
        loading: () => const Center(
          child: SizedBox(
            width: 50,
            height: 22,
            child: SpinKitThreeBounce(color: AppColors.primary, size: 25),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (p) {
          if (p == null) return const Center(child: Text('Project not found'));

          final all = tasks.value ?? const <TaskItem>[];
          final pending = all.where((t) => !t.isClosed).toList();
          final done = all.where((t) => t.isClosed).toList();
          final bugs = pending.where((t) => t.isBug).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            children: [
              Text(
                p.name,
                style: const TextStyle(
                  fontSize: 25,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (p.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  p.description,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Created by ${users[p.createdBy]?.name ?? '-'}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // Summary
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    _StatItem(
                      value: tasks.hasValue ? '${pending.length}' : '-',
                      label: 'Pending',
                    ),
                    _StatItem(
                      value: tasks.hasValue ? '$bugs' : '-',
                      label: 'Bugs',
                    ),
                    _StatItem(
                      value: tasks.hasValue ? '${done.length}' : '-',
                      label: 'Completed',
                    ),
                  ],
                ),
              ),

              // Team
              const SizedBox(height: 24),
              const _SectionTitle('Team'),
              const SizedBox(height: 10),
              members.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Could not load team: $e'),
                data: (list) => Column(
                  children: [for (final m in list) _MemberTile(member: m)],
                ),
              ),

              // Pending tasks
              const SizedBox(height: 14),
              _SectionTitle(
                'Pending tasks${tasks.hasValue ? ' · ${pending.length}' : ''}',
              ),
              const SizedBox(height: 10),
              if (tasks.hasError)
                Text('Could not load tasks: ${tasks.error}')
              else if (!tasks.hasValue)
                const LinearProgressIndicator()
              else if (pending.isEmpty)
                const Text(
                  'No pending tasks',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                )
              else
                for (final t in pending) _TaskCard(task: t),

              // Completed tasks
              if (done.isNotEmpty) ...[
                const SizedBox(height: 14),
                _SectionTitle('Completed · ${done.length}'),
                const SizedBox(height: 10),
                for (final t in done) _TaskCard(task: t, dimmed: true),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
    ),
  );
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: AppColors.background,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.background,
          ),
        ),
      ],
    ),
  );
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});
  final ProjectMember member;

  @override
  Widget build(BuildContext context) {
    final u = member.user;
    final inactive = !u.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: inactive
                ? AppColors.surfaceHigh
                : AppColors.primary,
            child: Text(
              u.initial,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: inactive
                    ? AppColors.textSecondary
                    : AppColors.background,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: inactive
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  u.email,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textSoft, width: .3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              inactive ? '${member.label} · Inactive' : member.label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, this.dimmed = false});
  final TaskItem task;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final overdue = !task.isClosed && task.dueText.startsWith('Overdue');

    return Opacity(
      opacity: dimmed ? .6 : 1,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: task.id)),
        ),
        child: Container(
          width: double.maxFinite,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PriorityBox(priority: task.priority),
                  TaskOrBugBox(isBug: task.isBug),
                  const Spacer(),
                  Text(
                    task.dueText,
                    style: TextStyle(
                      fontSize: 10,
                      color: overdue
                          ? AppColors.error
                          : AppColors.textSecondary,
                      fontWeight: overdue ? FontWeight.w900 : FontWeight.w100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${task.assigneeName.isEmpty ? 'Unassigned' : task.assigneeName} · ${statusLabels[task.status] ?? task.status}'
                '${task.hasPendingWrites ? ' · Pending sync' : ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
