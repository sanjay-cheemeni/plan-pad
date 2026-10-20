import 'package:flutter/material.dart';
import 'package:plan_pad/core/values/app_colors.dart';
import 'package:plan_pad/models/task.dart'; // statusLabels

/// Returns the chosen status key (for example 'in_progress'), or null if dismissed.
Future<String?> showStatusModal({
  required BuildContext context,
  required String current,
  required List<String> options,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.bg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => SafeArea(
      child: SizedBox(
        width: double.maxFinite,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Change status to',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: [
                  Text(
                    'The current status is ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textSecondary,
                    ),
                  ),
                   Text(
                    '${statusLabels[current] ?? current}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textSoft,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final s in options)
                    StatusPill(
                      title: statusLabels[s] ?? s,
                      isSelected: false,
                      onSelect: () => Navigator.pop(sheetContext, s),
                    ),
                ],
              ),

              // ListTile(
              //   contentPadding: EdgeInsets.zero,
              //   title: Text(
              //     statusLabels[s] ?? s,
              //     style: const TextStyle(fontWeight: FontWeight.w600),
              //   ),
              //   onTap: () => Navigator.pop(sheetContext, s),
              // ),
            ],
          ),
        ),
      ),
    ),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill({
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
