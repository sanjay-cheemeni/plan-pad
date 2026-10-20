import 'package:flutter/material.dart';
import 'package:plan_pad/core/values/app_colors.dart';

/// Returns true if the user confirms the logout.
Future<bool> showLogoutDialog(
  BuildContext context, {
  int pendingChanges = 0, // changes saved on the phone but not yet synced
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.urgentBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            const Text(
              'Log out?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You will need to sign in again to see your tasks and projects.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            if (pendingChanges > 0) ...[
              const SizedBox(height: 14),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.highBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$pendingChanges change${pendingChanges == 1 ? '' : 's'} not synced yet. '
                  'Reconnect and wait for them to sync before logging out, or they may be lost.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.highFg,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surfaceHigh,
                        foregroundColor: AppColors.textSoft,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.background,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Log out',
                          style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false; // tapping outside the dialog counts as Cancel
}