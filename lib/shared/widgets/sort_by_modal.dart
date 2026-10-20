import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/providers/task_provider.dart';

String _sortLabel(TaskSort sort) {
  switch (sort) {
    case TaskSort.priority:
      return 'Priority';
    case TaskSort.dueDate:
      return 'Due Date';
    case TaskSort.title:
      return 'Title';
  }
}

Future<TaskSort?> showSortByModal(
  BuildContext context,
  WidgetRef ref,
  TaskSort currentSelected,
) {
  const options = TaskSort.values;

  return showModalBottomSheet<TaskSort>(
    context: context,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (bottomSheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'Done and Cancelled always keeps last',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 20),

                Row(
                  children: [
                    SortItem(
                      title: 'Priority',
                      isSelected: currentSelected == TaskSort.priority,
                      onSelect: () {
                        ref.read(taskSortProvider.notifier).state =
                            TaskSort.priority;
                        Navigator.pop(bottomSheetContext, TaskSort.priority);
                      },
                    ),
                    SortItem(
                      title: 'Due Date',
                      isSelected: currentSelected == TaskSort.dueDate,
                      onSelect: () {
                        ref.read(taskSortProvider.notifier).state =
                            TaskSort.dueDate;
                        Navigator.pop(bottomSheetContext, TaskSort.dueDate);
                      },
                    ),
                    SortItem(
                      title: 'Title',
                      isSelected: currentSelected == TaskSort.title,
                      onSelect: () {
                        ref.read(taskSortProvider.notifier).state =
                            TaskSort.title;
                        Navigator.pop(bottomSheetContext, TaskSort.title);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
/*

 */

class SortItem extends StatelessWidget {
  const SortItem({
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
