import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/task.dart';
import 'package:plan_pad/providers/task_provider.dart';
import 'package:plan_pad/screens/dashboard/task/add_task_page.dart';
import 'package:plan_pad/screens/dashboard/task/task_details_screen.dart';
import 'package:plan_pad/shared/widgets/sort_by_modal.dart';

class TaskPage extends ConsumerStatefulWidget {
  const TaskPage({super.key});

  @override
  ConsumerState<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  @override
  Widget build(BuildContext context) {
    final pending =
        ref
            .read(allTasksProvider)
            .value
            ?.where((t) => t.hasPendingWrites)
            .length ??
        0;
    final taskState = ref.watch(filteredTasksProvider);
    final filter = ref.watch(taskFilterProvider);
    final sort = ref.watch(taskSortProvider);

    String sortLabel(TaskSort s) => switch (s) {
      TaskSort.priority => 'Priority',
      TaskSort.dueDate => 'Due date',
      TaskSort.title => 'Title',
    };
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    debugPrint('inset: ${MediaQuery.of(context).viewInsets.bottom}');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Tasks',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () async {
                final selected = await showSortByModal(context, ref, sort);
              },
              child: Text(
                'By ${sortLabel(sort)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w100,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: isKeyboardVisible
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.extended(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                onPressed: () => openAddTaskPage(context),
                label: const Text(
                  'Add Task',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                icon: const Icon(Icons.add, size: 15),
              ),
            ),
      body: taskState.when(
        data: (data) => Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 00.0),
          child: Column(
            children: [
              if (pending != 0)
                Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.highBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Offline · $pending changes waiting to sync',
                    style: TextStyle(
                      color: AppColors.highFg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

              SizedBox(height: 10),

              TextField(
                onChanged: (v) =>
                    ref.read(taskSearchProvider.notifier).state = v,
                decoration: InputDecoration(
                  hintText: 'Search title or tag',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  FilterItem(
                    title: 'All',
                    isSelected: filter == TaskFilter.all,
                    onSelect: () =>
                        ref.read(taskFilterProvider.notifier).state =
                            TaskFilter.all,
                  ),
                  FilterItem(
                    title: 'Urgent',
                    isSelected: filter == TaskFilter.urgent,
                    onSelect: () =>
                        ref.read(taskFilterProvider.notifier).state =
                            TaskFilter.urgent,
                  ),
                  FilterItem(
                    title: 'Bugs',
                    isSelected: filter == TaskFilter.bugs,
                    onSelect: () =>
                        ref.read(taskFilterProvider.notifier).state =
                            TaskFilter.bugs,
                  ),
                  FilterItem(
                    title: 'Tasks',
                    isSelected: filter == TaskFilter.tasks,
                    onSelect: () =>
                        ref.read(taskFilterProvider.notifier).state =
                            TaskFilter.tasks,
                  ),
                ],
              ),

              SizedBox(height: 10),

              if (data.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.task_alt_rounded,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks/bugs found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Your tasks/bugs will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Your existing task list
              Expanded(
                child: ListView.builder(
                  itemCount: data.length + 1,
                  itemBuilder: (bc, index) {
                    if (index == data.length) return SizedBox(height: 200);

                    final task = data[index];
                    final now = DateTime.now();

                    final isDueExpired = task.dueDate?.isBefore(now) ?? false;

                    return GestureDetector(
                      onTap: () => OpenTaskDetailsPage(context, task),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 15,
                        ),

                        margin: EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Row(
                              children: [
                                PriorityBox(priority: task.priority),
                                TaskOrBugBox(isBug: task.isBug),
                                Spacer(),
                                Text(
                                  task.dueText,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDueExpired
                                        ? AppColors.error
                                        : AppColors.textSecondary,
                                    fontWeight: isDueExpired
                                        ? FontWeight.w900
                                        : FontWeight.w100,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${task.assigneeName} · ${statusLabels[task.status]}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ===========================================
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: data.length,
              //     itemBuilder: ((context, index) {
              //       return GestureDetector(
              //         onTap: () => OpenTaskDetailsPage(context, data[index]),
              //         child: Container(
              //           margin: EdgeInsets.symmetric(
              //             vertical: 10,
              //             horizontal: 10,
              //           ),
              //           width: 100,
              //           height: 40,
              //           color: Colors.green,
              //           child: Text(data[index].title),
              //         ),
              //       );
              //     }),
              //   ),
              // ),
            ],
          ),
        ),
        error: (error, stackTrace) => Text('Error: $error'),
        loading: () => const SizedBox(
          width: 50,
          height: 22,
          child: SpinKitThreeBounce(color: AppColors.primary, size: 25),
        ),
      ),
    );
  }

  void openAddTaskPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => AddTaskPage()));
  }

  void OpenTaskDetailsPage(BuildContext context, TaskItem data) {
    print('${data.projectId}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => TaskDetailsScreen(taskId: data.id)),
    );
  }
}

class PriorityBox extends StatelessWidget {
  const PriorityBox({super.key, required String this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = AppColors.priority(priority);
    final taskPriority = priority[0].toUpperCase() + priority.substring(1);
    return Container(
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Text(
        taskPriority,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  getBackgroundColor(String priority) {}
}

class TaskOrBugBox extends StatelessWidget {
  const TaskOrBugBox({super.key, required bool this.isBug});

  final bool isBug;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: BoxBorder.all(color: AppColors.textSoft, width: .3),
        borderRadius: BorderRadius.circular(25),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Text(
        isBug ? 'Bug' : 'Task',
        style: TextStyle(
          color: AppColors.textSoft,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class FilterItem extends StatelessWidget {
  const FilterItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onSelect,
  });
  final String title;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Text(
          '$title',
          style: TextStyle(
            color: isSelected ? AppColors.bg : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
