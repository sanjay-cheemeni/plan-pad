import 'package:flutter/material.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/project.dart';

Future<String?> showProjectSelectionModal({
  required BuildContext context,
  required List<Project> projects,
  String? selectedProjectId,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (bottomSheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Projects',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Text(
                'Select project',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              if (projects.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No projects yet. Create a project first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(bottomSheetContext).size.height * 0.6,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: projects.length,
                    // separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      final isSelected = project.id == selectedProjectId;

                      return ProjectItem(
                        title: project.name,
                        isSelected: isSelected,
                        onSelect: () =>
                            Navigator.pop(bottomSheetContext, project.id),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class ProjectItem extends StatelessWidget {
  const ProjectItem({
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
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
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
