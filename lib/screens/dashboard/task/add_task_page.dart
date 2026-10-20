import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/project.dart';
import 'package:plan_pad/providers/add_task_provider.dart';
import 'package:plan_pad/providers/project_members_provider.dart';
import 'package:plan_pad/screens/success/task_success_page.dart';
import 'package:plan_pad/shared/widgets/project_selection_modal.dart';
import 'package:plan_pad/shared/widgets/snackbar.dart';
import 'package:plan_pad/shared/widgets/user_selection_modal.dart';

class AddTaskPage extends ConsumerStatefulWidget {
  const AddTaskPage({super.key});

  @override
  ConsumerState<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends ConsumerState<AddTaskPage> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String? _assigneeId;
  String _type = 'task';
  String _priority = 'medium';
  DateTime? _dueDate;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    final ok = await ref
        .read(addTaskControllerProvider.notifier)
        .add(
          projectId: ref.read(selectedTaskProjectProvider)?.id ?? '',
          title: _title.text,
          description: _desc.text,
          type: _type,
          priority: _priority,
          assigneeId: _assigneeId ?? '',
          dueDate: _dueDate,
        );
    if (ok && mounted)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => TaskSuccessPage()),
      );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(addTaskControllerProvider, (_, next) {
      if (next.hasError && !next.isLoading) {
        AppSnackbar.error(context, next.error.toString());
      }
    });

    final projects = ref.watch(taskProjectsProvider).value ?? [];
    final selected = ref.watch(
      selectedTaskProjectProvider,
    ); // Project? (auto-picked if only one)
    final members = selected == null
        ? null
        : ref.watch(assignableMembersProvider(selected.id));
    final state = ref.watch(addTaskControllerProvider);
    final workload = selected == null
        ? const <String, UserWorkload>{}
        : ref.watch(userWorkloadProvider(selected.id));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          'Add Task',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 12,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w100,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Title',
              style: TextStyle(
                fontSize: 12,
                height: 2,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
            TextField(
              enabled: !state.isLoading,
              controller: _title,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                // fillColor: Colors.grey.shade100,
              ),
            ),

            SizedBox(height: 15),

            Text(
              'Description',
              style: TextStyle(
                fontSize: 12,
                height: 2,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
            TextField(
              minLines: 2,
              maxLines: 5,
              enabled: !state.isLoading,
              controller: _desc,
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                // fillColor: Colors.grey.shade100,
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Type',
              style: TextStyle(
                fontSize: 12,
                height: 2,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),

            Row(
              children: [
                TypeItem(
                  title: 'Task',
                  isSelected: _type == 'task',
                  onSelect: () => setState(() => _type = 'task'),
                ),

                TypeItem(
                  title: 'Bug',
                  isSelected: _type == 'bug',
                  onSelect: () => setState(() => _type = 'bug'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'Priority',
              style: TextStyle(
                fontSize: 12,
                height: 2,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),

            Row(
              children: [
                TypeItem(
                  title: 'Urgent',
                  isSelected: _priority == 'urgent',
                  onSelect: () => setState(() => _priority = 'urgent'),
                ),

                TypeItem(
                  title: 'High',
                  isSelected: _priority == 'high',
                  onSelect: () => setState(() => _priority = 'high'),
                ),

                TypeItem(
                  title: 'Medium',
                  isSelected: _priority == 'medium',
                  onSelect: () => setState(() => _priority = 'medium'),
                ),

                TypeItem(
                  title: 'Low',
                  isSelected: _priority == 'low',
                  onSelect: () => setState(() => _priority = 'low'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Project',
              style: TextStyle(
                fontSize: 12,
                height: 2,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),

            GestureDetector(
              onTap: () async {
                final projectId = await showProjectSelectionModal(
                  context: context,
                  projects: projects,
                  selectedProjectId: selected?.id,
                );

                if (projectId != null && mounted) {
                  ref.read(newTaskProjectIdProvider.notifier).select(projectId);

                  setState(() {
                    _assigneeId = null;
                  });
                }
              },
              child: ProjectSelectionBox(selected: selected),
            ),

            const SizedBox(height: 16),
            Text(
              'Assign to',
              style: TextStyle(
                fontSize: 12,
                height: 2,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
            if (selected == null)
              const Center(
                child: Text(
                  'Select a project to see its users.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 2,
                    fontWeight: FontWeight.w100,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              members!.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Could not load members: $e'),
                data: (list) {
                  final selectedMembers = list.where(
                    (m) => m.user.id == _assigneeId,
                  );

                  final selectedUserName = selectedMembers.isEmpty
                      ? null
                      : '${selectedMembers.first.user.name} · ${selectedMembers.first.label}';

                  return GestureDetector(
                    onTap: () async {
                      final userId = await showUserSelectionModal(
                        context: context,
                        users: list,
                        selectedUserId: _assigneeId,
                        getUserId: (m) => m.user.id,
                        getUserName: (m) => '${m.user.name} · ${m.label}',
                      );

                      if (userId != null && mounted) {
                        setState(() {
                          _assigneeId = userId;
                        });
                      }
                    },
                    child: UserSelectionBox(
                      selectedUser: selectedUserName,
                      workloadLabel: workload[_assigneeId]?.label,
                    ),
                  );
                },
              ),

            const SizedBox(height: 16),
            Text(
              'Due date',
              style: TextStyle(
                fontSize: 12,
                height: 2,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),

            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.maxFinite,
                height: 60,

                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.only(left: 20, right: 20),

                child: Align(
                  alignment: .centerLeft,
                  child: Text(
                    _dueDate == null
                        ? 'Select due date'
                        : DateFormat('dd MMMM yyyy').format(_dueDate!),
                    style: TextStyle(
                      fontSize: 15,
                      height: 2,
                      fontWeight: _dueDate == null ? null : FontWeight.w900,
                      color: _dueDate == null
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            FilledButton(
              onPressed: state.isLoading ? null : _save,
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectSelectionBox extends StatelessWidget {
  const ProjectSelectionBox({super.key, required this.selected});

  final Project? selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 60,

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.only(left: 20),

      child: Align(
        alignment: AlignmentGeometry.centerLeft,
        child: Text(
          selected?.name ?? 'Select a project',
          style: TextStyle(
            fontSize: 15,
            height: 2,
            fontWeight: selected?.name == null ? null : FontWeight.w900,
            color: selected?.name == null
                ? AppColors.textSecondary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class UserSelectionBox extends StatelessWidget {
  const UserSelectionBox({
    super.key,
    required this.selectedUser,
    this.workloadLabel,
  });

  final String? selectedUser;
  // final List<String
  final String? workloadLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: 60,

      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.only(left: 20, right: 20),

      child: Align(
        alignment: AlignmentGeometry.centerLeft,
        child: Row(
          children: [
            Text(
              selectedUser ?? 'Select user',
              style: TextStyle(
                fontSize: 15,
                height: 2,
                fontWeight: selectedUser == null ? null : FontWeight.w900,
                color: selectedUser == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
            Spacer(),
            if (selectedUser != null)
              Text(
                workloadLabel ?? '',
                style: TextStyle(
                  fontSize: 12,
                  // height: 2,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TypeItem extends StatelessWidget {
  const TypeItem({
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
