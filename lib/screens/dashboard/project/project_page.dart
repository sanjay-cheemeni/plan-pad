import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/app_user.dart';
import 'package:plan_pad/models/project.dart';
import 'package:plan_pad/models/task.dart';
import 'package:plan_pad/providers/project_provider.dart';
import 'package:plan_pad/providers/task_provider.dart';
import 'package:plan_pad/providers/user_provider.dart';
import 'package:plan_pad/screens/dashboard/project/add_project_page.dart';
import 'package:plan_pad/screens/dashboard/project/project_details_screen.dart';
import 'package:plan_pad/screens/dashboard/task/task_details_screen.dart';
import 'package:plan_pad/screens/dashboard/task/task_page.dart';

class ProjectPage extends ConsumerWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final projects = ref.watch(myProjectsProvider(false));
    final users = ref.watch(usersMapProvider).value ?? const {};

    if (user == null) {
      return const Scaffold(
        // backgroundColor: AppColors.bg,
        body: Center(child: Text('Projects are available to managers only')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Projects',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: () => openAddProjectPage(context),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'New',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.bg,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: projects.when(
          data: (data) => Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20.0),
            child: Column(
              // mainAxisAlignment: .center,
              children: [
                Align(
                  alignment: .centerLeft,
                  child: Text(
                    '${user.roleLabel} view · tasks and team per project',
                    style: TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length + 1,
                    itemBuilder: (b, i) => (i == data.length)
                        ? SizedBox(height: 150)
                        : ProjectItem(users: users, project: data[i]),
                  ),
                ),

                // Text('${data.map((e) => e.toString()).toList()}'),
                // Expanded(
                //   child: ListView.builder(
                //     itemCount: data.length,
                //     itemBuilder: (context, index) {
                //       final element = data[index];

                //       return GestureDetector(
                //         onTap: () => openProjectDetailsPage(context, element),
                //         child: Text(element.name),
                //       );
                //     },
                //   ),
                // ),
                // Visibility(
                //   visible: !(user?.isManager ?? false),
                //   child: ElevatedButton(
                //     onPressed: () => openAddProjectPage(context),
                //     child: Text('Add Project'),
                //   ),
                // ),
              ],
            ),
          ),
          error: (er, st) => Text('Error: ${er}'),
          loading: () => Center(child: const SizedBox(
              width: 50,
              height: 22,
              child: SpinKitThreeBounce(color: AppColors.primary, size: 25),
            ),),
        ),
      ),
    );
  }

  openAddProjectPage(context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => AddProjectPage()),
    );
  }

  openProjectDetailsPage(context, Project project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ProjectDetailsScreen(projectId: project.id),
      ),
    );
  }
}

class ProjectItem extends ConsumerWidget {
  const ProjectItem({super.key, required this.users, required this.project});

  final Map<String, AppUser> users;
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(projectSummaryProvider(project.id));
    final s = summary.value;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailsScreen(projectId: project.id),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: double.maxFinite,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: AppColors.surface,
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ),
                Text(
                  s == null
                      ? ''
                      : '${s.open} open · ${s.bugs} ${s.bugs == 1 ? 'bug' : 'bugs'}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              runSpacing: 10,
              children: [
                for (final e in project.members.entries)
                  ProjectMemberPill(
                    title:
                        '${users[e.key]?.name ?? ''} · ${roleLabel(e.value)}',
                  ),
              ],
            ),
            const Divider(height: 24),
            if (summary.hasError)
              Text(
                'Could not load tasks: ${summary.error}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              )
            else if (s == null)
              const LinearProgressIndicator()
            else if (s.top.isEmpty)
              const Text(
                'No pending tasks',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              )
            else ...[
              for (final t in s.top) _TaskRow(task: t),
              if (s.open > s.top.length)
                Text(
                  '+ ${s.open - s.top.length} more',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({required this.task});
  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TaskDetailsScreen(taskId: task.id)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${task.assigneeName.isEmpty ? 'Unassigned' : task.assigneeName} · ${statusLabels[task.status] ?? task.status}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PriorityBox(priority: task.priority),
            TaskOrBugBox(isBug: task.isBug),
          ],
        ),
      ),
    );
  }
}

class ProjectMemberPill extends StatelessWidget {
  const ProjectMemberPill({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(50),

        border: BoxBorder.all(color: AppColors.textSecondary),
      ),
      child: Text(
        '$title',
        style: TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
