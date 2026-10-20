import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/task.dart';
import 'package:plan_pad/providers/add_task_provider.dart'; // taskStatusControllerProvider, availableStatuses
import 'package:plan_pad/providers/project_provider.dart'; // usersMapProvider
import 'package:plan_pad/providers/task_provider.dart';
import 'package:plan_pad/providers/user_provider.dart';
import 'package:plan_pad/screens/dashboard/task/task_page.dart';
import 'package:plan_pad/shared/widgets/status_change_modal.dart';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _fmt(DateTime d) =>
    '${d.day} ${_months[d.month - 1]}, '
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

class TaskDetailsScreen extends ConsumerWidget {
  const TaskDetailsScreen({super.key, required this.taskId});
  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Shows validation errors and late server errors (for example permission denied)
    ref.listen(taskStatusControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${next.error}')));
      }
    });

    final task = ref.watch(taskProvider(taskId));
    final priority = task.value?.priority;
    final isBug = task.value?.isBug;
    final history = ref.watch(statusHistoryProvider(taskId));
    final user = ref.watch(currentUserProvider).value;
    final users = ref.watch(usersMapProvider).value ?? const {};
    final projects = ref.watch(visibleProjectsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 200,
        leading: GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Row(
            children: [
              Icon(Icons.chevron_left, color: AppColors.primary),
              Text(
                'back to Tasks',
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
          if (priority != null) PriorityBox(priority: priority),

          if (isBug != null)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: TaskOrBugBox(isBug: isBug),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: task.when(
          loading: () => const Center(child: const SizedBox(
              width: 50,
              height: 22,
              child: SpinKitThreeBounce(color: AppColors.primary, size: 25),
            )),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (task) {
            if (task == null)
              return const Center(child: Text('Task not found'));
            final options = user == null
                ? <String>[]
                : availableStatuses(task, user);
            return ListView(
              children: [
                Text(
                  '${task?.title}',
                  style: TextStyle(
                    fontSize: 25,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Assigned to ${task?.assigneeName} · Created by ${users[task?.createdBy]?.name ?? '-'} · ${task?.dueText}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 20),

                Container(
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),

                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12.0),

                  child: Column(
                    crossAxisAlignment: .start,
                    mainAxisAlignment: .center,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Text(
                            '${statusLabels[task?.status]}',
                            style: TextStyle(
                              color: AppColors.background,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // ElevatedButton(
                          //   onPressed: () {},
                          //   child: Text(
                          //     'Change Status',
                          //     style: TextStyle(fontWeight: FontWeight.bold),
                          //   ),
                          // ),
                          ElevatedButton(
                            onPressed: options.isEmpty
                                ? null // this user may not change this task
                                : () async {
                                    final newStatus = await showStatusModal(
                                      context: context,
                                      current: task.status,
                                      options: options,
                                    );
                                    if (newStatus != null) {
                                      ref
                                          .read(
                                            taskStatusControllerProvider
                                                .notifier,
                                          )
                                          .changeStatus(task, newStatus);
                                    }
                                  },
                            child: Text(
                              'Change Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                Text(
                  '${task?.description}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                  ),
                ),

                SizedBox(height: 20),

                history.when(
                  data: (list) => ListView.builder(
                    shrinkWrap: true, // takes only the height it needs
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final h = list[index];
                      return Container(
                        width: double.maxFinite,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(
                                h.changedByName[0],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (h.fromStatus == null)
                                  Text(
                                    'Created as ${statusLabels[h.toStatus] ?? h.toStatus}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                if (h.fromStatus != null)
                                  Row(
                                    children: [
                                      Text(
                                        '${statusLabels[h.fromStatus] ?? h.fromStatus}',
                                        style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded),
                                      Text(
                                        '${statusLabels[h.toStatus] ?? h.toStatus}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 2),
                                Text(
                                  '${h.changedByName} · ${_fmt(h.at)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  error: (er, st) => Text('Error: $er'),
                  loading: () =>
                      const Center(child: const SizedBox(
              width: 50,
              height: 22,
              child: SpinKitThreeBounce(color: AppColors.primary, size: 25),
            )),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
